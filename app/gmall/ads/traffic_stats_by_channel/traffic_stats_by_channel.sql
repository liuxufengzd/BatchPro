result
=
SELECT recent_days,
       channel,
       count(session_id)                                                    sv_count,
       count(distinct mid_id)                                               uv_count,
       cast(avg(during_time_1d) / 1000 as bigint)                           avg_duration_sec,
       cast(avg(page_view_count_1d) as bigint)                              avg_page_count,
       cast(count_if(page_view_count_1d == 1) / count(*) as decimal(16, 2)) bounce_rate,
       '${date}'                                                            date_id
FROM traffic_session_page_view_1d LATERAL VIEW explode(array(1,7,30)) tmp as recent_days
WHERE date_id >= date_sub('${date}', recent_days-1)
GROUP BY recent_days, channel


SELECT common.*, display.*, ts FROM displayData LATERAL VIEW EXPLODE(displays) tmp as display