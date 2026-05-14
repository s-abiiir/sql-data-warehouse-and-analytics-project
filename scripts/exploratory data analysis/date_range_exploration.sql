/*
===============================================================================
Date Range Exploration 
===============================================================================
Purpose:
    - Explore the time boundaries of key business events (orders, shipping, due dates).
    - Measure the temporal coverage of the dataset across different date fields.
    - Analyze processing and delivery times (order-to-shipping, shipping-to-due).
    - Understand customer age distribution using birthdate information.
	

SQL Functions Used:
    - MIN(), MAX(), AVG(), DATEDIFF()
===============================================================================
*/


-- FIND THE FIRST AND LAST ORDER DATES
-- CALCULATE THE TIME SPAN BETWEEN THE FIRST AND LAST ORDER DATES (IN MONTHS)
SELECT 
	MIN(order_date) AS first_order,
	MAX(order_date) AS last_order,
	DATEDIFF(month, MIN(order_date),MAX(order_date)) AS order_range_month
FROM gold.fact_sales


-- FIND THE FIRST AND LAST SHIPPING DATES
-- CALCULATE THE TIME SPAN BETWEEN THE FIRST AND LAST SHIPPING DATES (IN MONTHS)
SELECT 
	MIN(shipping_date) AS first_shipping,
	MAX(shipping_date) AS last_shipping,
	DATEDIFF(month, MIN(shipping_date),MAX(shipping_date)) AS shipping_range_month
FROM gold.fact_sales


-- FIND THE FIRST AND LAST DUE DATES
-- CALCULATE THE TIME SPAN BETWEEN THE FIRST AND LAST DUE DATES (IN MONTHS)
SELECT 
	MIN(due_date) AS first_due,
	MAX(due_date) AS last_due,
	DATEDIFF(month, MIN(due_date),MAX(due_date)) AS due_range_month
FROM gold.fact_sales


-- CALCULATE THE AVERAGE TIME BETWEEN ORDER DATE AND SHIPPING DATE IN DAYS
SELECT AVG(DATEDIFF(day,order_date,shipping_date)) AS order_to_shipping_days
FROM gold.fact_sales


-- CALCULATE THE AVERAGE TIME BETWEEN SHIPPING DATE AND DUE DATE IN DAYS (DELIVERY PERFORMANCE)
SELECT AVG(DATEDIFF(day,shipping_date,due_date)) AS shipping_to_due_days
FROM gold.fact_sales


-- FIND THE YOUNGEST AND THE OLDEST CUSTOMER
SELECT 
	MIN(birthdate) AS oldest_birthdate,
	DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
	MAX(birthdate) AS youngest_birthdate,
	DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers
