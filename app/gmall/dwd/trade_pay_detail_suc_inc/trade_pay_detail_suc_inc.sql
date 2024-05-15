result
=
SELECT pi.id,
       pi.order_id,
       user_id,
       sku_id,
       sku_num,
       province_id,
       activity_id,
       activity_rule_id,
       coupon_id,
       payment_type                             payment_type_code,
       dic_name                                 payment_type_name,
       callback_time,
       split_original_amount,
       nvl(split_activity_amount, 0)            split_activity_amount,
       nvl(split_coupon_amount, 0)              split_coupon_amount,
       split_payment_amount,
       date_format(callback_time, 'yyyy-MM-dd') date_id
FROM (
         (SELECT data.id,
                 data.order_id,
                 data.user_id,
                 data.payment_type,
                 data.total_amount split_payment_amount,
                 data.callback_time
          FROM payment_info_inc
          WHERE type = 'update'
            AND old['payment_status'] is not null
            AND data.payment_status = '1602') pi
             LEFT JOIN (SELECT data.order_id,
                               data.sku_id,
                               data.sku_name,
                               data.sku_num,
                               data.order_price * data.sku_num split_original_amount,
                               data.split_total_amount,
                               data.split_activity_amount,
                               data.split_coupon_amount
                        FROM order_detail_inc
                        WHERE type = 'insert'
                           OR type = 'bootstrap-insert') od ON pi.order_id = od.order_id
             LEFT JOIN (SELECT data.id, data.province_id
                        FROM order_info_inc
                        WHERE type = 'insert') oi ON pi.order_id = oi.id
             LEFT JOIN (SELECT data.order_id,
                               data.activity_id,
                               data.activity_rule_id
                        FROM order_detail_activity_inc
                        WHERE type = 'insert'
                           OR type = 'bootstrap-insert') oda ON pi.order_id = oda.order_id
             LEFT JOIN (SELECT data.order_id, data.coupon_id
                        FROM order_detail_coupon_inc
                        WHERE type = 'insert'
                           OR type = 'bootstrap-insert') odc ON pi.order_id = odc.order_id
             LEFT JOIN (SELECT dic_code, dic_name
                        FROM base_dic_full
                        WHERE parent_code = '11') dic ON pi.payment_type = dic.dic_code
         )
