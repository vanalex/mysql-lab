CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    order_date DATE NOT NULL
);

INSERT INTO orders (
    customer_name,
    product,
    quantity,
    price,
    order_date
)
VALUES
    ('Alice', 'Keyboard', 1, 80.00, '2026-08-01'),
    ('Alice', 'Mouse', 2, 30.00, '2026-08-03'),
    ('Bob', 'Monitor', 1, 300.00, '2026-08-02'),
    ('Bob', 'Keyboard', 2, 80.00, '2026-08-05'),
    ('Charlie', 'Mouse', 1, 30.00, '2026-08-04'),
    ('Charlie', 'Monitor', 2, 300.00, '2026-08-06'),
    ('Alice', 'Monitor', 1, 300.00, '2026-08-07');