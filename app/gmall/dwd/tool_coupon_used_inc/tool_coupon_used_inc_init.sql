result
=
SELECT data.coupon_id,
       data.user_id,
       data.order_id,
       data.used_time,
       date_format(data.used_time, 'yyyy-MM-dd') date_id
FROM coupon_use_inc
WHERE type = 'bootstrap-insert'
  AND data.coupon_status = '1403'