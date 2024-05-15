result
=
SELECT common.ar                                                 province_id,
       common.ba                                                 brand,
       common.ch                                                 channel,
       common.is_new                                             is_new,
       common.md                                                 model,
       common.mid                                                mid_id,
       common.os                                                 operate_system,
       common.uid                                                user_id,
       common.vc                                                 version_code,
       common.sid                                                session_id,
       page.item                                                 page_item,
       page.item_type                                            page_item_type,
       page.last_page                                            last_page_id,
       page.page_id,
       page.from_pos_id,
       page.from_pos_seq,
       page.refer_id,
       page.during_time,
       from_unixtime(round(ts / 1000, 0), 'yyyy-MM-dd HH:mm:ss') view_time,
       from_unixtime(round(ts / 1000, 0), 'yyyy-MM-dd')          date_id
FROM log_inc
WHERE page is not null