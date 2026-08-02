/*
==========================================================
File: 07_create_views.sql

Project: SQL Data Warehouse & Sales Analytics

Description:
Creates reusable analytical views for reporting
and dashboard development.

Author: Prakhar Singh
Database: PostgreSQL

==========================================================
*/

----------------------------------------------------------
-- View 1 : Customer Summary
----------------------------------------------------------

DROP VIEW IF EXISTS gold.customer_summary;

CREATE VIEW gold.customer_summary AS

SELECT

c.customer_id,

CONCAT(c.first_name,' ',c.last_name) AS customer_name,

c.country,

SUM(s.sales_amount) AS total_revenue,

COUNT(DISTINCT s.order_number) AS total_orders,

ROUND(

SUM(s.sales_amount)
/COUNT(DISTINCT s.order_number)

,2) AS average_order_value,

CASE

WHEN SUM(s.sales_amount)>=10000 THEN 'Premium'

WHEN SUM(s.sales_amount)>=5000 THEN 'Regular'

ELSE 'Basic'

END AS customer_segment

FROM gold.fact_sales s

JOIN gold.dim_customers c

ON s.customer_key=c.customer_key

GROUP BY

c.customer_id,

customer_name,

c.country;

----------------------------------------------------------
-- View 2 : Product Summary
----------------------------------------------------------

DROP VIEW IF EXISTS gold.product_summary;

CREATE VIEW gold.product_summary AS

SELECT

p.product_id,

p.product_name,

p.category,

SUM(s.sales_amount) AS total_revenue,

SUM(s.quantity) AS total_quantity,

COUNT(DISTINCT s.order_number) AS total_orders,

RANK()

OVER(

ORDER BY SUM(s.sales_amount) DESC

) AS product_rank

FROM gold.fact_sales s

JOIN gold.dim_products p

ON s.product_key=p.product_key

GROUP BY

p.product_id,

p.product_name,

p.category;

----------------------------------------------------------
-- View 3 : Sales Summary
----------------------------------------------------------

DROP VIEW IF EXISTS gold.sales_summary;

CREATE VIEW gold.sales_summary AS

WITH monthly_sales AS
(
SELECT

EXTRACT(YEAR FROM order_date) AS year,

EXTRACT(MONTH FROM order_date) AS month,

SUM(sales_amount) AS revenue

FROM gold.fact_sales

GROUP BY

EXTRACT(YEAR FROM order_date),

EXTRACT(MONTH FROM order_date)
),

sales_growth AS
(
SELECT

*,

SUM(revenue)

OVER(

ORDER BY year,month

) AS running_revenue,

LAG(revenue)

OVER(

ORDER BY year,month

) AS previous_revenue

FROM monthly_sales
)

SELECT

year,

month,

revenue,

running_revenue,

previous_revenue,

ROUND(

(revenue-previous_revenue)

*100.0/

NULLIF(previous_revenue,0)

,2

) AS growth_percentage

FROM sales_growth;

----------------------------------------------------------
-- Verify Views
----------------------------------------------------------

SELECT *
FROM gold.customer_summary
LIMIT 20;

SELECT *
FROM gold.product_summary
LIMIT 20;

SELECT *
FROM gold.sales_summary
LIMIT 20;