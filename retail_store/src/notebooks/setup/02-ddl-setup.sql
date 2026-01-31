USE CATALOG IDENTIFIER(:catalog);
CREATE SCHEMA IF NOT EXISTS misc;
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

-- Create Masking function
CREATE OR REPLACE FUNCTION misc.fnMaskingAdhar(sensetive STRING)
RETURNS STRING
RETURN IF (is_account_group_member('developers'), 'xxxxxx', sensetive);

CREATE OR REPLACE FUNCTION misc.fnMaskAddress(addr STRING)
RETURNS STRING
RETURN IF (is_account_group_member('developers'), 'xxxxxx' || RIGHT(addr, 7), addr);

CREATE OR REPLACE FUNCTION misc.fnMaskName(addr STRING)
RETURNS STRING
RETURN IF (is_account_group_member('developers'), MASK(addr, NULL, 'x'), addr);



-- Setup Bronze tables
CREATE TABLE IF NOT EXISTS bronze.orders
(
  order_id STRING,
  order_date STRING,
  customer_name STRING MASK misc.fnMaskName,
  customer_address STRING MASK misc.fnMaskAddress,
  employee_id STRING,
  order_amount STRING,
  line_items STRING,
  _rescued_data STRING,
  load_date TIMESTAMP,
  file_name STRING
)
COMMENT 'Bronze table for Order Ingestion'
TBLPROPERTIES ('quality'='bronze');

ALTER TABLE bronze.orders
ALTER COLUMN customer_address
SET TAGS ('pii' = 'Address');

ALTER TABLE bronze.orders
ALTER COLUMN customer_address
SET TAGS ('pii' = 'Name');


CREATE TABLE IF NOT EXISTS bronze.products
(
  ProdId      INT,
  Name        STRING,
  Brand       STRING,
  Color       STRING,
  Category    STRING,
  LoadDate    TIMESTAMP
)
COMMENT 'Bronze Ingestion For Products'
TBLPROPERTIES('quality'='bronze', 'delta.feature.allowColumnDefaults' = 'supported');

ALTER TABLE bronze.products
ALTER COLUMN LoadDate SET DEFAULT current_timestamp();

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

--Setup Silver tables
CREATE TABLE IF NOT EXISTS silver.orders_cleansed
(
  order_id STRING,
  order_date TIMESTAMP,
  customer_name STRING MASK misc.fnMaskName,
  customer_address STRING MASK misc.fnMaskAddress,
  employee_id INT,
  order_amount DOUBLE,
  line_items ARRAY<STRUCT<product_id: INT, quantity: INT>>,
  _rescued_data STRING,
  load_date TIMESTAMP,
  file_name STRING,
  pincode INT
)
COMMENT 'Silver table for Order Cleansing'
TBLPROPERTIES ('quality'='Silver');

ALTER TABLE silver.orders_cleansed
ALTER COLUMN customer_address
SET TAGS ('pii' = 'Address');

ALTER TABLE silver.orders_cleansed
ALTER COLUMN customer_address
SET TAGS ('pii' = 'Name');

CREATE TABLE IF NOT EXISTS silver.fact_orders
(
  fact_order_id LONG GENERATED ALWAYS AS IDENTITY(START WITH 1 INCREMENT BY 1),
  order_id STRING,
  order_date TIMESTAMP,  
  employee_id INT,
  customer_pincode INT,
  order_amount DOUBLE,
  product_id INT,
  quantity INT,  
  load_date TIMESTAMP  
)
COMMENT 'Silver table for Order Cleansing'
TBLPROPERTIES ('quality'='Silver');


CREATE TABLE IF NOT EXISTS silver.employees
(
  EmployeeId    INT,
  StoreId       INT,
  FirstName     STRING,
  LastName      STRING,
  Adhar_Id      STRING MASK misc.fnMaskingAdhar,
  LoadDate      TIMESTAMP,
  BatchId       INT
)
COMMENT 'Silver Ingestion For Employees'
TBLPROPERTIES('quality'='silver');

ALTER TABLE silver.employees
ALTER COLUMN Adhar_Id
SET TAGS ('pii' = 'Aadhar');

CREATE TABLE IF NOT EXISTS silver.stores
(
  StoreId       INT,
  StoreName     STRING,
  StoreAdd      STRING,
  LoadDate      TIMESTAMP,
  BatchId       INT
)
COMMENT 'Silver Ingestion For Stores'
TBLPROPERTIES('quality'='silver');

CREATE TABLE IF NOT EXISTS silver.store_employees
(
  StoreEmpId      LONG GENERATED ALWAYS AS IDENTITY (START WITH 1 INCREMENT BY 1),  
  EmployeeId      INT,  
  FullName        STRING,
  StoreName       STRING,
  __start_at      DATE,
  __end_at        DATE,
  IsActive        BOOLEAN
)
COMMENT 'Silver Ingestion For Store Employees'
TBLPROPERTIES('quality'='silver', 'type' = 'SCD Type 2 Dimension');

CREATE TABLE IF NOT EXISTS silver.product
(
  ProdId      INT,
  Name        STRING,
  Brand       STRING,
  Color       STRING,
  Category    STRING
)
COMMENT 'Silver Ingestion For Products'
TBLPROPERTIES('quality'='silver', 'type' = 'SCD Type 1 Dimension');
