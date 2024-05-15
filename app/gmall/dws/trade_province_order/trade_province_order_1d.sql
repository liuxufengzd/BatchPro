trade_order_detail_inc
=
SELECT province_id,
       count(distinct user_id)    user_count_1d,
       count(distinct order_id)   order_count_1d,
       sum(sku_num)               sku_num_1d,
       sum(split_original_amount) order_original_amount_1d,
       sum(split_activity_amount) order_activity_amount_1d,
       sum(split_coupon_amount)   order_coupon_amount_1d,
       sum(split_total_amount)    order_total_amount_1d,
       date_id
FROM trade_order_detail_inc
GROUP BY province_id, date_id;

result
=
SELECT province_id,
       name province_name,
       area_code,
       iso_code,
       iso_3166_2,
       user_count_1d,
       order_count_1d,
       sku_num_1d,
       order_original_amount_1d,
       order_activity_amount_1d,
       order_coupon_amount_1d,
       order_total_amount_1d,
       date_id
FROM trade_order_detail_inc a
         LEFT JOIN province_full b ON a.province_id = b.id