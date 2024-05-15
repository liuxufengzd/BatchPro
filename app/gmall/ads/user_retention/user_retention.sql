user_user_login_td
=
SELECT date_format(login_time_first, 'yyyy-MM-dd') login_date_first,
       date_format(login_time_last, 'yyyy-MM-dd')  login_date_last
FROM user_user_login_td;

user_user_login_td
=
SELECT login_date_first                      create_date,
       count_if(login_date_last = '${date}') retention_count,
       count(*)                              new_user_count
FROM user_user_login_td
WHERE login_date_first >= date_sub('${date}', 7)
  AND login_date_first < '${date}'
GROUP BY login_date_first;

result
=
SELECT '${date}'                                                      date_id,
       create_date,
       datediff('${date}', create_date)                               retention_day,
       retention_count,
       new_user_count,
       cast(retention_count / new_user_count * 100 as decimal(16, 2)) retention_rate
FROM user_user_login_td;
