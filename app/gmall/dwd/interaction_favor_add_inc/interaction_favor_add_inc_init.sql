result
=
SELECT data.user_id,
       data.sku_id,
       data.spu_id,
       data.create_time,
       date_format(data.create_time, 'yyyy-MM-dd') date_id
FROM favor_info_inc
WHERE type = 'bootstrap-insert'