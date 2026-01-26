USE CATALOG IDENTIFIER(:catalog);
CREATE SCHEMA IF NOT EXISTS misc;
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

-- Create Masking function
CREATE OR REPLACE FUNCTION misc.fnMaskingAdhar(sensetive STRING)
RETURNS STRING
RETURN IF (is_account_group_member('developers'), 'xxxxxx', sensetive);

-- Setup Bronze tables
CREATE TABLE IF NOT EXISTS bronze.employees
(
  EmployeeId    INT,
  StoreId       INT,
  FirstName     STRING,
  LastName      STRING,
  Adhar_Id      STRING MASK misc.fnMaskingAdhar,
  LoadDate      TIMESTAMP,
  BatchId       INT
)
COMMENT 'Bronze Ingestion For Employees'
TBLPROPERTIES('quality'='bronze');

ALTER TABLE bronze.employees
ALTER COLUMN Adhar_Id
SET TAGS ('pii' = 'Aadhar');

CREATE TABLE IF NOT EXISTS bronze.stores
(
  StoreId       INT,
  StoreName     STRING,
  StoreAdd      STRING,
  LoadDate      TIMESTAMP,
  BatchId       INT
)
COMMENT 'Bronze Ingestion For Stores'
TBLPROPERTIES('quality'='bronze');
