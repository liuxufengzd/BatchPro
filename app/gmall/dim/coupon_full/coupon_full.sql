result
=
SELECT id,
       coupon_name,
       coupon_type,
       coupon_type_name,
       condition_amount,
       condition_num,
       activity_id,
       benefit_amount,
       benefit_discount,
       get_coupon_benefit_rule(coupon_type, condition_amount, benefit_amount, condition_num, benefit_discount) benefit_rule,
       limit_num,
       taken_count,
       start_time,
       end_time,
       create_time,
       operate_time,
       expire_time,
       range_type,
       range_type_name,
       range_desc
FROM coupon_info_full AS coupon
         LEFT JOIN (SELECT dic_code, dic_name AS coupon_type_name
                    FROM base_dic_full
                    WHERE parent_code = '32') AS dic1 ON coupon.coupon_type = dic1.dic_code
         LEFT JOIN (SELECT dic_code, dic_name AS range_type_name
                    FROM base_dic_full
                    WHERE parent_code = '33') AS dic2 ON coupon.range_type = dic2.dic_code;