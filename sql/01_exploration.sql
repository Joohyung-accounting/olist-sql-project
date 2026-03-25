-- 1. Checking Table lists
SELECT name
FROM sqlite_master
WHERE type = 'table';

-- 2. Counting rows from each table
SELECT 'customer_id', COUNT(*) FROM customers
UNION ALL
SELECT 'geolocation_zip_code_prefix', COUNT(*) FROM geolocation
UNION ALL
SELECT 'mql_id', COUNT(*) FROM leads_closed
UNION ALL
SELECT 'mql_id', COUNT(*) FROM leads_qualified
UNION ALL
SELECT 'order_id', COUNT(*) FROM order_items
UNION ALL
SELECT 'order_id', COUNT(*) FROM order_payments
UNION ALL
SELECT 'review_id', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'order_id', COUNT(*) FROM orders
UNION ALL
SELECT 'product_category_name', COUNT(*) FROM product_category_name_translation
UNION ALL
SELECT 'product_id', COUNT(*) FROM products
UNION ALL
SELECT 'seller_id', COUNT(*) FROM sellers;

-- 3. Checking NULL values
SELECT 
    COUNT(*) AS total_rows, 
    COUNT(order_delivered_customer_date) AS delivered_not_null
FROM orders;

-- 4. Distribution of order_status
SELECT order_status, COUNT(*) AS count
FROM orders
GROUP BY order_status
ORDER BY count;

-- 5. Distribution of review_score
SELECT review_score, COUNT(*) AS count
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

-- 6. Distribution of payment_method
SELECT payment_type, COUNT(*) AS count
FROM order_payments
GROUP BY payment_type;

-- 7. Checking the date range
SELECT 
    MIN(order_purchase_timestamp) AS start_date,
    MAX(order_purchase_timestamp) AS end_date
FROM orders;

-- 8. Basic JOIN test
SELECT 
    o.order_id,
    r.review_score
FROM orders o
JOIN order_reviews r 
ON o.order_id = r.order_id
LIMIT 10;
