
/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - Group data into meaningful categories for targeted insights.
    - Customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/


-- SEGMENT PRODUCTS INTO COST RANGES AND COUNT HOW MANY PRODUCTS FALL INTO EACH SEGMENT
WITH product_segments AS (
SELECT 
	product_key,
	product_name,
	cost,
	CASE WHEN cost < 100 THEN 'Below 100'
		 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		 ELSE 'Above 1000'
	END cost_range
FROM gold.dim_products
)
SELECT 
	cost_range,
	COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC


-- SEGMENT CUSTOMERS INTO AGE GROUPS AND CALCULATE THE TOTAL NUMBER OF CUSTOMERS IN EACH GROUP
WITH customer_age_segments AS (
SELECT 
	customer_key,
	DATEDIFF(year, birthdate, GETDATE()) AS age,
	CASE WHEN DATEDIFF(year, birthdate, GETDATE()) BETWEEN 40 AND 59 THEN '40 - 60'
		 WHEN DATEDIFF(year, birthdate, GETDATE()) BETWEEN 40 AND 79 THEN '61 - 80'
		 WHEN DATEDIFF(year, birthdate, GETDATE()) BETWEEN 80 AND 99 THEN '81 - 100'
		 WHEN DATEDIFF(year, birthdate, GETDATE()) > 100 THEN 'Older than 100'
		 ELSE 'Unknown'
	END age_segment
FROM gold.dim_customers
)
SELECT 
	age_segment,
	COUNT(customer_key) AS total_customers
FROM customer_age_segments
GROUP BY age_segment
ORDER BY total_customers DESC


/* GROUP CUSTOMERS INTO THREE SEGMENTS BASED ON THEIR SPENDING BEHAVIOR:
	- VIP: CUSTOMERS WITH AT LEAST 12 MONTHS OF HISTORY AND SPENDING MORE THEN €5,000.
	- REGULAR: CUSTOMERS WITH AT LEAST 12 MONTHS OF HISTORY BUT SPENDING €5,000 OR LESS.
	- NEW: CUSTOMERS WITH A LIFESPAN LESS THAN 12 MONTHS.
AND FIND THE TOTAL NUMBER OF CUSTOMERS BY EACH GROUP
*/

WITH customer_spending AS (
SELECT 
	cu.customer_key,
	SUM(sa.sales_amount) AS total_spending,
	MIN(sa.order_date) AS first_order,
	MAX(sa.order_date) AS last_order,
	DATEDIFF(month, MIN(order_date), Max(order_date)) lifespan
FROM gold.fact_sales sa
LEFT JOIN gold.dim_customers cu
	ON sa.customer_key = cu.customer_key
GROUP BY cu.customer_key
) 
SELECT 
	customer_segment,
	COUNT(customer_key) AS total_customers
FROM (
	SELECT 
		customer_key,
		CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
			 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
			 ELSE 'New'
		END customer_segment
	FROM customer_spending 
)t 
GROUP BY customer_segment
ORDER BY total_customers DESC
