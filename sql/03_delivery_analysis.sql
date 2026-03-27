-- 1. Check delivery-related date completeness
SELECT
    COUNT(*) AS total_orders,
    COUNT(order_delivered_customer_date) AS delivered_orders,
    COUNT(order_estimated_delivery_date) AS estimated_delivery_available,
    COUNT(order_delivered_carrier_date) AS carrier_date_available
FROM orders;

-- 2. Actual delivery time (purchase to customer delivery)
SELECT
    ROUND(AVG(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)), 2) AS avg_delivery_days,
    ROUND(MIN(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)), 2) AS min_delivery_days,
    ROUND(MAX(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)), 2) AS max_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- 3. Monthly average delivery time
SELECT
    strftime('%Y-%m', order_purchase_timestamp) AS order_month,
    COUNT(*) AS delivered_orders,
    ROUND(AVG(julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp)), 2) AS avg_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY order_month
ORDER BY order_month;

-- 4. On-time vs delayed delivery
SELECT
    CASE
        WHEN julianday(order_delivered_customer_date) <= julianday(order_estimated_delivery_date) THEN 'On Time'
        ELSE 'Delayed'
    END AS delivery_status,
    COUNT(*) AS total_orders,
    ROUND(100.0 * COUNT(*) / (
        SELECT COUNT(*)
        FROM orders
        WHERE order_delivered_customer_date IS NOT NULL
          AND order_estimated_delivery_date IS NOT NULL
    ), 2) AS pct_of_delivered_orders
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_status;

-- 5. Average delay days relative to estimated delivery date
SELECT
    ROUND(AVG(julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date)), 2) AS avg_delay_days,
    ROUND(MIN(julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date)), 2) AS min_delay_days,
    ROUND(MAX(julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date)), 2) AS max_delay_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;

-- 6. Monthly delivery delay rate
WITH delivered_orders AS (
    SELECT
        strftime('%Y-%m', order_purchase_timestamp) AS order_month,
        CASE
            WHEN julianday(order_delivered_customer_date) > julianday(order_estimated_delivery_date) THEN 1
            ELSE 0
        END AS is_delayed
    FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
      AND order_estimated_delivery_date IS NOT NULL
)
SELECT
    order_month,
    COUNT(*) AS delivered_orders,
    SUM(is_delayed) AS delayed_orders,
    ROUND(100.0 * SUM(is_delayed) / COUNT(*), 2) AS delay_rate
FROM delivered_orders
GROUP BY order_month
ORDER BY order_month;

-- 7. Delivery time bucket distribution
WITH delivery_times AS (
    SELECT
        julianday(order_delivered_customer_date) - julianday(order_purchase_timestamp) AS delivery_days
    FROM orders
    WHERE order_delivered_customer_date IS NOT NULL
)
SELECT
    CASE
        WHEN delivery_days < 5 THEN '< 5 days'
        WHEN delivery_days < 10 THEN '5-9 days'
        WHEN delivery_days < 15 THEN '10-14 days'
        WHEN delivery_days < 20 THEN '15-19 days'
        ELSE '20+ days'
    END AS delivery_bucket,
    COUNT(*) AS total_orders
FROM delivery_times
GROUP BY delivery_bucket
ORDER BY total_orders DESC;