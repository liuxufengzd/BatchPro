result
=
SELECT *, "${date}" date_id
FROM (SELECT 1                        recent_days,
             province_id,
             province_name,
             area_code,
             iso_code,
             iso_3166_2,
             order_count_1d           order_count,
             order_original_amount_1d order_user_count
      FROM trade_province_order_1d
      UNION ALL
      SELECT 7                        recent_days,
             province_id,
             province_name,
             area_code,
             iso_code,
             iso_3166_2,
             order_count_7d           order_count,
             order_original_amount_7d order_user_count
      FROM trade_province_order_nd
      UNION ALL
      SELECT 30                        recent_days,
             province_id,
             province_name,
             area_code,
             iso_code,
             iso_3166_2,
             order_count_30d           order_count,
             order_original_amount_30d order_user_count
      FROM trade_province_order_nd)
