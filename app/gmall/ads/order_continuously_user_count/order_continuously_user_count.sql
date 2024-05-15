-- Method1: UDAF
result
=
SELECT user_id,
       cast(has_continue_dates(collect_set(date_id), 3) as boolean) has_continue_dates
FROM trade_user_sku_order
GROUP BY user_id;

result
=
SELECT '${date}'      date_id,
       7              recent_days,
       count(user_id) order_continuously_user_count
FROM result
WHERE has_continue_dates

-- Method2: Use lead

-- trade_user_sku_order
-- =
-- SELECT DISTINCT *
-- FROM trade_user_sku_order;
--
-- result
-- =
-- select '${date}'               date_id,
--        7                       recent_days,
--        count(distinct user_id) order_continuously_user_count
-- from (select user_id,
--              datediff(lead(date_id, 2, '9999-12-31') over(partition by user_id order by date_id), date_id) diff
--       from trade_user_sku_order)
-- where diff = 2;