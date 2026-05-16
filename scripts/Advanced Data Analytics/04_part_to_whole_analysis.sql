 /*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - Compare performance or metrics across dimensions or time periods.
    - Evaluate differences between categories.
    - Useful for A/B testing or regional comparisons.

SQL Functions Used:
    - SUM(), AVG(): Aggregates values for comparison.
    - Window Functions: SUM() OVER() for total calculations.
===============================================================================
*/


-- WHICH CATEGORIES CONTRIBUTE THE MOST TO OVERALL SALES?
WITH category_sales AS (
SELECT 
	pr.category,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales sa
LEFT JOIN gold.dim_products pr
	ON sa.product_key = pr.product_key
GROUP BY pr.category
)
SELECT 
	category,
	total_sales,
	SUM(total_sales) OVER () AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC


-- WHICH SUBCATEGORIES CONTRIBUTE THE MOST TO BIKES CATEGORY SALES?
WITH bikes_category_sales AS (
SELECT 
	pr.subcategory,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales sa
LEFT JOIN gold.dim_products pr
	ON sa.product_key = pr.product_key
WHERE pr.category = 'Bikes'
GROUP BY pr.subcategory
)
SELECT 
	subcategory,
	total_sales,
	SUM(total_sales) OVER () AS overall_bikes_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM bikes_category_sales
ORDER BY total_sales DESC


-- WHICH COUNTRIES CONTRIBUTE THE MOST TO OVERALL SALES?
WITH country_sales AS (
SELECT 
	cu.country,
	SUM(sales_amount) AS total_sales
FROM gold.fact_sales sa
LEFT JOIN gold.dim_customers cu
	ON sa.customer_key = cu.customer_key
GROUP BY cu.country
)
SELECT 
	country,
	total_sales,
	SUM(total_sales) OVER () AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM country_sales
ORDER BY total_sales DESC
