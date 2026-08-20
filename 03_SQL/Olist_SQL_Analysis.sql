-- =========================================================
-- OLIST E-COMMERCE ANALYSIS
-- SQL BUSINESS ANALYSIS
-- =========================================================
-- Project Type : End-to-End Data Analytics & Business Intelligence
-- Dataset      : Brazilian E-Commerce Public Dataset by Olist
-- Database     : MySQL
-- SQL Queries  : 20
-- Author       : Sejal Sayam
-- Date         : August 2026
-- =========================================================
                   -- BEGINNER LEVEL -- 
-- =========================================================
-- Focus: SELECT, COUNT, WHERE, GROUP BY, ORDER BY,
--        and date functions.
-- =========================================================

-- Q1. Total Number of Customers
-- Business Question:
-- How many customers are present in the dataset?

SELECT COUNT(*) AS total_customers
FROM customers;

-- Expected Result: 99,441
-- =========================================================
-- Q2. Customer Count by State
-- Business Question:
-- How are customers distributed across different states?

SELECT
    customer_state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY customer_state
ORDER BY customer_count DESC;

-- =========================================================
-- Q3. Order Count by Order Status
-- Business Question:
-- What is the distribution of orders across different
-- order statuses?

SELECT
    order_status,
    COUNT(*) AS order_count
FROM orders
GROUP BY order_status
ORDER BY order_count DESC;

-- =========================================================
-- Q4. Number of Products by Category
-- Business Question:
-- How many products are available in each product category?

SELECT
    product_category_name,
    COUNT(*) AS available_products
FROM products
GROUP BY product_category_name
ORDER BY available_products DESC;

-- =========================================================
-- Q5. Number of Sellers by State
-- Business Question:
-- How are sellers distributed across different states?

SELECT
    seller_state,
    COUNT(*) AS seller_count
FROM sellers
GROUP BY seller_state
ORDER BY seller_count DESC;

-- =========================================================
-- Q6. Number of Orders Placed Each Year
-- Business Question:
-- How has the number of orders changed year over year?

SELECT
    YEAR(order_purchase_timestamp) AS order_year,
    COUNT(*) AS total_orders
FROM orders
GROUP BY YEAR(order_purchase_timestamp)
ORDER BY order_year;
 
 -- =========================================================
                 -- Intermediate Level --
 -- =========================================================
-- Focus: JOIN, aggregation, subqueries, revenue analysis,
--        payment analysis, review analysis, and date
--        calculations.
-- =========================================================

-- Q7. Calculate Total Revenue
-- Business Question:
-- What is the total revenue generated from product prices
-- and freight charges?

SELECT
    ROUND(SUM(price + freight_value), 2) AS total_revenue
FROM order_items;

-- =========================================================
-- Q8. Calculate Average Order Value (AOV)
-- Business Question:
-- What is the average amount paid per order?

SELECT
    ROUND(AVG(order_total), 2) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(payment_value) AS order_total
    FROM order_payments
    GROUP BY order_id
) AS order_value;

-- =========================================================
-- Q9. Top 10 Product Categories by Revenue
-- Business Question:
-- Which product categories generate the highest revenue?

SELECT
    p.product_category_name,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 10;

-- =========================================================
-- Q10. Top 10 Seller States by Revenue
-- Business Question:
-- Which seller states generate the highest revenue?

SELECT
    s.seller_state,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue
FROM sellers AS s
JOIN order_items AS oi
    ON oi.seller_id = s.seller_id
GROUP BY s.seller_state
ORDER BY revenue DESC
LIMIT 10;

-- =========================================================
-- Q11. Revenue by Customer State
-- Business Question:
-- Which customer states generate the highest revenue?

SELECT
    c.customer_state,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

-- =========================================================
-- Q12. Most Preferred Payment Method
-- Business Question:
-- Which payment methods are most frequently used by
-- customers?

SELECT
    payment_type,
    COUNT(order_id) AS total_orders
FROM order_payments
GROUP BY payment_type
ORDER BY total_orders DESC;

-- =========================================================
-- Q13. Average Review Score by Product Category
-- Business Question:
-- How does customer satisfaction vary across product
-- categories?

SELECT
    p.product_category_name,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM products AS p
JOIN order_items AS oi
    ON p.product_id = oi.product_id
JOIN order_reviews AS r
    ON oi.order_id = r.order_id
GROUP BY p.product_category_name;

-- =========================================================
-- Q14. Average Delivery Time
-- Business Question:
-- What is the average time taken to deliver an order
-- to the customer?

SELECT
    ROUND(
        AVG(
            DATEDIFF(
                order_delivered_customer_date,
                order_purchase_timestamp
            )
        ),
        2
    ) AS average_delivery_time_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- =========================================================
                  -- ADVANCED LEVEL --
-- =========================================================
-- Focus: Window functions, ranking, subqueries,
--        time-series analysis, repeat-customer analysis,
--        and customer lifetime value.
-- =========================================================

-- =========================================================
-- Q15. Rank Top 10 Customers by Total Spending
-- Business Question:
-- Which customers have generated the highest total spending?

SELECT *
FROM (
    SELECT
        c.customer_id,
        ROUND(SUM(op.payment_value), 2) AS total_spending,
        DENSE_RANK() OVER (
            ORDER BY SUM(op.payment_value) DESC
        ) AS customer_rank
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    JOIN order_payments AS op
        ON op.order_id = o.order_id
    GROUP BY c.customer_id
) AS customer_ranking
WHERE customer_rank <= 10;

-- =========================================================
-- Q16. Monthly Revenue Trend
-- Business Question:
-- How does revenue change from month to month?

SELECT
    DATE_FORMAT(
        o.order_purchase_timestamp,
        '%Y-%m'
    ) AS order_month,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS monthly_revenue
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(
    o.order_purchase_timestamp,
    '%Y-%m'
)
ORDER BY order_month;

-- =========================================================
-- Q17. Customers with More Than One Order
-- Business Question:
-- Which customers have made repeat purchases?

SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC;

-- =========================================================
-- Q18. Top 3 Product Categories by Revenue
-- Business Question:
-- Which three product categories generate the highest
-- revenue?

SELECT
    p.product_category_name,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue
FROM order_items AS oi
JOIN products AS p
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 3;

-- =========================================================
-- Q19. Customer Lifetime Value (Historical)
-- Business Question:
-- What is the total historical payment value generated
-- by each customer during the available analysis period?

SELECT
    c.customer_id,
    ROUND(SUM(op.payment_value), 2) AS customer_lifetime_value
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
JOIN order_payments AS op
    ON op.order_id = o.order_id
GROUP BY c.customer_id
ORDER BY customer_lifetime_value DESC;

-- =========================================================
-- Q20. Top 10 Sellers by Total Revenue
-- Business Question:
-- Which sellers generate the highest revenue?

SELECT
    s.seller_id,
    s.seller_state,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue
FROM sellers AS s
JOIN order_items AS oi
    ON s.seller_id = oi.seller_id
GROUP BY
    s.seller_id,
    s.seller_state
ORDER BY revenue DESC
LIMIT 10;



