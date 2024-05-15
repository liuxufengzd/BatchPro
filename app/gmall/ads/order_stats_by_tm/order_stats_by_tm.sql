-- If no nd is cached in DWS
-- result
-- =
-- SELECT days             recent_days,
--        tm_id,
--        tm_name,
--        sum(order_count) order_count,
--        count(distinct user_id) order_user_count,
--        "${date}"        date_id
-- FROM trade_user_sku_order_1d LATERAL VIEW explode(array(1,7,30)) tmp as days
-- WHERE date_id >= date_sub("${date}", days-1)
-- GROUP BY days, tm_id, tm_name

-- If nd is cached in DWS
result
=
SELECT *, "${date}" date_id
FROM (SELECT 1                       recent_days,
             tm_id,
             tm_name,
             sum(order_count_1d)     order_count,
             count(distinct user_id) order_user_count
      FROM trade_user_sku_order_nd
      WHERE order_count_1d > 0
      GROUP BY tm_id, tm_name
      UNION ALL
      SELECT 7                       recent_days,
             tm_id,
             tm_name,
             sum(order_count_7d)     order_count,
             count(distinct user_id) order_user_count
      FROM trade_user_sku_order_nd
      WHERE order_count_7d > 0
      GROUP BY tm_id, tm_name
      UNION ALL
      SELECT 30                      recent_days,
             tm_id,
             tm_name,
             sum(order_count_30d)    order_count,
             count(distinct user_id) order_user_count
      FROM trade_user_sku_order_nd
      WHERE order_count_30d > 0
      GROUP BY tm_id, tm_name)