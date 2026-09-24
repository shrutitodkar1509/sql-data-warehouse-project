This stored procedure loads and transforms data from the Bronze Layer into the Silver Layer.

It performs the following operations:

Truncates all Silver Layer tables before loading fresh data.
Cleans and standardizes customer, product, sales, location, and category data.
Removes duplicate customer records using ROW_NUMBER().
Handles NULL and invalid values.
Standardizes gender, marital status, country names, and product line values.
Converts raw date values into proper DATE format.
Calculates product end dates using the LEAD() window function.
Recalculates invalid sales and price values.
Loads cleaned CRM and ERP data into Silver tables.
Tracks execution time for each table load.
Calculates total Silver Layer load duration.
Uses TRY...CATCH for error handling and displays detailed error information.

Source Layer: Bronze
Target Layer: Silver
Process: Data Cleaning, Transformation, Standardization, Deduplication, Validation, and Loading.

  
EXEC silver.load_silver
CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN

    DECLARE @start_time DATETIME,
            @end_time DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '===========================================';
        PRINT '          LOADING SILVER LAYER';
        PRINT '===========================================';


        -- =====================================================
        -- LOAD CRM TABLES
        -- =====================================================

        PRINT '-------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-------------------------------------------';


        -- =====================================================
        -- 1. CRM CUSTOMER INFO
        -- =====================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_cust_info';

        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: silver.crm_cust_info';

        INSERT INTO silver.crm_cust_info
        (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_material_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,

            CASE
                WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status,

            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,

            cst_create_date

        FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC
                ) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t

        WHERE flag_last = 1;


        SET @end_time = GETDATE();

        PRINT '>> crm_cust_info Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';

        PRINT '-------------------------------------------';


        -- =====================================================
        -- 2. CRM PRODUCT INFO
        -- =====================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_prd_info';

        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting Data Into: silver.crm_prd_info';

        INSERT INTO silver.crm_prd_info
        (
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

            REPLACE(
                SUBSTRING(prd_key, 1, 5),
                '-',
                '_'
            ) AS cat_id,

            SUBSTRING(
                prd_key,
                7,
                LEN(prd_key)
            ) AS prd_key,

            prd_nm,

            ISNULL(prd_cost, 0) AS prd_cost,

            CASE
                WHEN UPPER(TRIM(prd_line)) = 'M'
                    THEN 'Mountain'

                WHEN UPPER(TRIM(prd_line)) = 'R'
                    THEN 'Road'

                WHEN UPPER(TRIM(prd_line)) = 'S'
                    THEN 'Station'

                WHEN UPPER(TRIM(prd_line)) = 'T'
                    THEN 'Touring'

                ELSE 'n/a'

            END AS prd_line,

            CAST(
                prd_start_dt AS DATE
            ) AS prd_start_dt,

            CAST(
                DATEADD(
                    DAY,
                    -1,
                    LEAD(prd_start_dt) OVER
                    (
                        PARTITION BY prd_key
                        ORDER BY prd_start_dt
                    )
                )
                AS DATE
            ) AS prd_end_dt

        FROM bronze.crm_prd_info;


        SET @end_time = GETDATE();

        PRINT '>> crm_prd_info Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';

        PRINT '-------------------------------------------';


        -- =====================================================
        -- 3. CRM SALES DETAILS
        -- =====================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.crm_sales_details';

        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting Data Into: silver.crm_sales_details';

        INSERT INTO silver.crm_sales_details
        (
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
                WHEN sls_order_dt = 0
                     OR LEN(sls_order_dt) != 8
                    THEN NULL

                ELSE CAST(
                    CAST(sls_order_dt AS VARCHAR)
                    AS DATE
                )

            END AS sls_order_dt,


            CASE
                WHEN sls_ship_dt = 0
                     OR LEN(sls_ship_dt) != 8
                    THEN NULL

                ELSE CAST(
                    CAST(sls_ship_dt AS VARCHAR)
                    AS DATE
                )

            END AS sls_ship_dt,


            CASE
                WHEN sls_due_dt = 0
                     OR LEN(sls_due_dt) != 8
                    THEN NULL

                ELSE CAST(
                    CAST(sls_due_dt AS VARCHAR)
                    AS DATE
                )

            END AS sls_due_dt,


            CASE
                WHEN sls_sales IS NULL
                     OR sls_sales <= 0
                     OR sls_sales != sls_quantity * ABS(sls_price)

                    THEN sls_quantity * ABS(sls_price)

                ELSE sls_sales

            END AS sls_sales,


            sls_quantity,


            CASE
                WHEN sls_price IS NULL
                     OR sls_price <= 0

                    THEN ABS(sls_sales)
                         / NULLIF(sls_quantity, 0)

                ELSE sls_price

            END AS sls_price

        FROM bronze.crm_sales_details;


        SET @end_time = GETDATE();

        PRINT '>> crm_sales_details Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';


        -- =====================================================
        -- LOAD ERP TABLES
        -- =====================================================

        PRINT '===========================================';
        PRINT 'Loading ERP Tables';
        PRINT '===========================================';


        -- =====================================================
        -- 4. ERP CUSTOMER INFO
        -- =====================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_cust_az12';

        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Inserting Data Into: silver.erp_cust_az12';

        INSERT INTO silver.erp_cust_az12
        (
            cid,
            bdate,
            gen
        )

        SELECT

            CASE
                WHEN cid LIKE 'NAS%'
                    THEN SUBSTRING(cid, 4, LEN(cid))

                ELSE cid

            END AS cid,


            CASE
                WHEN bdate > GETDATE()
                    THEN NULL

                ELSE bdate

            END AS bdate,


            CASE
                WHEN UPPER(TRIM(gen))
                     IN ('F', 'FEMALE')
                    THEN 'Female'

                WHEN UPPER(TRIM(gen))
                     IN ('M', 'MALE')
                    THEN 'Male'

                ELSE 'n/a'

            END AS gen

        FROM bronze.erp_cust_az12;


        SET @end_time = GETDATE();

        PRINT '>> erp_cust_az12 Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';

        PRINT '-------------------------------------------';


        -- =====================================================
        -- 5. ERP LOCATION INFO
        -- =====================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_loc_a101';

        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Inserting Data Into: silver.erp_loc_a101';

        INSERT INTO silver.erp_loc_a101
        (
            cid,
            cntry
        )

        SELECT

            REPLACE(
                cid,
                '-',
                ''
            ) AS cid,


            CASE
                WHEN TRIM(cntry) = 'DE'
                    THEN 'Germany'

                WHEN TRIM(cntry)
                     IN ('US', 'USA')
                    THEN 'United States'

                WHEN TRIM(cntry) = ''
                     OR cntry IS NULL
                    THEN 'n/a'

                ELSE TRIM(cntry)

            END AS cntry

        FROM bronze.erp_loc_a101;


        SET @end_time = GETDATE();

        PRINT '>> erp_loc_a101 Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';

        PRINT '-------------------------------------------';


        -- =====================================================
        -- 6. ERP PRODUCT CATEGORY INFO
        -- =====================================================

        SET @start_time = GETDATE();

        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';

        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';

        INSERT INTO silver.erp_px_cat_g1v2
        (
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


        SET @end_time = GETDATE();

        PRINT '>> erp_px_cat_g1v2 Load Duration: '
              + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR)
              + ' seconds';


        -- =====================================================
        -- TOTAL BATCH DURATION
        -- =====================================================

        SET @batch_end_time = GETDATE();

        PRINT '===========================================';
        PRINT 'SILVER LAYER LOADING COMPLETED';
        PRINT 'Total Load Duration: '
              + CAST(
                    DATEDIFF(
                        SECOND,
                        @batch_start_time,
                        @batch_end_time
                    )
                    AS NVARCHAR
                )
              + ' seconds';
        PRINT '===========================================';


    END TRY


    BEGIN CATCH

        PRINT '===========================================';
        PRINT 'ERROR OCCURRED DURING SILVER LAYER LOADING';
        PRINT '===========================================';

        PRINT 'Error Number: '
              + CAST(ERROR_NUMBER() AS NVARCHAR);

        PRINT 'Error Message: '
              + ERROR_MESSAGE();

        PRINT 'Error Line: '
              + CAST(ERROR_LINE() AS NVARCHAR);

        PRINT 'Error Procedure: '
              + ISNULL(ERROR_PROCEDURE(), 'N/A');

        PRINT '===========================================';

    END CATCH

END;
GO


-- =====================================================
-- EXECUTE SILVER LOAD
-- =====================================================

EXEC silver.load_silver;
GO
