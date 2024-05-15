result
=
SELECT sku_id,
       sku_name,
       tm_id,
       tm_name,
       favor_count_1d favor_count,
       rank()         over(partition by sku_id order by favor_count_1d desc) rk,
       '${date}'      date_id
FROM interaction_sku_favor_add_1d;

result
=
SELECT *
FROM result
WHERE rk <= 3;
