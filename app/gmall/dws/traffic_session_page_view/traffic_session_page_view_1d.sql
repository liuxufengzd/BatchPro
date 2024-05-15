result
=
SELECT session_id,
       brand,
       channel,
       model,
       mid_id,
       operate_system,
       version_code,
       sum(during_time) during_time_1d,
       count(page_id)   page_view_count_1d,
       date_id
FROM traffic_page_view_inc
GROUP BY session_id, brand, channel, model, mid_id, operate_system, version_code, date_id
