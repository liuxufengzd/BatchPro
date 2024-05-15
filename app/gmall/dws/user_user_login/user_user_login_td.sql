result
=
SELECT user_id,
       min(login_time_first) login_time_first,
       max(login_time_last)  login_time_last,
       sum(login_count_td)   login_count_td,
       "${date}"             date_id
FROM (SELECT user_id,
             min(login_time) login_time_first,
             max(login_time) login_time_last,
             count(*)        login_count_td
      FROM user_login_inc
      GROUP BY user_id
      UNION ALL
      SELECT user_id,
             login_time_first,
             login_time_last,
             login_count_td
      FROM user_user_login_td)
GROUP BY date_id, user_id