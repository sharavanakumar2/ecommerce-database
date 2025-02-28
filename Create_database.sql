-- Create the ecommerce database if it doesn't exist.
CREATE DATABASE IF NOT EXISTS ecommerce;

-- Use the ecommerce database.
USE ecommerce;

-- Create the customers table.
CREATE TABLE IF NOT EXISTS customers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    address VARCHAR(255)
);

-- Create the products table.
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    description TEXT
);

-- Create the orders table with a foreign key referencing customers.
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Insert sample data into the customers table.
INSERT INTO customers (name, email, address) VALUES
('Alice Smith', 'alice@example.com', '123 Main St'),
('Bob Johnson', 'bob@example.com', '456 Oak Ave'),
('Charlie Brown', 'charlie@example.com', '789 Pine Ln'),
('David Lee', 'david@example.com', '101 Elm Rd');

-- Insert sample data into the products table.
INSERT INTO products (name, price, description) VALUES
('Product A', 25.00, 'Description of Product A'),
('Product B', 50.00, 'Description of Product B'),
('Product C', 30.00, 'Description of Product C'),
('Product D', 100.00, 'Description of Product D');

-- Insert sample data into the orders table. Use recent dates.
INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, '2023-12-01', 75.00),
(2, '2023-12-05', 120.00),
(1, '2023-12-15', 50.00),
(3, '2023-12-20', 150.00),
(4, '2023-12-25', 200.00),
(2, '2023-12-30', 90.00);

-- Retrieve all customers who have placed an order in the last 30 days.
SELECT DISTINCT c.*
FROM customers c
JOIN orders o ON c.id = o.customer_id
WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- Get the total amount of all orders placed by each customer.
SELECT c.name, SUM(o.total_amount) AS total_order_amount
FROM customers c
LEFT JOIN orders o ON c.id = o.customer_id
GROUP BY c.name;

-- Update the price of Product C to 45.00.
UPDATE products SET price = 45.00 WHERE name = 'Product C';

-- Add a new column discount to the products table.
ALTER TABLE products ADD COLUMN discount DECIMAL(5, 2) DEFAULT 0.00;

-- Retrieve the top 3 products with the highest price.
SELECT * FROM products ORDER BY price DESC LIMIT 3;

-- Create the order_items table for database normalization.
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Insert sample data into the order_items table.
INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 2, 1),
(2, 4, 1),
(3, 2, 1),
(4, 4, 1),
(5, 4, 2),
(6, 2, 1),
(6, 3, 1);

-- Update the orders table to calculate total_amount based on order_items.
UPDATE orders o
SET o.total_amount = (
    SELECT SUM(oi.quantity * p.price)
    FROM order_items oi
    JOIN products p ON oi.product_id = p.id
    WHERE oi.order_id = o.id
);

-- Retrieve the names of customers who have ordered Product A.
SELECT DISTINCT c.name
FROM customers c
JOIN orders o ON c.id = o.customer_id
JOIN order_items oi ON o.id = oi.order_id
JOIN products p ON oi.product_id = p.id
WHERE p.name = 'Product A';

-- Join the orders and customers tables to retrieve the customer's name and order date for each order.
SELECT c.name, o.order_date
FROM customers c
JOIN orders o ON c.id = o.customer_id;

-- Retrieve the orders with a total amount greater than 150.00.
SELECT * FROM orders WHERE total_amount > 150.00;

-- Retrieve the average total of all orders.
SELECT AVG(total_amount) AS average_order_total FROM orders;