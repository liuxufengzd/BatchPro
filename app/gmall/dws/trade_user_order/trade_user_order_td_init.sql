result
=
SELECT user_id,
       min(date_id)               order_date_first,
       max(date_id)               order_date_last,
       sum(distinct order_id)     order_count_td,
       sum(sku_num)               order_num_td,
       sum(split_original_amount) original_amount_td,
       sum(split_activity_amount) activity_reduce_amount_td,
       sum(split_coupon_amount)   coupon_reduce_amount_td,
       sum(split_total_amount)    total_amount_td
FROM trade_order_detail_inc
GROUP BY user_id