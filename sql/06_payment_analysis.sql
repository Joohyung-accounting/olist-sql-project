--payment summary
WITH payment_summary AS (
    SELECT
        order_id,
        COUNT(*) AS payment_count,
        SUM(payment_value) AS total_payment_value,
        SUM(payment_installments) AS total_installments
    FROM order_payments
    GROUP BY order_id
),
main_payment AS (
    SELECT
        order_id,
        payment_type,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY payment_value DESC, payment_sequential
        ) AS rn
    FROM order_payments
)
SELECT
    o.order_id,
    strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
    o.order_status,
    ps.payment_count,
    ps.total_payment_value,
    ps.total_installments,
    mp.payment_type AS main_payment_type,
    r.review_score,
    julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date) AS delivery_delay_days
FROM orders o
JOIN payment_summary ps
    ON o.order_id = ps.order_id
JOIN main_payment mp
    ON o.order_id = mp.order_id
   AND mp.rn = 1
LEFT JOIN order_reviews r
    ON o.order_id = r.order_id;

--payment per order
WITH payment_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value
    FROM order_payments
    GROUP BY order_id
),
main_payment AS (
    SELECT
        order_id,
        payment_type,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY payment_value DESC, payment_sequential
        ) AS rn
    FROM order_payments
)
SELECT
    mp.payment_type,
    COUNT(*) AS orders,
    ROUND(AVG(ppo.total_payment_value), 2) AS avg_order_value,
    ROUND(SUM(ppo.total_payment_value), 2) AS total_revenue
FROM main_payment mp
JOIN payment_per_order ppo
    ON mp.order_id = ppo.order_id
WHERE mp.rn = 1
GROUP BY mp.payment_type
ORDER BY total_revenue DESC;

--analysis of credit card installment
WITH cc_orders AS (
    SELECT
        order_id,
        MAX(payment_installments) AS installments,
        SUM(payment_value) AS total_payment_value
    FROM order_payments
    WHERE payment_type = 'credit_card'
    GROUP BY order_id
)
SELECT
    installments,
    COUNT(*) AS orders,
    ROUND(AVG(total_payment_value), 2) AS avg_order_value,
    ROUND(SUM(total_payment_value), 2) AS total_revenue
FROM cc_orders
GROUP BY installments
ORDER BY installments;

--review rating per payment method
WITH payment_per_order AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value
    FROM order_payments
    GROUP BY order_id
),
main_payment AS (
    SELECT
        order_id,
        payment_type,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY payment_value DESC, payment_sequential
        ) AS rn
    FROM order_payments
)
SELECT
    mp.payment_type,
    COUNT(*) AS orders,
    ROUND(AVG(ppo.total_payment_value), 2) AS avg_order_value,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM main_payment mp
JOIN payment_per_order ppo
    ON mp.order_id = ppo.order_id
LEFT JOIN order_reviews r
    ON mp.order_id = r.order_id
WHERE mp.rn = 1
GROUP BY mp.payment_type
ORDER BY orders DESC;