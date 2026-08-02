/*
==========================================================
File: 03_import_data.sql

Project: SQL Data Warehouse & Sales Analytics

Description:
Data was imported using the pgAdmin Import/Export Wizard.

Author: Prakhar Singh
Database: PostgreSQL

==========================================================
*/

-- Data Import Method

/*
The following CSV files were imported manually using
pgAdmin's Import/Export Data tool.

Files Imported:

1. gold.dim_customers.csv
2. gold.dim_products.csv
3. gold.fact_sales.csv

Import Settings:

- Format      : CSV
- Header      : Yes
- Delimiter   : ,
- Encoding    : UTF-8
*/

-- Verify imported records

SELECT COUNT(*) AS customers
FROM gold.dim_customers;

SELECT COUNT(*) AS products
FROM gold.dim_products;

SELECT COUNT(*) AS sales
FROM gold.fact_sales;