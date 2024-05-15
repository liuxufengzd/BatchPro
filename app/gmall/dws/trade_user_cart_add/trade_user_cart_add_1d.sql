result
=
SELECT user_id,
       sku_id,
       sku_name,
       count(user_id) cart_add_count_1d,
       sum(sku_num)   cart_add_num_1d,
       date_id
FROM trade_cart_add_inc
GROUP BY date_id, sku_id, sku_name, user_id