/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/


-- =============================================================================
-- Create Report: gold.report_customers
-- =============================================================================
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS
 
-- 1 -- BASE QUERY: RETRIVE CORE COLUMNS FROM TABLES
WITH base_query AS (
SELECT 
	sa.order_number,
	sa.product_key,
	sa.order_date,
	sa.quantity,
	sa.sales_amount,
	cu.customer_key,
	cu.customer_number,
	CONCAT(cu.first_name, ' ', cu.last_name) AS customer_name,
	DATEDIFF(year, cu.birthdate, GETDATE()) AS customer_age
FROM gold.fact_sales sa
LEFT JOIN gold.dim_customers cu
	ON sa.customer_key = cu.customer_key
WHERE order_date IS NOT NULL
)
-- 2 -- CUSTOMER AGGREGATIONS: SUMMERIZE KEY METRICS AT THE CUSTOMER LEVEL
, customer_aggregation AS (
SELECT 
	customer_key,
	customer_number,
	customer_name,
	customer_age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY customer_key, customer_number, customer_name, customer_age
)
SELECT 
	customer_key,
	customer_number,
	customer_name,
	customer_age,
	CASE WHEN customer_age < 20 THEN 'Under 20'
		 WHEN customer_age BETWEEN 20 AND 29 THEN '20-29'
		 WHEN customer_age BETWEEN 30 AND 39 THEN '30-39'
		 WHEN customer_age BETWEEN 40 AND 49 THEN '40-49'
		 WHEN customer_age >= 50 THEN '50 and above'
		 ELSE 'Unknown'
	END age_group,
	CASE WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
			 ELSE 'New'
	END customer_segment,
	last_order_date,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency,
	total_orders,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	-- CALCULATE AVERAGE ORDER VALUE (AVO)
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders 
	END avg_order_value,
	-- CALCULATE AVERAGE MONTHLY SPEND
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales / lifespan
	END avg_monthly_spend
FROM customer_aggregation
