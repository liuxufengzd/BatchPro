insert_data
=
SELECT data.id,
       data.user_id,
       data.sku_id,
       data.sku_name,
       data.sku_num,
       data.create_time,
       date_format(data.create_time, 'yyyy-MM-dd') date_id
FROM cart_info_inc
WHERE type = 'insert';

update_data
=
SELECT data.id,
       data.user_id,
       data.sku_id,
       data.sku_name,
       data.sku_num - cast(old['sku_num'] as int)   sku_num,
       data.operate_time,
       date_format(data.operate_time, 'yyyy-MM-dd') date_id
FROM cart_info_inc
WHERE type = 'update'
  and old['sku_num'] is not null and data.sku_num > cast(old['sku_num'] as int);

result
= (SELECT * FROM insert_data) UNION ALL (SELECT * FROM update_data)
