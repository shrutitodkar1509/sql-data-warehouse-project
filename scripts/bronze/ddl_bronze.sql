/*
===============================================================================
Stored Procedure: bronze.load_bronze
===============================================================================

Script Purpose:
    This stored procedure loads raw CRM and ERP data from CSV files
    into the Bronze Layer of the Data Warehouse.

    It performs the following steps:

    1. Truncates existing Bronze tables.
    2. Loads fresh data using BULK INSERT.
    3. Calculates load duration for each table.
    4. Calculates the total duration of the whole Bronze batch.
    5. Uses transactions to maintain data consistency.
    6. Uses TRY...CATCH for error handling.
    7. Rolls back the transaction if any load fails.

Source Systems:
    - CRM (Customer Relationship Management)
    - ERP (Enterprise Resource Planning)

Target Tables:
    CRM:
        - bronze.crm_cust_info
        - bronze.crm_prd_info
        - bronze.crm_sales_details

    ERP:
        - bronze.erp_loc_a101
        - bronze.erp_cust_az12
        - bronze.erp_px_cat_g1v2
Usage Example:
EXEC bronze.load_bronze;

Important:
    Existing Bronze Layer data will be deleted before fresh data is loaded
    because TRUNCATE TABLE is used.

===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @start_time DATETIME2;
    DECLARE @end_time DATETIME2;
    DECLARE @batch_start_time DATETIME2;
    DECLARE @batch_end_time DATETIME2;
    DECLARE @duration INT;

    SET @start_time = SYSDATETIME();

    PRINT 'Loading Bronze Layer';
    PRINT '============================================================';
    PRINT '';

    BEGIN TRY

        BEGIN TRANSACTION;

        /*==========================================================
          CRM TABLES
        ==========================================================*/

        PRINT '------------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------------------';


        /* CRM CUSTOMER INFO */

        SET @batch_start_time = SYSDATETIME();

        PRINT '>> Truncating Table: bronze.crm_cust_info';

        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\EU-ITAdmin\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @batch_end_time = SYSDATETIME();

        SET @duration =
            DATEDIFF(SECOND, @batch_start_time, @batch_end_time);

        PRINT '>> Load Duration: '
              + CAST(@duration AS VARCHAR(10))
              + ' seconds';

        PRINT '>> ---------------------------------------------------------';


        /* CRM PRODUCT INFO */

        SET @batch_start_time = SYSDATETIME();

        PRINT '>> Truncating Table: bronze.crm_prd_info';

        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\EU-ITAdmin\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @batch_end_time = SYSDATETIME();

        SET @duration =
            DATEDIFF(SECOND, @batch_start_time, @batch_end_time);

        PRINT '>> Load Duration: '
              + CAST(@duration AS VARCHAR(10))
              + ' seconds';

        PRINT '>> ---------------------------------------------------------';


        /* CRM SALES DETAILS */

        SET @batch_start_time = SYSDATETIME();

        PRINT '>> Truncating Table: bronze.crm_sales_details';

        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\EU-ITAdmin\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @batch_end_time = SYSDATETIME();

        SET @duration =
            DATEDIFF(SECOND, @batch_start_time, @batch_end_time);

        PRINT '>> Load Duration: '
              + CAST(@duration AS VARCHAR(10))
              + ' seconds';

        PRINT '>> ---------------------------------------------------------';


        /*==========================================================
          ERP TABLES
        ==========================================================*/

        PRINT '';
        PRINT '------------------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------------------';


        /* ERP LOCATION */

        SET @batch_start_time = SYSDATETIME();

        PRINT '>> Truncating Table: bronze.erp_loc_a101';

        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\EU-ITAdmin\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @batch_end_time = SYSDATETIME();

        SET @duration =
            DATEDIFF(SECOND, @batch_start_time, @batch_end_time);

        PRINT '>> Load Duration: '
              + CAST(@duration AS VARCHAR(10))
              + ' seconds';

        PRINT '>> ---------------------------------------------------------';


        /* ERP CUSTOMER */

        SET @batch_start_time = SYSDATETIME();

        PRINT '>> Truncating Table: bronze.erp_cust_az12';

        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\EU-ITAdmin\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @batch_end_time = SYSDATETIME();

        SET @duration =
            DATEDIFF(SECOND, @batch_start_time, @batch_end_time);

        PRINT '>> Load Duration: '
              + CAST(@duration AS VARCHAR(10))
              + ' seconds';

        PRINT '>> ---------------------------------------------------------';


        /* ERP PRODUCT CATEGORY */

        SET @batch_start_time = SYSDATETIME();

        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';

        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\EU-ITAdmin\Downloads\sql-data-warehouse-project (1)\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @batch_end_time = SYSDATETIME();

        SET @duration =
            DATEDIFF(SECOND, @batch_start_time, @batch_end_time);

        PRINT '>> Load Duration: '
              + CAST(@duration AS VARCHAR(10))
              + ' seconds';

        PRINT '>> ---------------------------------------------------------';


        COMMIT TRANSACTION;

        SET @end_time = SYSDATETIME();

        PRINT '';
        PRINT '============================================================';
        PRINT 'Loading Bronze Layer Completed';
        PRINT '============================================================';

        PRINT 'Total Load Duration: '
              + CAST(
                    DATEDIFF(SECOND, @start_time, @end_time)
                    AS VARCHAR(10)
                )
              + ' seconds';


    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        PRINT '';
        PRINT '============================================================';
        PRINT 'ERROR OCCURRED WHILE LOADING BRONZE LAYER';
        PRINT '============================================================';

        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line: '
              + CAST(ERROR_LINE() AS VARCHAR(10));

        THROW;

    END CATCH

END;
GO
