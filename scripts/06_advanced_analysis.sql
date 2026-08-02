/*
==========================================================
File: 06_advanced_analysis.sql

Project: SQL Data Warehouse & Sales Analytics

Description:
Advanced analytical queries using CTEs,
Window Functions and Business Analysis.

Author: Prakhar Singh
Database: PostgreSQL

==========================================================
*/

----------------------------------------------------------
-- 1. Monthly Revenue with Previous Month Revenue
----------------------------------------------------------

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
)

SELECT
    *,
    LAG(revenue)
    OVER(ORDER BY year,month) AS previous_revenue
FROM monthly_sales;

----------------------------------------------------------
-- 2. Monthly Growth Percentage
----------------------------------------------------------

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

growth AS
(
SELECT
    *,
    LAG(revenue)
    OVER(ORDER BY year,month) AS previous_revenue
FROM monthly_sales
)

SELECT
    year,
    month,
    revenue,
    previous_revenue,

ROUND(
(revenue-previous_revenue)*100.0/
NULLIF(previous_revenue,0),
2
) AS growth_percentage

FROM growth
ORDER BY year,month;

----------------------------------------------------------
-- 3. Running Revenue
----------------------------------------------------------

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
)

SELECT
*,

SUM(revenue)
OVER(
ORDER BY year,month
) AS running_revenue

FROM monthly_sales;

----------------------------------------------------------
-- 4. Rank Customers by Revenue
----------------------------------------------------------

WITH customer_revenue AS
(
SELECT

c.customer_id,

CONCAT(c.first_name,' ',c.last_name) AS customer_name,

SUM(s.sales_amount) AS revenue

FROM gold.fact_sales s

JOIN gold.dim_customers c

ON s.customer_key=c.customer_key

GROUP BY
c.customer_id,
customer_name
)

SELECT

*,

RANK()

OVER(ORDER BY revenue DESC) AS customer_rank

FROM customer_revenue;

----------------------------------------------------------
-- 5. Top Product in Every Category
----------------------------------------------------------

SELECT *

FROM
(
SELECT

p.category,

p.product_name,

SUM(s.sales_amount) AS revenue,

RANK()

OVER(

PARTITION BY p.category

ORDER BY SUM(s.sales_amount) DESC

) AS product_rank

FROM gold.fact_sales s

JOIN gold.dim_products p

ON s.product_key=p.product_key

GROUP BY

p.category,

p.product_name

) ranked_products

WHERE product_rank=1;

----------------------------------------------------------
-- 6. Top 10 Customer Contribution
----------------------------------------------------------

WITH customer_sales AS
(
SELECT

c.customer_id,

SUM(s.sales_amount) AS customer_revenue

FROM gold.fact_sales s

JOIN gold.dim_customers c

ON s.customer_key=c.customer_key

GROUP BY c.customer_id
),

ranked_customers AS
(
SELECT

*,

ROW_NUMBER()

OVER(ORDER BY customer_revenue DESC) AS rn

FROM customer_sales
)

SELECT

SUM(customer_revenue) AS top10_revenue,

(SELECT SUM(sales_amount)

FROM gold.fact_sales) AS total_revenue,

ROUND(

SUM(customer_revenue)*100.0/

(SELECT SUM(sales_amount)

FROM gold.fact_sales)

,2) AS contribution_percentage

FROM ranked_customers

WHERE rn<=10;

----------------------------------------------------------
-- 7. Revenue Contribution by Category
----------------------------------------------------------

WITH category_sales AS
(
SELECT

p.category,

SUM(s.sales_amount) AS revenue

FROM gold.fact_sales s

JOIN gold.dim_products p

ON s.product_key=p.product_key

GROUP BY p.category
)

SELECT

category,

revenue,

ROUND(

revenue*100.0/

(SELECT SUM(sales_amount)

FROM gold.fact_sales)

,2

) AS revenue_percentage

FROM category_sales

ORDER BY revenue DESC;

----------------------------------------------------------
-- 8. Highest Revenue Month of Every Year
----------------------------------------------------------

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

ranked_months AS
(
SELECT

*,

ROW_NUMBER()

OVER(

PARTITION BY year

ORDER BY revenue DESC

) AS rn

FROM monthly_sales
)

SELECT *

FROM ranked_months

WHERE rn=1;

----------------------------------------------------------
-- 9. Best Customer in Every Country
----------------------------------------------------------

WITH customer_sales AS
(
SELECT

c.country,

c.customer_id,

CONCAT(c.first_name,' ',c.last_name) AS customer_name,

SUM(s.sales_amount) AS revenue

FROM gold.fact_sales s

JOIN gold.dim_customers c

ON s.customer_key=c.customer_key

GROUP BY

c.country,

c.customer_id,

customer_name
),

ranked_customers AS
(
SELECT

*,

ROW_NUMBER()

OVER(

PARTITION BY country

ORDER BY revenue DESC

) AS rn

FROM customer_sales
)

SELECT

country,

customer_id,

customer_name,

revenue

FROM ranked_customers

WHERE rn=1;

----------------------------------------------------------
-- 10. Customer Segmentation
----------------------------------------------------------

WITH customer_sales AS
(
SELECT

c.customer_id,

CONCAT(c.first_name,' ',c.last_name) AS customer_name,

SUM(s.sales_amount) AS revenue

FROM gold.fact_sales s

JOIN gold.dim_customers c

ON s.customer_key=c.customer_key

GROUP BY

c.customer_id,

customer_name
)

SELECT

*,

CASE

WHEN revenue>=10000 THEN 'Premium'

WHEN revenue>=5000 THEN 'Regular'

ELSE 'Basic'

END AS customer_segment

FROM customer_sales;

----------------------------------------------------------
-- 11. Revenue Bucket Analysis
----------------------------------------------------------

WITH customer_sales AS
(
SELECT

c.customer_id,

SUM(s.sales_amount) AS revenue

FROM gold.fact_sales s

JOIN gold.dim_customers c

ON s.customer_key=c.customer_key

GROUP BY c.customer_id
)

SELECT

CASE

WHEN revenue<=1000 THEN '0-1000'

WHEN revenue<=5000 THEN '1001-5000'

WHEN revenue<=10000 THEN '5001-10000'

ELSE '10001+'

END AS revenue_bucket,

COUNT(*) AS customers,

SUM(revenue) AS total_revenue

FROM customer_sales

GROUP BY revenue_bucket

ORDER BY revenue_bucket;