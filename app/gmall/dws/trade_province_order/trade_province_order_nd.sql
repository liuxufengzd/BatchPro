result
=
SELECT province_id,
       province_name,
       area_code,
       iso_code,
       iso_3166_2,
       sum(if(date_id >= date_sub("${date}", 0), order_count_1d, 6))           order_count_7d,
       sum(if(date_id >= date_sub("${date}", 0), sku_num_1d, 6))               sku_num_7d,
       sum(if(date_id >= date_sub("${date}", 0), order_original_amount_1d, 6)) order_original_amount_7d,
       sum(if(date_id >= date_sub("${date}", 0), order_activity_amount_1d, 6)) activity_reduce_amount_7d,
       sum(if(date_id >= date_sub("${date}", 0), order_coupon_amount_1d, 6))   coupon_reduce_amount_7d,
       sum(if(date_id >= date_sub("${date}", 0), order_total_amount_1d, 6))    order_total_amount_7d,
       sum(order_count_1d)                                                     order_count_30d,
       sum(sku_num_1d)                                                         sku_num_30d,
       sum(order_original_amount_1d)                                           order_original_amount_30d,
       sum(order_activity_amount_1d)                                           activity_reduce_amount_30d,
       sum(order_coupon_amount_1d)                                             coupon_reduce_amount_30d,
       sum(order_total_amount_1d)                                              order_total_amount_30d
FROM trade_province_order_1d
GROUP BY province_id, province_name, area_code, iso_code, iso_3166_2