/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segment products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/


-- =============================================================================
-- Create Report: gold.report_products
-- =============================================================================
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS
WITH base_query AS (
-- 1 -- BASE QUERY: RETRIVE CORE COLUMNS FROM TABLES
SELECT 
    sa.order_number,
    sa.order_date,
    sa.customer_key,
    sa.quantity,
    sa.sales_amount,
    pr.product_key,
    pr.product_name,
    pr.category,
    pr.subcategory,
    pr.cost   
FROM gold.fact_sales sa
LEFT JOIN gold.dim_products pr
    ON sa.product_key = pr.product_key
),
product_aggregations AS (
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price   
FROM base_query
GROUP BY product_key, product_name, category, subcategory, cost
)
--3-- FINAL QUERY: COMBINE ALL PRODUCT RESULTS INTO ONE OUTPUT
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(month, last_sale_date, GETDATE()) AS recency_in_months,
    CASE WHEN total_sales > 50000 THEN 'High-Performer'
         WHEN total_sales >= 10000 THEN 'Mid-Range'
         ELSE 'Low-Performer'
    END product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    -- AVERAGE ORDER REVENUE (AOR)
    CASE WHEN total_orders = 0 THEN 0
         ELSE total_sales / total_orders
    END avg_order_revenue,
    -- AVERAGE MONTHLY REVENUE
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE total_sales / lifespan
    END avg_monthly_revenue
FROM product_aggregations
