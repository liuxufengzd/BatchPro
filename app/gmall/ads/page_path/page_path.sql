-- 1. we don't care last_page = null, but care when exit.
-- 2. Sankey chart does not permit circle. So we add index to each page.
result
=
SELECT concat('step-', rn, ':', source)     source,
       concat('step-', rn + 1, ':', target) target
FROM (SELECT page_id source,
             lead(page_id, 1, 'out') OVER(PARTITION BY session_id ORDER BY view_time) target,
             row_number() OVER(PARTITION BY session_id ORDER BY view_time) rn
      FROM traffic_page_view_inc);

result
=
SELECT source,
       target,
       count(*)  path_count,
       '${date}' date_id
FROM result
GROUP BY source, target
