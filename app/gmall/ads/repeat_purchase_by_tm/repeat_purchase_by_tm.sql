result
=
SELECT user_id,
       tm_id,
       tm_name,
       sum(order_count_30d) total_count
FROM trade_user_sku_order_nd
GROUP BY user_id, tm_id, tm_name;

result
=
SELECT 30                                                                                  recent_days,
       tm_id,
       tm_name,
       cast(count_if(total_count > 1) / count_if(total_count > 0) * 100 as decimal(16, 2)) order_repeat_rate,
       '${date}'                                                                           date_id
FROM result
GROUP BY tm_name, tm_id;