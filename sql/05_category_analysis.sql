-- =========================================================
-- 03_category_analysis.sql
-- Olist E-commerce SQL Analytics
-- Goal: Analyze product categories by sales and customer satisfaction
-- =========================================================

-- ---------------------------------------------------------
-- 1. Category-level sales and review summary
-- Shows:
-- - total orders
-- - total revenue
-- - average review score
-- - average item price
-- ---------------------------------------------------------
WITH category_base AS (
    SELECT
        p.product_category_name AS category,
        oi.order_id,
        oi.price,
        r.review_score
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    LEFT JOIN order_reviews r
        ON oi.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND p.product_category_name IS NOT NULL
)
SELECT
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(price), 2) AS total_revenue,
    ROUND(AVG(price), 2) AS avg_item_price,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM category_base
GROUP BY category
ORDER BY total_revenue DESC;


-- ---------------------------------------------------------
-- 2. Top 10 categories by revenue
-- ---------------------------------------------------------
SELECT
    p.product_category_name AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;


-- ---------------------------------------------------------
-- 3. Lowest-rated categories
-- Only includes categories with at least 30 delivered orders
-- so tiny categories do not distort the result
-- ---------------------------------------------------------
SELECT
    p.product_category_name AS category,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
LEFT JOIN order_reviews r
    ON oi.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
HAVING COUNT(DISTINCT oi.order_id) >= 30
ORDER BY avg_review_score ASC, total_orders DESC
LIMIT 10;


-- ---------------------------------------------------------
-- 4. High-revenue but low-satisfaction categories
-- Useful for identifying problem categories that matter most
-- ---------------------------------------------------------
WITH category_summary AS (
    SELECT
        p.product_category_name AS category,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        ROUND(SUM(oi.price), 2) AS total_revenue,
        ROUND(AVG(r.review_score), 2) AS avg_review_score
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    LEFT JOIN order_reviews r
        ON oi.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND p.product_category_name IS NOT NULL
    GROUP BY p.product_category_name
)
SELECT
    category,
    total_orders,
    total_revenue,
    avg_review_score
FROM category_summary
WHERE total_orders >= 30
  AND avg_review_score < 4.0
ORDER BY total_revenue DESC, avg_review_score ASC;


-- ---------------------------------------------------------
-- 5. Category review distribution
-- Shows how many reviews of each score each category receives
-- ---------------------------------------------------------
SELECT
    p.product_category_name AS category,
    r.review_score,
    COUNT(*) AS review_count
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
JOIN order_reviews r
    ON oi.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY p.product_category_name, r.review_score
ORDER BY category, r.review_score;


-- ---------------------------------------------------------
-- 6. Low-review rate by category
-- Defines low review as review_score <= 2
-- ---------------------------------------------------------
SELECT
    p.product_category_name AS category,
    COUNT(*) AS total_reviewed_orders,
    SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) AS low_review_orders,
    ROUND(
        100.0 * SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS low_review_rate_pct
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
JOIN order_reviews r
    ON oi.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
HAVING COUNT(*) >= 30
ORDER BY low_review_rate_pct DESC, total_reviewed_orders DESC;


-- ---------------------------------------------------------
-- 7. Delivery delay impact by category
-- Delay = delivered_customer_date > estimated_delivery_date
-- ---------------------------------------------------------
WITH category_delivery AS (
    SELECT
        p.product_category_name AS category,
        oi.order_id,
        CASE
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
            ELSE 0
        END AS is_delayed,
        r.review_score
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    LEFT JOIN order_reviews r
        ON oi.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND p.product_category_name IS NOT NULL
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
    category,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(100.0 * AVG(is_delayed), 2) AS delay_rate_pct,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM category_delivery
GROUP BY category
HAVING COUNT(DISTINCT order_id) >= 30
ORDER BY delay_rate_pct DESC, avg_review_score ASC;


-- ---------------------------------------------------------
-- 8. Best categories: high review + strong revenue
-- ---------------------------------------------------------
WITH category_summary AS (
    SELECT
        p.product_category_name AS category,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        ROUND(SUM(oi.price), 2) AS total_revenue,
        ROUND(AVG(r.review_score), 2) AS avg_review_score
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    JOIN orders o
        ON oi.order_id = o.order_id
    LEFT JOIN order_reviews r
        ON oi.order_id = r.order_id
    WHERE o.order_status = 'delivered'
      AND p.product_category_name IS NOT NULL
    GROUP BY p.product_category_name
)
SELECT
    category,
    total_orders,
    total_revenue,
    avg_review_score
FROM category_summary
WHERE total_orders >= 30
ORDER BY avg_review_score DESC, total_revenue DESC
LIMIT 10;