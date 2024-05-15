user_info_inc
=
SELECT id,
       name,
       phone_num,
       email,
       user_level,
       birthday,
       gender,
       create_time,
       operate_time,
       "${date}"    start_date,
       "9999-12-31" end_date
FROM (SELECT data.id,
             encode_name(data.name)              name,
             encode_phone_number(data.phone_num) phone_num,
             encode_email(data.email)            email,
             data.user_level,
             data.birthday,
             data.gender,
             data.create_time,
             data.operate_time,
             row_number()                        OVER(PARTITION BY data.id ORDER BY ts DESC) rn
      FROM user_info_inc)
WHERE rn = 1;

user_zip
=
SELECT *,
       row_number() OVER(PARTITION BY id ORDER BY start_date DESC) rn
FROM ((SELECT id,
              name,
              phone_num,
              email,
              user_level,
              birthday,
              gender,
              create_time,
              operate_time,
              start_date,
              end_date
       FROM user_zip)
      UNION ALL
      (SELECT id,
              name,
              phone_num,
              email,
              user_level,
              birthday,
              gender,
              create_time,
              operate_time,
              start_date,
              end_date
       FROM user_info_inc));

result
=
SELECT id,
       name,
       phone_num,
       email,
       user_level,
       birthday,
       gender,
       create_time,
       operate_time,
       start_date,
       if(rn = 1, "9999-12-31", date_sub("${date}", 1)) end_date
FROM user_zip;