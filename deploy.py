import json
import subprocess
from collections import defaultdict

from pydolphinscheduler.core import Engine, Task
from pydolphinscheduler.core.resource import Resource

import os


def parse_files(directory):
    file_list = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            with open(file_path, 'r') as f:
                file_list.append((file_path, f.read()))
    return file_list


def calculate_dependencies(tasks):
    graph = {}
    indegree = {}
    result = []

    # Build the graph and calculate indegrees
    for child, parents in tasks.items():
        graph[child] = parents
        indegree[child] = 0
    for parents in tasks.values():
        for parent in parents:
            if parent not in indegree:
                indegree[parent] = 0
            indegree[parent] += 1

    # Topological sort
    queue = [task for task, degree in indegree.items() if degree == 0]
    while queue:
        node = queue.pop(0)
        result.append(node)
        for child in graph.get(node, []):
            indegree[child] -= 1
            if indegree[child] == 0:
                queue.append(child)

    # If there are cycles in the graph, return None
    if len(result) != len(graph):
        return None
    else:
        return result[::-1]


def get_source_default_layer(sink_layer: str):
    if sink_layer == 'dwd' or sink_layer == 'dim':
        return 'ods'
    if sink_layer == 'dws':
        return 'dwd'
    if sink_layer == 'ads':
        return 'dws'


# STEP1 - Upload file to resource center and build graph
directories = ['resource', 'app']
file_list = []
workflows = {}
for directory in directories:
    file_list.extend(parse_files(directory))

workflow_order = []
path_map = {}
for path, content in file_list:
    Resource(name=str(path), content=content, user_name="admin").create_or_update_resource()
    if not path.endswith('.json'):
        continue
    context = json.loads(content)
    env = context['env']
    if env.get('scheduler') is None:
        continue
    app = env.get('app')
    layer = env['layer'].lower()
    sources = context.get('sources')
    table = f"{layer}_{env['table']}"
    if app is not None:
        table = f"{app}_{table}"
    path_map[table] = path
    if layer == 'ods' or sources is None:
        workflows[table] = []
        continue
    workflows[table] = []
    for source in sources:
        source_layer = get_source_default_layer(layer) if source.get('layer') is None else source['layer']
        source_name = f"{app}_{source_layer}_{source['table']}"
        if source_name != table:
            workflows[table].append(source_name)

workflow_order = calculate_dependencies(workflows)

# STEP2 - Submit workflows
for workflow in workflow_order:
    path = path_map[workflow]
    subprocess.run(["echo", "python", "workflow.py", path])
    subprocess.run(["python", "workflow.py", path])
