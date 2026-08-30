with order_values as (
    select customer_name,
    quantity * price as total_amount
    from orders
)
select customer_name, sum(total_amount) as total_spending
from order_values
group by customer_name;