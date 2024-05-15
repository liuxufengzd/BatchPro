traffic_page_view_inc
=
SELECT (user_id is not null)                registered,
       if(user_id is null, mid_id, user_id) visitor_id,
       brand,
       channel,
       model,
       operate_system,
       during_time,
       page_id,
       date_id
FROM traffic_page_view_inc;

result
=
SELECT registered,
       visitor_id,
       page_id,
       brand,
       channel,
       model,
       operate_system,
       sum(during_time) during_time_1d,
       count(page_id)   page_view_count_1d,
       date_id
FROM traffic_page_view_inc
GROUP BY registered, visitor_id, page_id, brand, channel, model, operate_system, date_id
