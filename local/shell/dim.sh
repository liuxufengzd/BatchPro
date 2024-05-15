#!/bin/bash

spark-submit ../../resource/transform.py -c ../../app/gmall/dim/user_zip/user_zip_init.json -s ../../app/gmall/dim/user_zip/user_zip_init.sql -f ../../resource/udf/udf.py

names=("activity_full" "coupon_full" "promotion_pos_full" "promotion_refer_full" "province_full" "sku_full")
for name in "${names[@]}"; do
    spark-submit ../../resource/transform.py -c ../../app/gmall/dim/"${name}"/"${name}".json -s ../../app/gmall/dim/"${name}"/"${name}".sql -f ../../resource/udf/udf.py -t 2022-06-08
    spark-submit ../../resource/transform.py -c ../../app/gmall/dim/"${name}"/"${name}".json -s ../../app/gmall/dim/"${name}"/"${name}".sql -f ../../resource/udf/udf.py -t 2022-06-09
done

spark-submit ../../resource/transform.py -c ../../app/gmall/dim/user_zip/user_zip.json -s ../../app/gmall/dim/user_zip/user_zip.sql -f ../../resource/udf/udf.py -t 2022-06-09