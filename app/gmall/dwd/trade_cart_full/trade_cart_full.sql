result
=
SELECT id,
       user_id,
       sku_id,
       sku_name,
       sku_num
FROM cart_info_full
WHERE is_ordered = '0'