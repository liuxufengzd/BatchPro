result
=
SELECT id,
       activity_name,
       activity_type,
       activity_type_name,
       activity_desc,
       start_time,
       end_time,
       get_activity_benefit_rule(activity_type, condition_amount, benefit_amount, condition_num, benefit_discount) benefit_rule,
       activity_id,
       condition_amount,
       condition_num,
       benefit_amount,
       benefit_discount,
       benefit_level
FROM activity_info_full AS act
         LEFT JOIN activity_rule_full AS rule ON act.id = rule.activity_id
         LEFT JOIN (SELECT dic_code, dic_name AS activity_type_name
                    FROM base_dic_full
                    WHERE parent_code = '31') AS dic ON act.activity_type = dic.dic_code;