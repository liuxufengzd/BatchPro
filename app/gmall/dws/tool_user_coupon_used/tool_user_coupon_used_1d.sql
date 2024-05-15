tool_coupon_used_inc
=
SELECT user_id,
       coupon_id,
       count(coupon_id) used_count_1d,
       date_id
FROM tool_coupon_used_inc
GROUP BY date_id, user_id, coupon_id;

result
=
SELECT user_id,
       coupon_id,
       coupon_name,
       coupon_type,
       coupon_type_name,
       benefit_rule,
       used_count_1d,
       date_id
FROM tool_coupon_used_inc a
         LEFT JOIN coupon_full b ON a.coupon_id = b.id
