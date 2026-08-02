/*
==========================================================
File: 05_business_analysis.sql

Project: SQL Data Warehouse & Sales Analytics

Description:
Business-oriented analytical queries used to answer
real-world sales and customer questions.

Author: Prakhar Singh
Database: PostgreSQL

==========================================================
*/

----------------------------------------------------------
-- 1. Highest Revenue by Country
----------------------------------------------------------

SELECT
    c.country,
    SUM(s.sales_amount) AS revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY revenue DESC;

----------------------------------------------------------
-- 2. Top 10 Highest Selling Products
----------------------------------------------------------

SELECT
    p.product_name,
    SUM(s.sales_amount) AS sales
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY sales DESC
LIMIT 10;

----------------------------------------------------------
-- 3. Highest Revenue Category
----------------------------------------------------------

SELECT
    p.category,
    SUM(s.sales_amount) AS revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY revenue DESC
LIMIT 1;

----------------------------------------------------------
-- 4. Highest Revenue Customer
----------------------------------------------------------

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(s.sales_amount) AS revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY
    c.customer_id,
    customer_name
ORDER BY revenue DESC
LIMIT 1;

----------------------------------------------------------
-- 5. Monthly Revenue Trend
----------------------------------------------------------

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(sales_amount) AS revenue
FROM gold.fact_sales
GROUP BY
    EXTRACT(YEAR FROM order_date),
    EXTRACT(MONTH FROM order_date)
ORDER BY year, month;

----------------------------------------------------------
-- 6. Top 5 Customers by Revenue
----------------------------------------------------------

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    SUM(s.sales_amount) AS revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY
    c.customer_id,
    customer_name
ORDER BY revenue DESC
LIMIT 5;

----------------------------------------------------------
-- 7. Average Order Value
----------------------------------------------------------

SELECT
ROUND(
SUM(sales_amount) /
COUNT(DISTINCT order_number),
2
) AS average_order_value
FROM gold.fact_sales;

----------------------------------------------------------
-- 8. Top 5 Products by Quantity Sold
----------------------------------------------------------

SELECT
    p.product_name,
    SUM(s.quantity) AS quantity_sold
FROM gold.fact_sales s
INNER JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY quantity_sold DESC
LIMIT 5;

----------------------------------------------------------
-- 9. Top 5 Customers by Number of Orders
----------------------------------------------------------

SELECT
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    COUNT(DISTINCT s.order_number) AS total_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
GROUP BY
    c.customer_id,
    customer_name
ORDER BY total_orders DESC
LIMIT 5;

----------------------------------------------------------
-- 10. Category Performance
----------------------------------------------------------

SELECT
    p.category,
    SUM(s.sales_amount) AS revenue,
    ROUND(AVG(s.sales_amount),2) AS average_sales,
    COUNT(DISTINCT s.order_number) AS total_orders
FROM gold.fact_sales s
INNER JOIN gold.dim_products p
    ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY revenue DESC;