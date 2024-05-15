result
=
SELECT user_id,
       province_id,
       payment_type_code,
       payment_type_name,
       sku_id,
       count(distinct order_id)   payment_count_1d,
       sum(sku_num)               payment_num_1d,
       sum(split_original_amount) total_amount_1d,
       sum(split_activity_amount) activity_amount_1d,
       sum(split_coupon_amount)   coupon_amount_1d,
       sum(split_payment_amount)  payment_amount_1d,
       date_id
FROM trade_pay_detail_suc_inc
GROUP BY user_id, province_id, payment_type_code, payment_type_name, sku_id, date_id