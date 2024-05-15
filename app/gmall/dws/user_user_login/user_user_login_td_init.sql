-- user_zip is used to complement login_time_first (seen as register time)
-- we can tolerate data loss of login_time_last and login_count_td for losing log data
result
=
SELECT user_id,
       min(login_time_first) login_time_first,
       max(login_time_last)  login_time_last,
       sum(login_count_td)   login_count_td,
       "2022-06-08"          date_id
FROM (SELECT user_id,
             min(login_time) login_time_first,
             max(login_time) login_time_last,
             count(*)        login_count_td
      FROM user_login_inc a
      GROUP BY user_id
      UNION ALL
      SELECT id          user_id,
             create_time login_time_first,
             create_time login_time_last,
             1           login_count_td
      FROM user_zip
      WHERE date_format(create_time, 'yyyy-MM-dd') < '2022-06-08')
GROUP BY date_id, user_id