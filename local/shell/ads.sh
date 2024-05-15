#!/bin/bash

names=("coupon_stats" "new_order_user_stats" "order_by_province" "order_continuously_user_count" "order_stats_by_tm" "order_to_pay_interval_avg" "page_path" "repeat_purchase_by_tm" "sku_cart_num_top3_by_cate" "sku_favor_count_top3_by_tm" "traffic_stats_by_channel" "user_action" "user_change" "user_retention" "user_stats")
for name in "${names[@]}"; do
    spark-submit ../../resource/transform.py -c ../../app/gmall/ads/"${name}"/"${name}".json -s ../../app/gmall/ads/"${name}"/"${name}".sql -f ../../resource/udf/udf.py -t 2022-06-08
    spark-submit ../../resource/transform.py -c ../../app/gmall/ads/"${name}"/"${name}".json -s ../../app/gmall/ads/"${name}"/"${name}".sql -f ../../resource/udf/udf.py -t 2022-06-09
done
