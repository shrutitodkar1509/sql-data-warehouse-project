/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads raw data from CSV source files into the
    Bronze Layer of the Data Warehouse.

    The procedure performs the following operations:
        - Truncates Bronze tables before loading new data.
        - Loads CRM source data using BULK INSERT.
        - Loads ERP source data using BULK INSERT.
        - Tracks the loading duration of each individual table.
        - Tracks the total duration of the entire Bronze loading batch.
        - Provides execution messages for monitoring the ETL process.
        - Uses TRY...CATCH for error handling and debugging.

Source Systems:
    CRM:
        - cust_info.csv
        - prd_info.csv
        - sales_details.csv

    ERP:
        - CUST_AZ12.csv
        - LOC_A101.csv
        - PX_CAT_G1V2.csv

Target Tables:
    CRM:
        - bronze.crm_cust_info
        - bronze.crm_prd_info
        - bronze.crm_sales_details

    ERP:
        - bronze.erp_cust_az12
        - bronze.erp_loc_a101
        - bronze.erp_px_cat_g1v2

Usage:
    EXEC bronze.load_bronze;

Note:
    Update the CSV file paths according to your local environment before
    executing this procedure.
===============================================================================
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE 
        @start_time       DATETIME,
        @end_time         DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time   DATETIME;

    BEGIN TRY

        -- =====================================================================
        -- START WHOLE BATCH TIMER
        -- =====================================================================

        SET @batch_start_time = GETDATE();

        PRINT '=====================================================';
        PRINT '              LOADING BRONZE LAYER';
        PRINT '=====================================================';


        -- =====================================================================
        -- CRM TABLES
        -- =====================================================================

        PRINT '-----------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-----------------------------------------------------';


        -- =====================================================================
        -- 1. CRM CUSTOMER INFORMATION
        -- =====================================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_cust_info';

        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\path\to\datasets\source_crm\cust_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '-----------------------------------------------------';


        -- =====================================================================
        -- 2. CRM PRODUCT INFORMATION
        -- =====================================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_prd_info';

        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\path\to\datasets\source_crm\prd_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '-----------------------------------------------------';


        -- =====================================================================
        -- 3. CRM SALES DETAILS
        -- =====================================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_sales_details';

        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\path\to\datasets\source_crm\sales_details.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';


        -- =====================================================================
        -- ERP TABLES
        -- =====================================================================

        PRINT '-----------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '-----------------------------------------------------';


        -- =====================================================================
        -- 4. ERP CUSTOMER INFORMATION
        -- =====================================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_cust_az12';

        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\path\to\datasets\source_erp\CUST_AZ12.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '-----------------------------------------------------';


        -- =====================================================================
        -- 5. ERP LOCATION INFORMATION
        -- =====================================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_loc_a101';

        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\path\to\datasets\source_erp\LOC_A101.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';

        PRINT '-----------------------------------------------------';


        -- =====================================================================
        -- 6. ERP PRODUCT CATEGORY INFORMATION
        -- =====================================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\path\to\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
            + ' seconds';


        -- =====================================================================
        -- WHOLE BATCH DURATION
        -- =====================================================================

        SET @batch_end_time = GETDATE();

        PRINT '=====================================================';
        PRINT '          BRONZE LAYER LOAD COMPLETED';
        PRINT '=====================================================';

        PRINT '>> Whole Batch Load Duration: '
            + CAST(
                DATEDIFF(
                    SECOND,
                    @batch_start_time,
                    @batch_end_time
                ) AS NVARCHAR
              )
            + ' seconds';

        PRINT '=====================================================';

    END TRY


    -- =====================================================================
    -- ERROR HANDLING
    -- =====================================================================

    BEGIN CATCH

        PRINT '=====================================================';
        PRINT '        ERROR OCCURRED DURING BRONZE LOADING';
        PRINT '=====================================================';

        PRINT 'Error Number  : '
            + CAST(ERROR_NUMBER() AS NVARCHAR);

        PRINT 'Error Message : '
            + ERROR_MESSAGE();

        PRINT 'Error Line    : '
            + CAST(ERROR_LINE() AS NVARCHAR);

        PRINT 'Error Procedure: '
            + ISNULL(ERROR_PROCEDURE(), 'N/A');

        PRINT '=====================================================';

    END CATCH

END;
GO


-- =============================================================================
-- EXECUTE STORED PROCEDURE
-- =============================================================================

EXEC bronze.load_bronze;
GO
