 
/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - Calculate aggregated metrics (e.g., totals, averages) for quick insights.
    - Identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/


-- FIND THE TOTAL SALES
SELECT 
	SUM(sales_amount) AS tota_sales
FROM gold.fact_sales


-- FIND HOW MANY ITEMS ARE SOLD
SELECT 
	SUM(quantity) AS total_items_sold
FROM gold.fact_sales


-- FIND THE AVERAGE SELLING PRICE
SELECT 
	AVG(price) AS avg_price
FROM gold.fact_sales


-- FIND THE TOTAL NUMBER OF ORDERS
SELECT 
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales


-- FIND THE TOTAL NUMBER OF PRODUCTS
SELECT 
	COUNT(product_key) AS tota_products
FROM gold.dim_products


-- FIND THE TOTAL NUMBER OF CUSTOMERS
SELECT 
	COUNT(customer_key) AS total_customers
FROM gold.dim_customers


-- FIND THE TOTAL NUMBER OF CUSTOMERS THAT HAVE PLACED AN ORDER
SELECT
	COUNT(DISTINCT customer_key) AS total_customers_placed_orders
FROM gold.fact_sales



-- GENERATE A REPORT THAT SHOWS ALL KEY METRICS OF THE BUSINESS
SELECT 'Total sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total products sold', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average selling price', AVG(price) AS avg_price FROM gold.fact_sales
UNION ALL
SELECT 'Total number of orders', COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_sales
UNION ALL
SELECT 'Total number of products', COUNT(product_key) AS tota_products FROM gold.dim_products
UNION ALL 
SELECT 'Total customers', COUNT(customer_key) AS total_customers FROM gold.dim_customers
UNION ALL 
SELECT 'Total number of customers that placed an order', COUNT(DISTINCT customer_key) AS total_customers_placed_orders FROM gold.fact_sales
