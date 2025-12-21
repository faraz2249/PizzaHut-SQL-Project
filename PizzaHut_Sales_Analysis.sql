
-- PizzaHut Sales Analysis SQL File

CREATE DATABASE PizzaHut;
USE PizzaHut;

-- Table Creation
CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

CREATE TABLE orders_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);

-- Total number of orders
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- Total revenue
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price), 2) AS total_sales
FROM orders_details
JOIN pizzas 
ON pizzas.pizza_id = orders_details.pizza_id;

-- Highest priced pizza
SELECT 
    pizza_types.name, 
    pizzas.price
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Most common pizza size
SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM pizzas
JOIN orders_details 
ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

-- Top 5 most ordered pizzas
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details 
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- Quantity by category
SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details 
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- Orders by hour
SELECT 
    HOUR(order_time) AS hour,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY HOUR(order_time);

-- Category-wise pizza count
SELECT 
    category, 
    COUNT(name)
FROM pizza_types
GROUP BY category;

-- Average pizzas per day
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM (
    SELECT 
        orders.order_date,
        SUM(orders_details.quantity) AS quantity
    FROM orders
    JOIN orders_details 
    ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date
) AS order_quantity;

-- Top 3 pizzas by revenue
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM pizza_types
JOIN pizzas 
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN orders_details 
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- Revenue percentage by category
SELECT 
    pizza_types.category,
    (SUM(orders_details.quantity * pizzas.price) / 
    (SELECT SUM(orders_details.quantity * pizzas.price) 
     FROM orders_details 
     JOIN pizzas 
     ON pizzas.pizza_id = orders_details.pizza_id)) * 100 AS revenue
FROM pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details 
ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- Cumulative revenue over time
SELECT 
    order_date,
    SUM(revenue) OVER (ORDER BY order_date) AS cum_revenue
FROM (
    SELECT 
        orders.order_date,
        SUM(orders_details.quantity * pizzas.price) AS revenue
    FROM orders_details
    JOIN pizzas 
    ON orders_details.pizza_id = pizzas.pizza_id
    JOIN orders 
    ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date
) AS sales;

-- Top 3 pizzas per category by revenue
SELECT name, revenue
FROM (
    SELECT 
        category,
        name,
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
    FROM (
        SELECT 
            pizza_types.category,
            pizza_types.name,
            SUM(orders_details.quantity * pizzas.price) AS revenue
        FROM pizza_types
        JOIN pizzas 
        ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN orders_details 
        ON orders_details.pizza_id = pizzas.pizza_id
        GROUP BY pizza_types.category, pizza_types.name
    ) AS a
) AS b
WHERE rn <= 3;
