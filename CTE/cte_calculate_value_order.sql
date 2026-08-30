WITH order_values AS (
    SELECT
        id,
        customer_name,
        product,
        quantity,
        price,
        quantity * price AS total_amount
    FROM orders
)
SELECT *
FROM order_values;