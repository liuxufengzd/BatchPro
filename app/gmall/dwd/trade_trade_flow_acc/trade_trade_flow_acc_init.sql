result
=
SELECT oi.order_id,
       user_id,
       province_id,
       order_time,
       payment_time,
       finish_time,
       date_format(order_time, 'yyyy-MM-dd')                     order_date_id,
       date_format(payment_time, 'yyyy-MM-dd')                   payment_date_id,
       nvl(date_format(finish_time, 'yyyy-MM-dd'), '9999-12-31') finish_date_id,
       nvl(order_original_amount, 0)                             order_original_amount,
       nvl(order_activity_amount, 0)                             order_activity_amount,
       nvl(order_coupon_amount, 0)                               order_coupon_amount,
       nvl(order_total_amount, 0)                                order_total_amount,
       nvl(payment_amount, 0)                                    payment_amount
FROM (
         (SELECT data.id                     order_id,
                 data.user_id,
                 data.province_id,
                 data.create_time            order_time,
                 data.original_total_amount  order_original_amount,
                 data.activity_reduce_amount order_activity_amount,
                 data.coupon_reduce_amount   order_coupon_amount,
                 data.total_amount           order_total_amount
          FROM order_info_inc
          WHERE type = 'bootstrap-insert') oi
             LEFT JOIN (SELECT data.order_id, data.callback_time payment_time, data.total_amount payment_amount
                        FROM payment_info_inc
                        WHERE data.payment_status = '1602'
                          AND type = 'bootstrap-insert') pay ON oi.order_id = pay.order_id
             LEFT JOIN (SELECT data.order_id, data.create_time finish_time
                        FROM order_status_log_inc
                        WHERE data.order_status = '1004'
                          AND type = 'bootstrap-insert') os
         ON oi.order_id = os.order_id
         )