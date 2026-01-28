-- Data Cleasing
TRUNCATE TABLE silver.crm_cust_info;
INSERT INTO silver.crm_cust_info(
		cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
)
SELECT
	cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
	CASE 
		WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
	END cst_marital_status,
    CASE 
		WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
	END cst_gndr,
    cst_create_date
FROM (
SELECT 
	*,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL)t WHERE flag_last = 1;



-- Clean & Load crm_prd_info
TRUNCATE TABLE silver.crm_prd_info;
INSERT INTO silver.crm_prd_info (
	prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
	prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, length(prd_key)) AS prd_key,
    prd_nm,
    COALESCE(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
        WHEN'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(LEAD(prd_start_dt) OVER (PARTITION BY SUBSTRING(prd_key, 7, length(prd_key)) ORDER BY prd_start_dt) - INTERVAL 1 DAY AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info;


/*
SELECT DISTINCT id FROM bronze.erp_px_cat_g1v2;
SELECT * FROM bronze.erp_px_cat_g1v2;
SELECT * FROM bronze.erp_loc_a101;
SELECT sls_prd_key from bronze.crm_sales_details;

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost < 0 or prd_cost is null;
*/

-- Data Standardization & Consistency
--  SELECT DISTINCT prd_line FROM bronze.crm_prd_info;

-- Check for Invalid Date Orders
/*
SELECT * FROM
bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

SELECT
	prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;
*/

-- Clean and Load crm_sales_details
TRUNCATE TABLE silver.crm_sales_details;
SELECT
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE
		WHEN sls_order_dt = 0 or LENGTH(sls_order_dt) != 8 THEN null 
        ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
    END sls_order_dt,
	CASE
		WHEN sls_ship_dt = 0 or LENGTH(sls_ship_dt) != 8 THEN null 
        ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
    END sls_ship_dt,
	CASE
		WHEN sls_due_dt = 0 or LENGTH(sls_due_dt) != 8 THEN null 
        ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
    END sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details;


-- Check for invalid
/*
SELECT
	*
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

SELECT
	*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;
*/


-- Check Data Consistency: Between Sales, Quantity, and Price
TRUNCATE TABLE silver.crm_sales_details;
INSERT INTO silver.crm_sales_details (
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
	CASE
		WHEN sls_order_dt = 0 or LENGTH(sls_order_dt) != 8 THEN null 
        ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
    END sls_order_dt,
	CASE
		WHEN sls_ship_dt = 0 or LENGTH(sls_ship_dt) != 8 THEN null 
        ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
    END sls_ship_dt,
	CASE
		WHEN sls_due_dt = 0 or LENGTH(sls_due_dt) != 8 THEN null 
        ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
	END sls_due_dt,
    CASE
		WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END sls_sales,
    sls_quantity,
    CASE 
		WHEN sls_price IS NULL OR sls_price <= 0 THEN 
			CASE
				WHEN COALESCE(sls_quantity, 0) = 0 THEN null
                ELSE sls_sales / sls_quantity
			END
		ELSE sls_price
    END sls_price
FROM bronze.crm_sales_details;

/*
SELECT * FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;
*/
