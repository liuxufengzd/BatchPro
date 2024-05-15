result
=
SELECT p.id,
       name,
       region_id,
       region_name,
       area_code,
       iso_code,
       iso_3166_2
FROM base_province_full AS p
         LEFT JOIN base_region_full AS r ON p.region_id = r.id;
