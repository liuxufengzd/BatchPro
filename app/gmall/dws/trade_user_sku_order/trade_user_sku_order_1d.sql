-- efficiency is not optimal, we can do aggregation at first and then join
result
=
SELECT user_id,
       sku_id,
       sku_name,
       tm_id,
       tm_name,
       category1_id,
       category1_name,
       category2_id,
       category2_name,
       category3_id,
       category3_name,
       count(distinct order_id)   order_count_1d,
       sum(sku_num)               order_num_1d,
       sum(split_original_amount) order_original_amount_1d,
       sum(split_activity_amount) activity_reduce_amount_1d,
       sum(split_coupon_amount)   coupon_reduce_amount_1d,
       sum(split_total_amount)    order_total_amount_1d,
       date_id
FROM trade_order_detail_inc
         LEFT JOIN sku_full ON trade_order_detail_inc.sku_id = sku_full.id
GROUP BY user_id,
         sku_id,
         sku_name,
         tm_id,
         tm_name,
         category1_id,
         category1_name,
         category2_id,
         category2_name,
         category3_id,
         category3_name,
         date_id