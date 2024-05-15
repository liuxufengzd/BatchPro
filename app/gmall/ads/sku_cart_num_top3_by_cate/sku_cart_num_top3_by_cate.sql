result
=
SELECT sku_id,
       sku_name,
       sum(sku_num) cart_num
FROM trade_cart_full
GROUP BY sku_id, sku_name;

result
=
SELECT '${date}' date_id,
       sku_id,
       sku_name,
       category1_id,
       category1_name,
       category2_id,
       category2_name,
       category3_id,
       category3_name,
       cart_num,
       rank()    over(partition by category1_id, category2_id, category3_id order by cart_num desc) rk
FROM result a
         LEFT JOIN sku_full b ON a.sku_id = b.id;

result
=
SELECT *
FROM result
WHERE rk <= 3;
