result
=
SELECT od.id,
       order_id,
       sku_id,
       sku_name,
       user_id,
       province_id,
       activity_id,
       activity_rule_id,
       coupon_id,
       sku_num,
       order_price,
       sku_num * order_price                  split_original_amount,
       nvl(split_activity_amount, 0)          split_activity_amount,
       nvl(split_coupon_amount, 0)            split_coupon_amount,
       nvl(split_total_amount, 0)             split_total_amount,
       create_time,
       date_format(create_time, 'yyyy-MM-dd') date_id
FROM (
         (SELECT data.id,
                 data.order_id,
                 data.sku_id,
                 data.sku_name,
                 data.order_price,
                 data.sku_num,
                 data.split_total_amount,
                 data.split_activity_amount,
                 data.split_coupon_amount,
                 data.create_time
          FROM order_detail_inc
          WHERE type = 'insert') od
             LEFT JOIN (SELECT data.user_id, data.province_id, data.id
                        FROM order_info_inc
                        WHERE type = 'insert') oi ON od.order_id = oi.id
             LEFT JOIN (SELECT data.activity_id, data.activity_rule_id, data.order_detail_id
                        FROM order_detail_activity_inc
                        WHERE type = 'insert') oda ON od.id = oda.order_detail_id
             LEFT JOIN (SELECT data.coupon_id, data.order_detail_id
                        FROM order_detail_coupon_inc
                        WHERE type = 'insert') odc
         ON od.id = odc.order_detail_id
         )