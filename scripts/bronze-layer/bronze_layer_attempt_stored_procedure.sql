DELIMITER //
DROP PROCEDURE IF EXISTS bronze.load_bronze //
CREATE PROCEDURE bronze.load_bronze()
BEGIN
	BEGIN TRY
		SELECT 'Loading Bronze Layer' AS Mensagem;
		
		SELECT 'Loading CRM Tables' AS Mensagem;
		TRUNCATE TABLE bronze.crm_cust_info;
		LOAD DATA LOCAL INFILE 'C:\\Users\\AARON\\Documents\\Dev\\Databases\\Projetos\\sql-data-warehouse-project\\datasets\\source_crm\\cust_info.csv'
		INTO TABLE bronze.crm_cust_info
		FIELDS TERMINATED BY ','
		LINES TERMINATED BY '\r\n'
		IGNORE 1 ROWS;

		TRUNCATE TABLE bronze.crm_prd_info;
		LOAD DATA LOCAL INFILE 'C:\\Users\\AARON\\Documents\\Dev\\Databases\\Projetos\\sql-data-warehouse-project\\datasets\\source_crm\\prd_info.csv'
		INTO TABLE bronze.crm_prd_info
		FIELDS TERMINATED BY ','
		LINES TERMINATED BY '\r\n'
		IGNORE 1 ROWS;

		TRUNCATE TABLE bronze.crm_sales_details;
		LOAD DATA LOCAL INFILE 'C:\\Users\\AARON\\Documents\\Dev\\Databases\\Projetos\\sql-data-warehouse-project\\datasets\\source_crm\\sales_details.csv'
		INTO TABLE bronze.crm_sales_details
		FIELDS TERMINATED BY ','
		LINES TERMINATED BY '\r\n'
		IGNORE 1 ROWS;

		SELECT 'Loading ERP Tables' AS Mensagem;
		TRUNCATE TABLE bronze.erp_cust_az12;
		LOAD DATA LOCAL INFILE 'C:\\Users\\AARON\\Documents\\Dev\\Databases\\Projetos\\sql-data-warehouse-project\\datasets\\source_erp\\CUST_AZ12.csv'
		INTO TABLE bronze.erp_cust_az12
		FIELDS TERMINATED BY ','
		LINES TERMINATED BY '\r\n'
		IGNORE 1 ROWS;

		TRUNCATE TABLE bronze.erp_loc_a101;
		LOAD DATA LOCAL INFILE 'C:\\Users\\AARON\\Documents\\Dev\\Databases\\Projetos\\sql-data-warehouse-project\\datasets\\source_erp\\LOC_A101.csv'
		INTO TABLE bronze.erp_loc_a101
		FIELDS TERMINATED BY ','
		LINES TERMINATED BY '\r\n'
		IGNORE 1 ROWS;

		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		LOAD DATA LOCAL INFILE 'C:\\Users\\AARON\\Documents\\Dev\\Databases\\Projetos\\sql-data-warehouse-project\\datasets\\source_erp\\PX_CAT_G1V2.csv'
		INTO TABLE bronze.erp_px_cat_g1v2
		FIELDS TERMINATED BY ','
		LINES TERMINATED BY '\r\n'
		IGNORE 1 ROWS;
    END TRY
    BEGIN CATCH
		SELECT 'Error Occured During Loading Bronze Layer' AS Mensagem;
    END CATCH
END //

DELIMITER ;

CALL bronze.load_bronze();

-- Configuração para o código acima executar
SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile'; -- se for ativado, aparece ON


SELECT COUNT(*) FROM bronze.crm_cust_info;
SELECT * FROM bronze.crm_cust_info LIMIT 1;

SELECT * FROM bronze.erp_px_cat_g1v2;


