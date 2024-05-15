result
=
SELECT sku.id   id,
       sku_name name,
       sku_desc description,
       weight,
       is_sale,
       price,
       spu_id,
       spu_name,
       tm_id,
       tm_name,
       c1.name  category1_id,
       c1.name  category1_name,
       c2.id    category2_id,
       c2.name  category2_name,
       c3.id    category3_id,
       c3.name  category3_name,
       attrs,
       sale_attrs,
       create_time
FROM sku_info_full AS sku
         LEFT JOIN spu_info_full AS spu
                   ON sku.spu_id = spu.id
         LEFT JOIN base_trademark_full AS tm ON sku.tm_id = tm.id
         LEFT JOIN base_category3_full AS c3 ON sku.category3_id = c3.id
         LEFT JOIN base_category2_full AS c2 ON c3.category2_id = c2.id
         LEFT JOIN base_category1_full AS c1 ON c2.category1_id = c1.id
         LEFT JOIN (SELECT sku_id,
                           collect_list(named_struct('attr_id', attr_id, 'attr_name', attr_name, 'value_id', value_id,
                                                     'value_name', value_name)) attrs
                    FROM sku_attr_value_full
                    GROUP BY sku_id) AS a1 ON sku.id = a1.sku_id
         LEFT JOIN (SELECT sku_id,
                           collect_list(named_struct('sale_attr_value_id', sale_attr_value_id, 'sale_attr_value_name',
                                                     sale_attr_value_name, 'sale_attr_id', sale_attr_id,
                                                     'sale_attr_name', sale_attr_name)) sale_attrs
                    FROM sku_sale_attr_value_full
                    GROUP BY sku_id) AS a2 ON sku.id = a2.sku_id;