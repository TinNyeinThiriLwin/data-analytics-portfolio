T976582.d3_sales
T976582.d3_customers

Step 1: Understand the Data Structure

SELECT 
column_name
, data_type
, is_nullable 
FROM v_catalog.columns 
WHERE table_name = 'd3_sales'; 


SELECT 
column_name
, data_type
, is_nullable 
FROM v_catalog.columns 
WHERE table_name = 'd3_customers'; 

SELECT * FROM T976582.d3_sales LIMIT 10;
SELECT COUNT(*) FROM T976582.d3_sales; 

SELECT * FROM T976582.d3_customers LIMIT 10;
SELECT COUNT(*) FROM T976582.d3_customers;
-------------------------------------------------------------
Step 2 : Data Quality Checking

SELECT 
COUNT(*)-COUNT(Order_id) AS Missing_Order,
COUNT(*)-COUNT(user_id) AS Missing_User ,
COUNT(*)-COUNT(order_timestamp) AS Missing_Time ,
COUNT(*)-COUNT(product_id) AS Missing_Product,
COUNT(*)-COUNT(product_category) AS Missing_Product_Category,
COUNT(*)-COUNT(product_price) AS Missing_Price,
COUNT(*)-COUNT(quantity) AS Missing_Quantity
FROM T976582.d3_sales;                        ---------- NO missing values

SELECT 
COUNT(*)-COUNT(user_id) AS Missing_User ,
COUNT(*)-COUNT(name) AS Missing_name ,
COUNT(*)-COUNT(gender) AS Missing_gender,
COUNT(*)-COUNT(age) AS Missing_age,
COUNT(*)-COUNT(location) AS Missing_location
FROM T976582.d3_customers;                     ---------- NO missing values

SELECT 
order_id
,user_id
,order_timestamp
,product_id
,product_category
,product_price	
,quantity
,COUNT(*)
FROM T976582.d3_sales 
GROUP BY 1,2,3,4,5,6,7
HAVING COUNT(*) >1 ;                           ---------- No Duplicates
 
SELECT 
  DISTINCT user_id, name, gender, age, location, COUNT(*)
FROM T976582.d3_customers
GROUP BY 1,2,3,4,5
HAVING COUNT(*) > 1;                           ---------- No Duplicates 

SELECT COUNT(DISTINCT Order_id) FROM T976582.d3_sales;  -- 3000 
SELECT COUNT(DISTINCT user_id) FROM T976582.d3_sales;   -- 498 
SELECT DISTINCT product_id FROM T976582.d3_sales;
SELECT DISTINCT product_category  FROM T976582.d3_sales;
SELECT DISTINCT product_id ,product_category FROM T976582.d3_sales;
SELECT DISTINCT product_id ,product_category FROM T976582.d3_sales;
SELECT MIN(order_timestamp) , MAX(order_timestamp) FROM T976582.d3_sales;

SELECT COUNT(*) FROM T976582.d3_customers;
SELECT COUNT(DISTINCT name) FROM T976582.d3_customers;
SELECT COUNT(DISTINCT user_id) FROM T976582.d3_customers;

SELECT 
COUNT(*) Total_Rows,
COUNT(DISTINCT user_id) AS Total_ID ,
COUNT(DISTINCT name) AS Total_Name 
FROM T976582.d3_customers; 

SELECT 
  name,
  COUNT(DISTINCT user_id) AS user_count
FROM T976582.d3_customers
GROUP BY name
HAVING COUNT(DISTINCT user_id) > 1;
--


-------------------------------------------------------------------------------------------------------

Step 3 : Detecting Outliers 


WITH stats AS (
  SELECT 
    AVG(quantity) AS avg_qty,
    STDDEV(quantity) AS std_qty,
    AVG(product_price) AS avg_price,
    STDDEV(product_price) AS std_price
  FROM t976582.d3_sales
)
SELECT 
  order_id,
  user_id,
  order_timestamp,
  product_id,
  product_category,
  product_price,
  quantity,
  CASE 
    WHEN quantity < (avg_qty - 2 * std_qty) OR 
         quantity > (avg_qty + 2 * std_qty) OR 
         product_price < (avg_price - 2 * std_price) OR 
         product_price > (avg_price + 2 * std_price)
    THEN 'Outlier'
    ELSE 'Normal'
  END AS outlier_flag
FROM t976582.d3_sales, stats;
 --- Outlier Flag based on product quantity and product price   -- 156 Outliers 

Step 4: Clean Data by Removing Outliers

--
DROP TABLE IF EXISTS cleaned_sales_data;
CREATE TABLE cleaned_sales_data AS
WITH stats AS (
  SELECT 
    AVG(quantity) AS avg_qty,
    STDDEV(quantity) AS std_qty,
    AVG(product_price) AS avg_price,
    STDDEV(product_price) AS std_price
  FROM t976582.d3_sales
)
SELECT 
  s.*,
  'Normal' AS outlier_flag
FROM t976582.d3_sales s
CROSS JOIN stats
WHERE 
  s.quantity BETWEEN (stats.avg_qty - 2 * stats.std_qty) AND (stats.avg_qty + 2 * stats.std_qty)
  AND s.product_price BETWEEN (stats.avg_price - 2 * stats.std_price) AND (stats.avg_price + 2 * stats.std_price);
--- Removing Outliers 


Step 5: Revenue Trend and Spike Analysis (Cleaned Data)

 
SELECT 
order_timestamp::Date as order_date,
SUM(product_price * quantity) AS Revenue
FROM cleaned_sales_data
GROUP BY 1
ORDER BY Revenue DESC;
-- Daily Revenue 

SELECT 
product_category,
SUM(product_price * quantity) AS revenue
FROM cleaned_sales_data
GROUP BY 1
ORDER BY revenue;
-- Daily Revenue by Category

SELECT 
  d.user_id, 
  c.name,
  c.gender,
  c.age,
  c.location,
  SUM(d.product_price * d.quantity) AS daily_revenue
FROM cleaned_sales_data d
LEFT JOIN T976582.d3_customers c
ON d.user_id = c.user_id
GROUP BY 1,2,3,4,5;


---- daily revenue - spike days 
WITH daily_revenue_spikedays AS (
  SELECT 
    order_timestamp::date AS order_date,
    SUM(product_price * quantity) AS daily_revenue
  FROM cleaned_sales_data
  GROUP BY order_timestamp::date
),
overall_stats AS (
  SELECT 
    AVG(daily_revenue) AS avg_rev,
    STDDEV(daily_revenue) AS stddev_rev
  FROM daily_revenue_spikedays
)
SELECT 
d.order_date,
d.daily_revenue
FROM daily_revenue_spikedays d
CROSS JOIN overall_stats o 
WHERE d.daily_revenue > o.avg_rev + 2 * o.stddev_rev;
--Spike days (cleaned)
2025-02-14	1260500.0
2025-01-26	1163900.0
2024-12-25	1167100.0
2024-12-07	1196300.0

Step 6: Analysis by Product Category on Spike Days (with Cleaned Data)

--Spike Day – Product Category Analysis
WITH daily_revenue_summary AS (
  SELECT 
    order_timestamp::date AS order_date,
    user_id,
    product_category, 
    SUM(product_price * quantity) AS daily_revenue
  FROM cleaned_sales_data
  GROUP BY order_timestamp::date, user_id, product_category
)
SELECT 
  order_date,
  product_category,
  SUM(daily_revenue) AS total_revenue
FROM daily_revenue_summary
WHERE order_date IN ('2025-01-26', '2025-02-14', '2024-12-07', '2024-12-25') -- spike days
GROUP BY 1, 2
ORDER BY order_date, total_revenue DESC;
--Product Category during Spike days 


Step 7: Customer Behavior Analysis During Spike Days (with Cleaned Data)

--Top-Spending Customers on Spike Days
SELECT 
  user_id,
  ROUND(SUM(product_price * quantity), 2) AS total_spent,
  COUNT(DISTINCT order_id) AS total_orders
FROM cleaned_sales_data
WHERE outlier_flag = 'Normal'
  AND CAST(order_timestamp AS DATE) IN ('2025-01-26', '2025-02-14', '2024-12-07', '2024-12-25')
GROUP BY user_id
ORDER BY total_spent DESC
LIMIT 10;

-- Customer Details During Spike Days 
WITH daily_revenue_summary AS (
  SELECT 
    order_timestamp::date AS order_date,
    user_id, 
    SUM(product_price * quantity) AS daily_revenue
  FROM cleaned_sales_data
  GROUP BY order_timestamp::date, user_id
)
SELECT 
  d.user_id, 
  c.name,
  c.gender,
  c.age,
  c.location,
  SUM(d.daily_revenue) AS total_revenue
FROM daily_revenue_summary d
LEFT JOIN T976582.d3_customers c
  ON d.user_id = c.user_id
WHERE d.order_date IN ('2025-01-26', '2025-02-14', '2024-12-07', '2024-12-25')  -- spike days
GROUP BY 1, 2, 3, 4, 5
ORDER BY total_revenue DESC
LIMIT 10;




--Most Popular Product Categories on Spike Days
SELECT 
  product_category,
  COUNT(DISTINCT user_id) AS num_customers,
  SUM(quantity) AS total_items_sold,
  ROUND(SUM(product_price * quantity), 2) AS total_revenue
FROM cleaned_sales_data
WHERE outlier_flag = 'Normal'
  AND CAST(order_timestamp AS DATE) IN ('2025-01-26', '2025-02-14', '2024-12-07', '2024-12-25')
GROUP BY product_category
ORDER BY total_revenue DESC;


--High-Frequency Buyers (by quantity)
SELECT 
  D.user_id,
  C.name,
  SUM(D.quantity) AS total_items_bought,
  COUNT(DISTINCT D.order_id) AS total_orders
FROM cleaned_sales_data D
LEFT JOIN T976582.d3_customers C ON C.user_id =D.user_id 
WHERE D.outlier_flag = 'Normal'
  AND CAST(D.order_timestamp AS DATE) IN ('2025-01-26', '2025-02-14', '2024-12-07', '2024-12-25')
GROUP BY D.user_id,C.name
ORDER BY total_items_bought DESC
LIMIT 10;


--Average Order Value per Customer
SELECT 
  user_id,
  ROUND(SUM(product_price * quantity), 2) AS total_spent,
  COUNT(DISTINCT order_id) AS total_orders,
  ROUND(SUM(product_price * quantity) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM cleaned_sales_data
WHERE outlier_flag = 'Normal'
  AND CAST(order_timestamp AS DATE) IN ('2025-01-26', '2025-02-14', '2024-12-07', '2024-12-25')
GROUP BY user_id
ORDER BY avg_order_value DESC
LIMIT 10;

--Top Purchased Product Overall on Spike Days
SELECT 
  product_category ,
  SUM(quantity) AS total_units_sold,
  ROUND(SUM(product_price * quantity), 2) AS total_revenue
FROM cleaned_sales_data
WHERE outlier_flag = 'Normal'
  AND CAST(order_timestamp AS DATE) IN ('2025-01-26', '2025-02-14', '2024-12-07', '2024-12-25')
GROUP BY product_category
ORDER BY total_units_sold DESC
LIMIT 10;



Step 8: Shopping Pattern Analysis

-- Customer Persona Segmentation 
 WITH customer_behavior_spikes AS (
  SELECT 
    user_id,
    product_category,
    COUNT(*) AS purchase_frequency,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(product_price * quantity), 2) AS total_spent,
    ROUND(SUM(product_price * quantity) / COUNT(DISTINCT order_id), 2) AS avg_order_value,
    ROW_NUMBER() OVER (
      PARTITION BY user_id 
      ORDER BY COUNT(*) DESC
    ) AS rank_favorite
  FROM cleaned_sales_data
  WHERE outlier_flag = 'Normal'
    AND CAST(order_timestamp AS DATE) IN ('2025-01-26', '2025-02-14', '2024-12-07', '2024-12-25')
  GROUP BY user_id, product_category
)
		SELECT 
		  D.user_id,
		  C.name,
		  D.product_category AS favorite_category,
		  D.purchase_frequency,
		  D.total_orders,
		  D.total_spent,
		  D.avg_order_value
		FROM customer_behavior_spikes D
		LEFT JOIN T976582.d3_customers C on D.user_id=C.user_id 
		WHERE D.rank_favorite = 1             -- Taking Top Category 
		ORDER BY D.purchase_frequency DESC,D.Total_spent DESC LIMIT 10;



SELECT * FROM cleaned_sales_data;


-----------------------------------------------------------------------------------------------------------------------


  
  
