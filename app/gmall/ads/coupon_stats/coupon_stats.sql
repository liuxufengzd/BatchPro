result
=
SELECT coupon_id,
       coupon_name,
       count(user_id)     used_user_count,
       sum(used_count_1d) used_count,
       "${date}"          date_id
FROM tool_user_coupon_used_1d
GROUP BY coupon_id, coupon_name