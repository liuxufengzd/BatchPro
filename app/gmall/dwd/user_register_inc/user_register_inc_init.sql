log_inc
=
SELECT common.uid user_id,
       common.ch  channel,
       common.ar  province_id,
       common.vc  version_code,
       common.mid mid_id,
       common.ba  brand,
       common.md  model,
       common.os  operate_system
FROM log_inc
WHERE common.uid is not null
  AND page.page_id = 'register';

user_info
=
SELECT data.id user_id,
       data.create_time
FROM user_info_inc
WHERE type = 'bootstrap-insert';

result
=
SELECT user_info.user_id,
       channel,
       province_id,
       version_code,
       mid_id,
       brand,
       model,
       operate_system,
       create_time,
       date_format(create_time, 'yyyy-MM-dd') date_id
FROM user_info
         LEFT JOIN log_inc ON user_info.user_id = log_inc.user_id;
