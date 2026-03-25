-- 1.Monthly order volume
SELECT
	strftime('%Y-%m', order_purchase_timestamp) AS order_month,
	COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- 2.Monthly order status distribution
SELECT
    strftime('%Y-%m', order_purchase_timestamp) AS order_month,
    order_status,
    COUNT(*) AS count
FROM orders
GROUP BY order_month, order_status
ORDER BY order_month, order_status;

-- 3.Overall order status distribution
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) AS pct_of_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 4.Monthly revenue trend
SELECT
    strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM orders o
JOIN order_payments p
    ON o.order_id = p.order_id
GROUP BY order_month
ORDER BY order_month;

-- 5.Average order value
WITH order_value AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment
    FROM order_payments
    GROUP BY order_id
)
SELECT
    ROUND(AVG(total_payment), 2) AS avg_order_value,
    ROUND(MIN(total_payment), 2) AS min_order_value,
    ROUND(MAX(total_payment), 2) AS max_order_value
FROM order_value;

-- 6.Monthly average order value
WITH order_value AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment
    FROM order_payments
    GROUP BY order_id
)
SELECT
    strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
    ROUND(AVG(ov.total_payment), 2) AS avg_order_value,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_value ov
    ON o.order_id = ov.order_id
GROUP BY order_month
ORDER BY order_month;

-- 7.Number of items per order
SELECT
    ROUND(AVG(item_count), 2) AS avg_items_per_order,
    MIN(item_count) AS min_items_per_order,
    MAX(item_count) AS max_items_per_order
FROM (
    SELECT
        order_id,
        COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
);

-- 8.Canceled orders by month
SELECT
    strftime('%Y-%m', order_purchase_timestamp) AS order_month,
    COUNT(*) AS canceled_orders
FROM orders
WHERE order_status = 'canceled'
GROUP BY order_month
ORDER BY order_month;

-- Cancellation rate by month
WITH monthly_orders AS (
    SELECT
        strftime('%Y-%m', order_purchase_timestamp) AS order_month,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY order_month
),
monthly_canceled AS (
    SELECT
        strftime('%Y-%m', order_purchase_timestamp) AS order_month,
        COUNT(*) AS canceled_orders
    FROM orders
    WHERE order_status = 'canceled'
    GROUP BY order_month
)
SELECT
    mo.order_month,
    mo.total_orders,
    COALESCE(mc.canceled_orders, 0) AS canceled_orders,
    ROUND(100.0 * COALESCE(mc.canceled_orders, 0) / mo.total_orders, 2) AS cancellation_rate
FROM monthly_orders mo
LEFT JOIN monthly_canceled mc
    ON mo.order_month = mc.order_month
ORDER BY mo.order_month;
