#!/bin/bash

names=("interaction_favor_add_inc" "tool_coupon_used_inc" "trade_cart_add_inc" "trade_order_detail_inc" "trade_pay_detail_suc_inc" "trade_trade_flow_acc" "user_register_inc")
for name in "${names[@]}"; do
    spark-submit ../../resource/transform.py -c ../../app/gmall/dwd/"${name}"/"${name}"_init.json -s ../../app/gmall/dwd/"${name}"/"${name}"_init.sql -f ../../resource/udf/udf.py
done

names=("trade_cart_full" "traffic_page_view_inc" "user_login_inc")
for name in "${names[@]}"; do
    spark-submit ../../resource/transform.py -c ../../app/gmall/dwd/"${name}"/"${name}".json -s ../../app/gmall/dwd/"${name}"/"${name}".sql -f ../../resource/udf/udf.py -t 2022-06-08
done

names=("interaction_favor_add_inc" "tool_coupon_used_inc" "trade_cart_add_inc" "trade_order_detail_inc" "trade_pay_detail_suc_inc" "trade_trade_flow_acc" "user_register_inc" "trade_cart_full" "traffic_page_view_inc" "user_login_inc")
for name in "${names[@]}"; do
    spark-submit ../../resource/transform.py -c ../../app/gmall/dwd/"${name}"/"${name}".json -s ../../app/gmall/dwd/"${name}"/"${name}".sql -f ../../resource/udf/udf.py -t 2022-06-09
done
