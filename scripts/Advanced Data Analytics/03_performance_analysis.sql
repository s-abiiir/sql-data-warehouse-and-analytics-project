
/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - Measure the performance of products over time.
    - Benchmarking and identifying high-performing entities.
    - Track yearly trends and growth.

SQL Functions Used:
    - LAG() OVER(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/


/* ANALYZE THE YEARLY PERFORMANCE OF PRODUCTS BY COMPARING THEIR SALES TO BOTH
THE AVERAGE SALES PERFORMANCE OF THE PRODUCT AND THE PREVIOUS YEAR'S SALES */

WITH yearly_product_sales AS (
SELECT 
	YEAR(sa.order_date) AS order_year,
	pr.product_name,
	SUM(sales_amount) AS current_sales
FROM gold.fact_sales sa
LEFT JOIN gold.dim_products pr
	ON sa.product_key = pr.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(sa.order_date), pr.product_name
)
SELECT 
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
		 ELSE 'Avg'
	END avg_change,
	-- Year-over-year Analysis
	LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,
	CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
		 ELSE 'No Change'
	END prev_year_change
FROM yearly_product_sales
ORDER BY product_name, order_year



-- MONTH BY MONTH PERFORMANCE ANALYSIS
WITH monthly_product_sales AS (
SELECT 
	YEAR(sa.order_date) AS order_year,
	MONTH(sa.order_date) AS order_month,
	pr.product_name,
	SUM(sales_amount) AS current_sales
FROM gold.fact_sales sa
LEFT JOIN gold.dim_products pr
	ON sa.product_key = pr.product_key
WHERE order_date IS NOT NULL
GROUP BY YEAR(sa.order_date), MONTH(sa.order_date), pr.product_name
)
SELECT 
	order_year,
	order_month,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name, order_year) AS avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name, order_year) AS diff_avg,
	CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name, order_year) > 0 THEN 'Above Avg'
		 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name, order_year) < 0 THEN 'Below Avg'
		 ELSE 'Avg'
	END avg_change,
	LAG(current_sales) OVER (PARTITION BY product_name, order_year ORDER BY order_month) AS prev_month_sales,
	current_sales - LAG(current_sales) OVER (PARTITION BY product_name, order_year ORDER BY order_month) AS diff_prev_month,
	CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name, order_year ORDER BY order_month) > 0 THEN 'Increase'
		 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name, order_year ORDER BY order_month) < 0 THEN 'Decrease'
		 ELSE 'No Change'
	END prev_month_change
FROM monthly_product_sales
ORDER BY product_name, order_year, order_month
