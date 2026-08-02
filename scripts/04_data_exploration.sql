/*
==========================================================
File: 04_data_exploration.sql

Project: SQL Data Warehouse & Sales Analytics

Description:
Exploratory Data Analysis (EDA)

Author: Prakhar Singh
Database: PostgreSQL

==========================================================
*/

----------------------------------------------------------
-- Preview Tables
----------------------------------------------------------

SELECT *
FROM gold.dim_customers
LIMIT 10;

SELECT *
FROM gold.dim_products
LIMIT 10;

SELECT *
FROM gold.fact_sales
LIMIT 10;

----------------------------------------------------------
-- Record Count
----------------------------------------------------------

SELECT COUNT(*) AS total_customers
FROM gold.dim_customers;

SELECT COUNT(*) AS total_products
FROM gold.dim_products;

SELECT COUNT(*) AS total_sales
FROM gold.fact_sales;

----------------------------------------------------------
-- Unique Values
----------------------------------------------------------

SELECT DISTINCT country
FROM gold.dim_customers;

SELECT DISTINCT category
FROM gold.dim_products;

SELECT DISTINCT gender
FROM gold.dim_customers;

----------------------------------------------------------
-- Date Range
----------------------------------------------------------

SELECT
MIN(order_date) AS first_order,
MAX(order_date) AS last_order
FROM gold.fact_sales;

----------------------------------------------------------
-- Sales Range
----------------------------------------------------------

SELECT
MIN(sales_amount) AS minimum_sales,
MAX(sales_amount) AS maximum_sales
FROM gold.fact_sales;

----------------------------------------------------------
-- Product Count by Category
----------------------------------------------------------

SELECT
category,
COUNT(product_id) AS product_count
FROM gold.dim_products
GROUP BY category
ORDER BY product_count DESC;

----------------------------------------------------------
-- Customer Count by Country
----------------------------------------------------------

SELECT
country,
COUNT(customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

----------------------------------------------------------
-- Gender Distribution
----------------------------------------------------------

SELECT
gender,
COUNT(customer_id) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

----------------------------------------------------------
-- Average Sales
----------------------------------------------------------

SELECT
ROUND(AVG(sales_amount),2) AS average_sales
FROM gold.fact_sales;

----------------------------------------------------------
-- Total Revenue
----------------------------------------------------------

SELECT
ROUND(SUM(sales_amount),2) AS total_revenue
FROM gold.fact_sales;

----------------------------------------------------------
-- Missing Category Values
----------------------------------------------------------

SELECT *
FROM gold.dim_products
WHERE category IS NULL;

----------------------------------------------------------
-- Sample Join Verification
----------------------------------------------------------

SELECT
s.order_number,
c.first_name,
p.product_name,
s.sales_amount
FROM gold.fact_sales s
JOIN gold.dim_products p
ON s.product_key = p.product_key
JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
LIMIT 20;