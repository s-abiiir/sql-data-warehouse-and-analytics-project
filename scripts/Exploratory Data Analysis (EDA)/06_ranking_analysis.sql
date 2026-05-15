
/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - Rank items (e.g., products, customers) based on performance or other metrics.
    - Identify top performers or laggards.

SQL Functions Used:
    - TOP N, Window Ranking Function RANK() 
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/


-- WHICH 5 PRODUCTS GENERATE THE HIGHEST REVENUE?

-- SIMPLE RANKING
SELECT TOP 5
	pr.product_name,
	SUM(sa.sales_amount) AS total_revenue
FROM gold.fact_sales sa
LEFT JOIN gold.dim_products pr
	ON sa.product_key = pr.product_key
GROUP BY pr.product_name
ORDER BY total_revenue DESC

-- RANKING USING WINDOW FUNCTIONS
SELECT 
	product_name,
	total_revenue
FROM (
	SELECT 
		pr.product_name,
		SUM(sa.sales_amount) AS total_revenue,
		RANK() OVER (ORDER BY SUM(sa.sales_amount) DESC) AS rank_products
	FROM gold.fact_sales sa
	LEFT JOIN gold.dim_products pr
		ON sa.product_key = pr.product_key
	GROUP BY pr.product_name
) ranked_products
WHERE rank_products <=5



-- WHAT ARE THE 5 WORST-PERFORMING PRODUCTS IN TERMS OF SALES?
SELECT TOP 5
	pr.product_name,
	SUM(sa.sales_amount) AS total_revenue
FROM gold.fact_sales sa
LEFT JOIN gold.dim_products pr
	ON sa.product_key = pr.product_key
GROUP BY pr.product_name
ORDER BY total_revenue 



-- WHICH CATEGORY GENERATES THE HIGHEST REVENUE?
SELECT TOP 1
	pr.category,
	SUM(sa.sales_amount) AS total_revenue
FROM gold.fact_sales sa
LEFT JOIN gold.dim_products pr
	ON sa.product_key = pr.product_key
GROUP BY pr.category
ORDER BY total_revenue DESC



-- FIND THE TOP 10 CUSTOMERS WHO HAVE GENERATED THE HIGHEST REVENUE
SELECT TOP 10
	cu.customer_key,
	cu.first_name,
	cu.last_name,
	SUM(sa.sales_amount) AS total_revenue
FROM gold.fact_sales sa
LEFT JOIN gold.dim_customers cu
	ON sa.customer_key = cu.customer_key
GROUP BY cu.customer_key, cu.first_name, cu.last_name
ORDER BY total_revenue DESC



-- THE 5 CUSTOMERS WITH THE HIGHEST ORDERS PLACED
SELECT TOP 5
	cu.customer_key,
	cu.first_name,
	cu.last_name,
	COUNT(DISTINCT sa.order_number) AS total_orders
FROM gold.fact_sales sa
LEFT JOIN gold.dim_customers cu
	ON sa.customer_key = cu.customer_key
GROUP BY cu.customer_key, cu.first_name, cu.last_name
ORDER BY total_orders DESC
