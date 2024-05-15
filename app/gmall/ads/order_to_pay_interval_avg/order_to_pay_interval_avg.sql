result
=
SELECT avg(unix_timestamp(payment_time) - unix_timestamp(order_time)) order_to_pay_interval_avg,
       '${date}'                                                      date_id
FROM trade_trade_flow_acc
WHERE finish_date_id in ('${date}', '9999-12-31')
  and payment_date_id = '${date}';

