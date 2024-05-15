#!/bin/bash

#names=("interaction_sku_favor_add" "tool_user_coupon_used" "trade_province_order" "trade_user_cart_add" "trade_user_payment" "trade_user_sku_order" "traffic_session_page_view" "traffic_visitor_page_view")
#for name in "${names[@]}"; do
#    spark-submit ../../resource/transform.py -c ../../app/gmall/dws/"${name}"/"${name}"_1d.json -s ../../app/gmall/dws/"${name}"/"${name}"_1d.sql -f ../../resource/udf/udf.py -t 2022-06-08
#    spark-submit ../../resource/transform.py -c ../../app/gmall/dws/"${name}"/"${name}"_1d.json -s ../../app/gmall/dws/"${name}"/"${name}"_1d.sql -f ../../resource/udf/udf.py -t 2022-06-09
#done

names=("trade_province_order" "trade_user_sku_order")
for name in "${names[@]}"; do
    spark-submit ../../resource/transform.py -c ../../app/gmall/dws/"${name}"/"${name}"_nd.json -s ../../app/gmall/dws/"${name}"/"${name}"_nd.sql -f ../../resource/udf/udf.py -t 2022-06-08
#    spark-submit ../../resource/transform.py -c ../../app/gmall/dws/"${name}"/"${name}"_nd.json -s ../../app/gmall/dws/"${name}"/"${name}"_nd.sql -f ../../resource/udf/udf.py -t 2022-06-09
done

#names=("trade_user_order" "user_user_login")
#for name in "${names[@]}"; do
#    spark-submit ../../resource/transform.py -c ../../app/gmall/dws/"${name}"/"${name}"_td_init.json -s ../../app/gmall/dws/"${name}"/"${name}"_td_init.sql -f ../../resource/udf/udf.py
#done
#
#names=("trade_user_order" "user_user_login")
#for name in "${names[@]}"; do
#    spark-submit ../../resource/transform.py -c ../../app/gmall/dws/"${name}"/"${name}"_td.json -s ../../app/gmall/dws/"${name}"/"${name}"_td.sql -f ../../resource/udf/udf.py -t 2022-06-09
#done
