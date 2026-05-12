/* 
=========================================================================================================
Quality Checks
=========================================================================================================
Script Purpose:
  This script performs various quality checks for data consistency, accuracy, and standardization across
  the 'silver' schema. It includes checks for:
  - Null or duplicate primary keys
  - Unwanted spaces in string fields
  - Data standardization and consistency
  - Invalid date ranges and orders
  - Data consistency between related fields.

Note: Run these checks after loading the data to the silver layer
=========================================================================================================
*/

-- ======================================================================================================
-- Checking 'silver.crm_cust_info'
-- ======================================================================================================

-- CHECK FOR NULLS AND DUPLICATES IN PRIMARY KEY
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

-- CHECK FOR UNWANTED SPACES IN STRING DATA TYPE COLUMNS
SELECT
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr
FROM silver.crm_cust_info
WHERE 
	cst_key != TRIM(cst_key) 
  OR cst_firstname != TRIM(cst_firstname) 
  OR cst_lastname != TRIM(cst_lastname) 
  OR cst_marital_status != TRIM(cst_marital_status) 
  OR cst_gndr != TRIM(cst_gndr)

-- DATA STANDARDIZATION & CONSISTENCY
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info


-- ======================================================================================================
-- Checking 'silver.crm_prd_info'
-- ======================================================================================================

-- CHECK FOR NULLS & DUPLICATES IN PRIMARY KEY
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- CHECK FOR UNWANTED SPACES IN STRING DATA TYPE COLUMNS
SELECT prd_key, prd_nm, prd_line
FROM silver.crm_prd_info
WHERE 
	prd_key != TRIM(prd_key) OR
	prd_nm != TRIM(prd_nm) OR 
	prd_line != TRIM(prd_line)

-- CHECK FOR NULLS AND NEGATIVE NUMBERS
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- DATA STANDARDIZATION & CONSISTENCY
SELECT DISTINCT prd_line
FROM silver.crm_prd_info
	
-- CHECK FOR INVALID DATE ORDERS
SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt
ORDER BY prd_id


-- ======================================================================================================
-- Checking 'silver.crm_sales_details'
-- ======================================================================================================

-- CHECK FOR UNWANTED SPACES
SELECT sls_ord_num, sls_prd_key
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num) AND sls_prd_key != TRIM(sls_prd_key)

-- CHECK FOR INVALID DATES
SELECT sls_order_dt
FROM silver.crm_sales_details
WHERE 
	sls_order_dt > CAST('2050-01-01' AS DATE)
	OR sls_order_dt < CAST('1900-01-01' AS DATE)

SELECT sls_ship_dt
FROM silver.crm_sales_details
WHERE 
	sls_ship_dt > CAST('2050-01-01' AS DATE)
	OR sls_ship_dt < CAST('1900-01-01' AS DATE)

SELECT sls_due_dt
FROM silver.crm_sales_details
WHERE 
	sls_due_dt > CAST('2050-01-01' AS DATE)
	OR sls_due_dt < CAST('1900-01-01' AS DATE)

-- CHECK FOR INVALID DATE ORDERS
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

SELECT *
FROM silver.crm_sales_details
WHERE sls_ship_dt > sls_due_dt 

-- CHECK DATA CONSISTENCY: BETWEEN SALES, QUANTITY AND PRICE
-- >> SALES = QUANTITY * PRICE
-- >> VALUES MUST NOT BE NULL, ZERO OR NEGATIVE
SELECT *
FROM silver.crm_sales_details
WHERE 
	sls_sales != sls_price * sls_quantity
	OR sls_sales <= 0 OR sls_price <= 0 OR sls_quantity <= 0
	OR sls_sales IS NULL OR sls_price IS NULL OR sls_quantity IS NULL
ORDER BY sls_sales, sls_quantity, sls_price


-- ======================================================================================================
-- Checking 'silver.erp_cust_az12'
-- ======================================================================================================

-- CHECK FOR NULL AND DUPLICATES IN PRIMARY KEY
SELECT cid, COUNT(*)
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL

-- CHECK FOR UNWANTED SPACES
SELECT cid, gen
FROM silver.erp_cust_az12
WHERE cid != TRIM(cid) OR gen != TRIM(gen)

-- DATA STANDARDIZATION AND CONSISTENCY
SELECT DISTINCT gen
FROM silver.erp_cust_az12

-- IDENTIFY OUT-OF-RANGE DATES
SELECT * 
FROM silver.erp_cust_az12
WHERE bdate > GETDATE()

-- ======================================================================================================
-- Checking 'silver.erp_loc_a101'
-- ======================================================================================================

-- CHECK FOR UNWANTED SPACES 
SELECT *
FROM silver.erp_loc_a101
WHERE cid != TRIM(cid) OR cntry != TRIM(cntry)

-- CHECK STANDARDIZATION AND CONSISTENCY
SELECT DISTINCT cntry 
FROM silver.erp_loc_a101


-- ======================================================================================================
-- Checking 'silver.erp_loc_a101'
-- ======================================================================================================

-- CHECK FOR NULLS AND DUPLICATES IN PRIMARY KEY
SELECT id, COUNT(*)
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL

-- CHECK FOR UNWANTED SPACES
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE
	id != TRIM(id)
	OR cat != TRIM(cat)
	OR subcat != TRIM(subcat)
	OR maintenance != TRIM(maintenance)

-- DATA STANDARDIZATION AND CONSISTENCY
SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2

SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2




