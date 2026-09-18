/*
===============================================================================
Create Database and Schemas
===============================================================================

Script Purpose:
    This script creates a new database named 'DataWarehouse'.

    If the database already exists, it is dropped and recreated.

    The script also creates three schemas:
        - bronze
        - silver
        - gold

WARNING:
    Running this script will delete the existing 'DataWarehouse' database
    if it already exists.

    All existing data inside the database will be permanently deleted.

    Use this script only when you are sure that you do not need the
    existing database data.
===============================================================================
*/


/*==============================================================================
STEP 1: USE MASTER DATABASE
==============================================================================*/

USE master;
GO


/*==============================================================================
STEP 2: CHECK IF DATABASE ALREADY EXISTS
==============================================================================*/

IF EXISTS
(
    SELECT 1
    FROM sys.databases
    WHERE name = 'DataWarehouse'
)
BEGIN

    /*
    Set database to SINGLE_USER mode.

    This disconnects other users/connections so that
    SQL Server can safely drop the database.
    */

    ALTER DATABASE DataWarehouse
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    /*
    Delete the existing database.
    */

    DROP DATABASE DataWarehouse;

END
GO


/*==============================================================================
STEP 3: CREATE NEW DATABASE
==============================================================================*/

CREATE DATABASE DataWarehouse;
GO


/*==============================================================================
STEP 4: USE THE NEW DATABASE
==============================================================================*/

USE DataWarehouse;
GO


/*==============================================================================
STEP 5: CREATE BRONZE SCHEMA

Bronze Layer:
    Stores raw data exactly as received from the source.
==============================================================================*/

CREATE SCHEMA bronze;
GO


/*==============================================================================
STEP 6: CREATE SILVER SCHEMA

Silver Layer:
    Stores cleaned and transformed data.
==============================================================================*/

CREATE SCHEMA silver;
GO


/*==============================================================================
STEP 7: CREATE GOLD SCHEMA

Gold Layer:
    Stores business-ready data used for analytics and reporting.
==============================================================================*/

CREATE SCHEMA gold;
GO


/*==============================================================================
DATABASE STRUCTURE CREATED

DataWarehouse
│
├── bronze
│   └── Raw Data
│
├── silver
│   └── Cleaned Data
│
└── gold
    └── Business / Reporting Data
==============================================================================*/
