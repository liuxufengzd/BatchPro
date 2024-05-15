result
=
SELECT oi.order_id,
       user_id,
       province_id,
       order_time,
       nvl(oi.payment_time, pay.payment_time)                                            payment_time,
       nvl(oi.finish_time, os.finish_time)                                               finish_time,
       order_date_id,
       date_format(nvl(oi.payment_time, pay.payment_time), 'yyyy-MM-dd')                 payment_date_id,
       nvl(date_format(nvl(oi.finish_time, os.finish_time), 'yyyy-MM-dd'), '9999-12-31') finish_date_id,
       nvl(order_original_amount, 0)                                                     order_original_amount,
       nvl(order_activity_amount, 0)                                                     order_activity_amount,
       nvl(order_coupon_amount, 0)                                                       order_coupon_amount,
       nvl(order_total_amount, 0)                                                         order_total_amount,
       nvl(oi.payment_amount, pay.payment_amount)                                        payment_amount
FROM (
         (SELECT order_id,
                 user_id,
                 province_id,
                 order_time,
                 order_date_id,
                 payment_time,
                 finish_time,
                 payment_date_id,
                 finish_date_id,
                 order_original_amount,
                 order_activity_amount,
                 order_coupon_amount,
                 order_total_amount,
                 payment_amount
          FROM trade_trade_flow_acc
          UNION ALL
          SELECT data.id                                     order_id,
                 data.user_id,
                 data.province_id,
                 data.create_time                            order_time,
                 date_format(data.create_time, 'yyyy-MM-dd') order_date_id,
                 null,
                 null,
                 null,
                 null,
                 data.original_total_amount                  order_original_amount,
                 data.activity_reduce_amount                 order_activity_amount,
                 data.coupon_reduce_amount                   order_coupon_amount,
                 data.total_amount                           order_total_amount,
                 null
          FROM order_info_inc
          WHERE type = 'insert') oi
             LEFT JOIN (SELECT data.order_id, data.callback_time payment_time, data.total_amount payment_amount
                        FROM payment_info_inc
                        WHERE type = 'update'
                          AND old['payment_status'] is not null AND data.payment_status = '1602') pay ON oi.order_id = pay.order_id
             LEFT JOIN (SELECT data.order_id, data.create_time finish_time
                        FROM order_status_log_inc
                        WHERE type = 'insert'
                          AND data.order_status = '1004') os
         ON oi.order_id = os.order_id
         )