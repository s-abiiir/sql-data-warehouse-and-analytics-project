
/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - Explore the structure of dimension tables.
	
SQL Functions Used:
    - DISTINCT
    - ORDER BY
===============================================================================
*/

-- EXPLORE THE DIFFERENT COUNTRIES WHERE CUSTOMERS ARE LOCATED
SELECT DISTINCT country
FROM gold.dim_customers
ORDER BY country

-- GET ALL UNIQUE CATEGORIES, SUBCATEGORIES, AND PRODUCTS
SELECT DISTINCT category, subcategory, product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name

-- GET ALL UNIQUE PRODUCT LINES 
SELECT DISTINCT product_line
FROM gold.dim_products
ORDER BY product_line
