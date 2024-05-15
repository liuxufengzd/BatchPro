#!/bin/bash

spark-submit ../../resource/ods.py -c ../../app/gmall/ods/log/log_inc.json -t "$1"

names_inc=("order_refund_info_inc" "order_info_inc" "order_detail_inc" "order_detail_coupon_inc" "order_detail_activity_inc" "favor_info_inc" "coupon_use_inc" "comment_info_inc" "cart_info_inc" "order_status_log_inc" "payment_info_inc" "refund_payment_inc" "user_info_inc")
names_full=("activity_info_full" "activity_rule_full" "base_category1_full" "base_category2_full" "base_category3_full" "base_dic_full" "base_province_full" "base_region_full" "base_trademark_full" "cart_info_full" "coupon_info_full" "promotion_pos_full" "promotion_refer_full" "sku_attr_value_full" "sku_info_full" "sku_sale_attr_value_full" "spu_info_full")

for name in "${names_inc[@]}"; do
    python ../../resource/ods.py -c ../../app/gmall/ods/db/inc/"${name}".json -t "$1"
done

for name in "${names_full[@]}"; do
    python ../../resource/ods.py -c ../../app/gmall/ods/db/full/"${name}".json -t "$1"
done
