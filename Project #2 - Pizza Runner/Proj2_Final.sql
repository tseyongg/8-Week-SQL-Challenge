--------------------------------
--CASE STUDY #2: PIZZA RUNNER--
--------------------------------

--Author: Lye Tse Yong
--Date: 14/06/2023 
--Tools used: MS SQL Server, VSCode 

-- Data Cleaning

WITH customer_orders_cte AS
(
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE 
  	  WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ''
      ELSE exclusions 
      END AS exclusions,
    CASE 
  	  WHEN extras IS NULL OR extras LIKE 'null' THEN ''
      ELSE extras 
      END AS extras,
    order_time
  FROM customer_orders
)

SELECT *
FROM customer_orders_cte;



WITH runner_orders_cte AS
(
  SELECT 
    order_id, 
    runner_id,  
    CAST(
	  CASE WHEN pickup_time LIKE 'null' THEN NULL
	  ELSE pickup_time
	  END AS DATETIME) AS pickup_time,
    CAST(
      CASE
	  WHEN distance LIKE 'null' THEN NULL
	  WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	  ELSE distance 
      END AS FLOAT) AS distance,
    CAST(
      CASE WHEN duration LIKE 'null' THEN NULL
	  WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	  WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	  WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	  ELSE duration
	  END AS INT) AS duration,
    CASE WHEN cancellation IN ('null', '') THEN NULL
	  ELSE cancellation
	  END AS cancellation
  FROM runner_orders
)

SELECT *
FROM runner_orders_cte;


-- A

--1.

WITH customer_orders_cte AS
(
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE 
  	  WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ''
      ELSE exclusions 
      END AS exclusions,
    CASE 
  	  WHEN extras IS NULL OR extras LIKE 'null' THEN ''
      ELSE extras 
      END AS extras,
    order_time
  FROM customer_orders
)

SELECT COUNT(order_id) AS pizza_count
FROM customer_orders_cte;

--2.

WITH customer_orders_cte AS
(
  SELECT
    order_id,
    customer_id,
    pizza_id,
    CASE 
  	  WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ''
      ELSE exclusions 
      END AS exclusions,
    CASE 
  	  WHEN extras IS NULL OR extras LIKE 'null' THEN ''
      ELSE extras 
      END AS extras,
    order_time
  FROM customer_orders
)

SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders_cte;