import json
import os
import sys
from argparse import ArgumentError
from datetime import datetime, timedelta

from pydolphinscheduler.core import Task
from pydolphinscheduler.core.workflow import Workflow
from pydolphinscheduler.tasks import Condition, Switch, SwitchCondition, Branch, Default, SUCCESS
from pydolphinscheduler.tasks.condition import And as C_And
from pydolphinscheduler.tasks.shell import Shell


def get_cron(frequency: str, delay: int):
    if frequency.lower() == 'day':
        return f'0 0 {delay} * * ? *'
    if frequency.lower() == 'hour':
        return f'0 {delay} 0 * * * ? *'


def etl_task(command: str, configuration: str, date=None, script=None, udf=None):
    full_command = f'$SPARK_HOME/bin/spark-submit {command} -c {configuration}'
    resource_list = [command, configuration]
    if date is not None:
        full_command = f"{full_command} -t {date}"
    if script is not None:
        full_command = f"{full_command} -s {script}"
        resource_list.append(script)
    if udf is not None:
        full_command = f"{full_command} -f {udf}"
        resource_list.append(udf)
    return Shell(
        name='transform',
        command=full_command,
        resource_list=resource_list
    )


def create_tracker_task(layer: str, table: str, date: str):
    return Shell(
        name='create_tracker',
        command=f"""
        hadoop fs -mkdir -p /user/lakehouse/tracker/{layer}/{table}
        hadoop fs -touch /user/lakehouse/tracker/{layer}/{table}/{date}.tracker
        """
    )


def check_sink_tracker(layer: str, table: str, date: str, execution_task: Task):
    check_sink_tracker_task = Shell(
        name='check_tracker',
        command="""
        hadoop fs -test -e /user/lakehouse/tracker/${layer}/${table}/${date}.tracker
        echo "#{setValue(tracker_exists=$?)}"
        """,
        input_params={"layer": layer, "table": table, "date": date},
        output_params={"tracker_exists": ''}
    )
    check_sink_tracker_task.set_downstream(Switch(name="switch", condition=SwitchCondition(
        Branch(condition="${tracker_exists} != 0", task=execution_task),
        Default(task=Shell(name="skip", command="echo skip running..."))
    )))
    return check_sink_tracker_task


def check_source_tracker_task(layer: str, table: str, dates: str):
    return Shell(
        name=f"check_{table}_tracker",
        command="""
                declare -a dates=(${dates})
                sleep_counter=${sleep_counter}
                i=0
                while [ $i -lt ${#dates[@]} ]
                do
                    hadoop fs -test -e /user/lakehouse/tracker/${layer}/${table}/${dates[$i]}.tracker
                    if [ $? -ne 0 ]; then
                        sleep_counter=$(($sleep_counter-1))
                        if [ $sleep_counter -eq -1 ]; then
                            exit 1
                        fi
                        echo Waiting for tracker of ${dates[$i]}...
                        sleep ${sleep_minus}m
                    else
                        i=$(($i+1))
                    fi                  
                done  
                """,
        input_params={"layer": layer, "table": table, "dates": " ".join(dates),
                      "sleep_minus": BLOCK_SLEEP_MINUTES, "sleep_counter": BLOCK_RETRY_TIMES}
    )


def get_source_default_layer(sink_layer: str):
    if sink_layer == 'dwd' or sink_layer == 'dim':
        return 'ods'
    if sink_layer == 'dws':
        return 'dwd'
    if sink_layer == 'ads':
        return 'dws'


args = sys.argv
if len(args) != 2:
    raise ArgumentError(None, "Arguments: config path is required")
config_path = args[1]
with open(config_path, encoding="utf-8") as f:
    context = json.load(f)
BLOCK_RETRY_TIMES = 60
BLOCK_SLEEP_MINUTES = 1

date = "$[yyyy-MM-dd]"

env = context['env']
layer = env['layer'].strip().lower()
table = env['table']
scheduler = env['scheduler']
app = env.get('app')
PROJECT_NAME = app
table_full_name = f"{layer}_{env['table']}"
if app is not None:
    table_full_name = f"{app}_{table_full_name}"
user = 'admin'
command = 'resource/transform.py'
udf_file = "resource/udf/udf.py"

if layer == 'ods' or env.get('local') is True:
    command = 'resource/ods.py'
    with Workflow(
            project=PROJECT_NAME,
            name=table_full_name,
            user=user,
            schedule=get_cron(scheduler['frequency'], scheduler['delay']),
            start_time=scheduler['startTime']
    ) as workflow:
        create_tracker = create_tracker_task(layer, table_full_name, date)
        ods_transform = etl_task(command, config_path, date)
        check_sink_tracker(layer, table_full_name, date, ods_transform)
        ods_transform >> create_tracker

        workflow.run()
else:
    with Workflow(
            project=PROJECT_NAME,
            name=table_full_name,
            user=user,
            schedule=get_cron(scheduler['frequency'], scheduler['delay']),
            start_time=scheduler['startTime'],
            param={"var": 1}
    ) as workflow:
        create_tracker = create_tracker_task(layer, table_full_name, date)

        sql_file = f"{os.path.dirname(config_path)}/{context['transform']['sql']}.sql"
        require_udf = context['transform'].get('udf') is not None
        transform = etl_task(command, config_path, date, sql_file, udf_file if require_udf else None)

        check_sources = []
        for source in context['sources']:
            dates = [date]
            if source.get('dates'):
                dates = source['dates']
            elif source.get('range'):
                dates = []
                v1, v2 = json.loads(source['range'])
                date_format = "%Y-%m-%d"
                for i in range(v1, v2 + 1):
                    dates.append((datetime.strptime(date, date_format) + timedelta(days=i)).strftime(date_format))
            source_layer = get_source_default_layer(layer) if source.get('layer') is None else source['layer']
            source_full_table_name = f"{app}_{source_layer}_{source['table']}"
            dates = filter(lambda d: d >= scheduler['startTime'], dates)
            check_sources.append(check_source_tracker_task(source_layer, source_full_table_name, dates))

        condition = Condition(
            name="condition",
            condition=C_And(
                C_And(
                    SUCCESS(*check_sources)
                )
            ),
            success_task=transform,
            failed_task=Shell(name="fail", command="exit 1")
        )

        check_sink_tracker(layer, table_full_name, date, condition)
        transform >> create_tracker

        if layer == 'ads':
            command = 'resource/data_share/share2db.py'
            data_share = Shell(
                name='data_share',
                command=f"$SPARK_HOME/bin/spark-submit {command} -t {table_full_name} -d {date}",
                resource_list=[command]
            )
            create_tracker >> data_share

        workflow.run()
