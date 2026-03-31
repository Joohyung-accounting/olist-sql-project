-- Review score distribution
SELECT
    review_score,
    COUNT(*) AS num_reviews,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM order_reviews), 2) AS pct
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

-- Delivery delay vs review score
WITH delivery_info AS (
    SELECT
        o.order_id,
        julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date) AS delay,
        r.review_score
    FROM orders o
    JOIN order_reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
)

SELECT
    CASE
        WHEN delay <= 0 THEN 'On Time'
        WHEN delay <= 3 THEN 'Slight Delay'
        ELSE 'Late'
    END AS delivery_status,
    ROUND(AVG(review_score), 2) AS avg_review,
    COUNT(*) AS num_orders
FROM delivery_info
GROUP BY delivery_status;

-- Category satisfaction
SELECT
    p.product_category_name,
    COUNT(*) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review
FROM order_items oi
JOIN order_reviews r ON oi.order_id = r.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
HAVING COUNT(*) > 100
ORDER BY avg_review ASC
LIMIT 10;

-- Payment Method vs Review
SELECT
    op.payment_type,
    ROUND(AVG(r.review_score), 2) AS avg_review,
    COUNT(*) AS num_orders
FROM order_payments op
JOIN order_reviews r ON op.order_id = r.order_id
GROUP BY op.payment_type;

-- Geographic satisfaction
SELECT
    c.customer_state,
    ROUND(AVG(r.review_score), 2) AS avg_review,
    COUNT(*) AS num_reviews
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_reviews r ON o.order_id = r.order_id
GROUP BY c.customer_state
HAVING COUNT(*) > 50
ORDER BY avg_review DESC;

-- Low review root cause
SELECT
    CASE
        WHEN julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date) > 0 THEN 'Delayed'
        ELSE 'On Time'
    END AS delivery_status,
    COUNT(*) AS low_reviews
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE r.review_score <= 2
GROUP BY delivery_status;

-- Price vs review 
SELECT
    CASE
        WHEN o.order_total < 50 THEN 'Low'
        WHEN o.order_total < 150 THEN 'Medium'
        ELSE 'High'
    END AS price_range,
    ROUND(AVG(r.review_score), 2) AS avg_review
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
GROUP BY price_range;