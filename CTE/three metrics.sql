WITH order_values AS (
    SELECT
        customer_name,
        quantity,
        quantity * price AS total_amount
    FROM orders
)
SELECT
    customer_name,
    COUNT(*) AS number_of_orders,
    SUM(quantity) AS products_bought,
    SUM(total_amount) AS total_spent
FROM order_values
GROUP BY customer_name;