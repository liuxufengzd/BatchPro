result
=
SELECT data.id,
       data.user_id,
       data.sku_id,
       data.sku_name,
       data.sku_num,
       data.create_time,
       date_format(data.create_time, 'yyyy-MM-dd') date_id
FROM cart_info_inc
WHERE type = 'bootstrap-insert'
