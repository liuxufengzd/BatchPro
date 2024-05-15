result
=
SELECT user_id,
       min(order_date_first)          order_date_first,
       max(order_date_last)           order_date_last,
       sum(order_count_td)            order_count_td,
       sum(order_num_td)              order_num_td,
       sum(original_amount_td)        original_amount_td,
       sum(activity_reduce_amount_td) activity_reduce_amount_td,
       sum(coupon_reduce_amount_td)   coupon_reduce_amount_td,
       sum(total_amount_td)           total_amount_td
FROM (SELECT user_id,
             "${date}"                  order_date_first,
             "${date}"                  order_date_last,
             count(distinct order_id)   order_count_td,
             sum(sku_num)               order_num_td,
             sum(split_original_amount) original_amount_td,
             sum(split_activity_amount) activity_reduce_amount_td,
             sum(split_coupon_amount)   coupon_reduce_amount_td,
             sum(split_total_amount)    total_amount_td
      FROM trade_order_detail_inc
      GROUP BY user_id
      UNION ALL
      SELECT user_id,
             order_date_first,
             order_date_last,
             order_count_td,
             order_num_td,
             original_amount_td,
             activity_reduce_amount_td,
             coupon_reduce_amount_td,
             total_amount_td
      FROM trade_user_order_td)
GROUP BY user_id