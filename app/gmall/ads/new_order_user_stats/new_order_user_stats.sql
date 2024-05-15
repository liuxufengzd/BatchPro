result
=
SELECT sum(if(order_date_first >= "${date}", 1, 0))               user_count_1d,
       sum(if(order_date_first >= date_sub("${date}", 6), 1, 0))  user_count_7d,
       sum(if(order_date_first >= date_sub("${date}", 9), 1, 0))  user_count_10d,
       sum(if(order_date_first >= date_sub("${date}", 29), 1, 0)) user_count_30d,
       "${date}"                                                  date_id
FROM trade_user_order_td
