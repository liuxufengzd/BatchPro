interaction_favor_add_inc
=
SELECT user_id,
       sku_id,
       count(sku_id) favor_count_1d,
       date_id
FROM interaction_favor_add_inc
GROUP BY date_id, user_id, sku_id;

result
=
SELECT user_id,
       sku_id,
       name sku_name,
       tm_id,
       tm_name,
       category1_id,
       category2_id,
       category3_id,
       category1_name,
       category2_name,
       category3_name,
       favor_count_1d,
       date_id
FROM interaction_favor_add_inc a
         LEFT JOIN sku_full b ON a.sku_id = b.id
