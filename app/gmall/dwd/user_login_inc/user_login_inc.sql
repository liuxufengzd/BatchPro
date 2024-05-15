log_inc
=
SELECT common.uid   user_id,
       common.ch    channel,
       common.ar    province_id,
       common.vc    version_code,
       common.mid   mid_id,
       common.ba    brand,
       common.md    model,
       common.os    operate_system,
       ts,
       row_number() OVER(PARTITION BY common.sid ORDER BY ts) rn
FROM log_inc
WHERE common.uid is not null
  AND page is not null;

result
=
SELECT user_id,
       channel,
       province_id,
       version_code,
       mid_id,
       brand,
       model,
       operate_system,
       from_unixtime(round(ts / 1000, 0), 'yyyy-MM-dd HH:mm:ss') login_time,
       from_unixtime(round(ts / 1000, 0), 'yyyy-MM-dd')          date_id
FROM log_inc
WHERE rn = 1;
