-- funnel chart should be more complex: result_N should contain result_N+1. Here is just a mock
result_1
=
SELECT count_if(page_id = 'home')        home_count,
       count_if(page_id = 'good_detail') good_detail_count
FROM traffic_visitor_page_view_1d
WHERE page_id in ('home', 'good_detail');

result_2
=
SELECT count(user_id) cart_count
FROM trade_user_cart_add_1d;

result_3
=
SELECT count(user_id) order_count
FROM trade_user_sku_order_1d;

result_4
=
SELECT count(user_id) payment_count
FROM trade_user_payment_1d;

result
=
SELECT *, '${date}' date_id
FROM result_1
         CROSS JOIN result_2
         CROSS JOIN result_3
         CROSS JOIN result_4;