churn_count
=
SELECT count(user_id) user_churn_count
FROM user_login
WHERE login_time_last = date_sub('${date}', 7);

back_count
=
SELECT count(a.user_id) user_back_count
FROM (SELECT *
      FROM user_login
      WHERE login_time_last = '${date}') a
         JOIN
     (SELECT *
      FROM user_login_pre
      WHERE login_time_last <= date_sub('${date}', 7)) b ON a.user_id = b.user_id;

result
=
SELECT *, "${date}" date_id
FROM churn_count
         CROSS JOIN back_count;

