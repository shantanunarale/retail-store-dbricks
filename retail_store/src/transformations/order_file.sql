CREATE OR REFRESH STREAMING TABLE silver.order_silver(
  CONSTRAINT invalid_amount EXPECT (order_amount < 0)
);

CREATE FLOW order_silver 
AS
INSERT INTO silver.order_silver BY NAME
SELECT
  order_id,
  order_date,
  customer_name,
  customer_address,
  employee_id,
  order_amount,
  inline_outer(line_items)
FROM STREAM orders_raw;

CREATE OR REFRESH MATERIALIZED VIEW gold.orders_gold
AS
SELECT
  r.Name,
  count(s.order_id) AS cnt_order_id
FROM silver.order_silver s
INNER JOIN products_raw r
  ON s.product_id = r.ProdId
GROUP BY ALL  ;