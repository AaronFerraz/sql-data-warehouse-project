-- ERP Cleasing
-- Clean & Load erp_cust_az12
TRUNCATE TABLE silver.erp_cust_az12;
INSERT INTO silver.erp_cust_az12 (
	cid,
    bdate, 
    gen
)
SELECT
    CASE
		WHEN cid like 'NAS%' THEN SUBSTRING(cid, 4, length(cid))
        ELSE cid
    END cid,
    CASE
		WHEN bdate > NOW() THEN NULL
        ELSE bdate 
    END bdate,
    CASE
		WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END gen
FROM bronze.erp_cust_az12;

-- Identify Out-of-Range Dates
/*
SELECT distinct
	bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > NOW();

SELECT distinct
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > NOW();

SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

SELECT * FROM silver.crm_cust_info;
*/


-- Clean & Load erp_loc_a101
TRUNCATE silver.erp_loc_a101;
INSERT INTO silver.erp_loc_a101 (
	cid,
	cntry
)
SELECT
	REPLACE(cid, '-', '') cid,
    CASE
		WHEN TRIM(cntry) in ('USA', 'US') THEN 'United States'
		WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IS NULL or TRIM(cntry) = '' THEN 'n/a' 
        ELSE TRIM(cntry)
    END cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;

-- Data Standardization & Consistency
--  SELECT DISTINCT cntry FROM bronze.erp_loc_a101;

 
--  SELECT * FROM silver.erp_loc_a101;
	


-- Clean & Load erp_px_cat_g1v2
TRUNCATE TABLE silver.erp_px_cat_g1v2;
INSERT INTO silver.erp_px_cat_g1v2(
	id,
    cat,
    subcat,
    maintenance
)
SELECT 
	id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;


-- Check for unwanted spaces
--  SELECT * FROM bronze.erp_px_cat_g1v2
--  WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR TRIM(maintenance);

-- Data Standardization & Consistency
/*
SELECT DISTINCT
	cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT
	subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT
	maintenance
FROM bronze.erp_px_cat_g1v2;



SELECT * FROM silver.erp_px_cat_g1v2
*/

 
