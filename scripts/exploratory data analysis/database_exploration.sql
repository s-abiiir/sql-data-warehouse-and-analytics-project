/*
===============================================================================
Database Exploration
===============================================================================
Purpose:
    - Explore the structure of the database, including the list of tables and their schemas.
    - Inspect the columns and metadata for specific tables.

===============================================================================
*/

-- EXPLORE ALL OBJECTS IN THE DATABASE
SELECT * FROM INFORMATION_SCHEMA.TABLES


-- EXPLORE ALL COLUMNS IN THE DATABASE FOR A SPECIFIC TABLE (dim_customers)
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'
