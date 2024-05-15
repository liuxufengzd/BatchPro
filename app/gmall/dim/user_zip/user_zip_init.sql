result
=
SELECT data.id,
       encode_name(data.name)              name,
       encode_phone_number(data.phone_num) phone_num,
       encode_email(data.email)            email,
       data.user_level,
       data.birthday,
       data.gender,
       data.create_time,
       data.operate_time,
       "2022-06-08"                        start_date,
       "9999-12-31"                        end_date
FROM user_info_inc
WHERE type = 'bootstrap-insert'