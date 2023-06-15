--------------------------------
--CASE STUDY #2: PIZZA RUNNER--
--------------------------------

--Author: Lye Tse Yong
--Date: 14/06/2023 
--Tools used: MS SQL Server, VSCode 

-- Data Cleaning

--a.

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
INTO #customer_orders_temp
FROM customer_orders;


SELECT *
FROM #customer_orders_temp;

--b.

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
INTO #runner_orders_temp
FROM runner_orders;

SELECT *
FROM #runner_orders_temp;


-- A. Pizza Metrics

--1.

SELECT COUNT(order_id) AS pizza_count
FROM #customer_orders_temp;

--2.

SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM #customer_orders_temp;

-- 3.

SELECT 
  runner_id,
  COUNT(order_id) AS successful_orders_count
FROM #runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id
