user_user_login_td
=
SELECT date_format(login_time_first, 'yyyy-MM-dd') login_date_first,
       date_format(login_time_last, 'yyyy-MM-dd')  login_date_last
FROM user_user_login_td;

result
=
SELECT recent_days,
       count_if(login_date_first > date_sub('${date}', recent_days)) new_user_count,
       count(*)                                                      active_user_count,
       '${date}'                                                     date_id
FROM user_user_login_td lateral view explode(array(1,7,30)) tmp as recent_days
WHERE login_date_last > date_sub('${date}', recent_days)
GROUP BY recent_days
