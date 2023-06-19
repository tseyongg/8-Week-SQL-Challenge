--------------------------------
--CASE STUDY #2: PIZZA RUNNER--
--------------------------------

--Author: Lye Tse Yong
--Date: 14/06/2023 
--Tools used: MS SQL Server, VSCode 

-- Data Cleaning

--a.

DROP TABLE IF EXISTS #customer_orders_temp;

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

DROP TABLE IF EXISTS #runner_orders_temp;

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
GROUP BY runner_id;

--4.

SELECT 
  pizza_name,
  COUNT(*) AS delivered_count
FROM #customer_orders_temp AS c
JOIN pizza_names AS p 
  ON c.pizza_id = p.pizza_id
JOIN #runner_orders_temp AS r 
  ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY p.pizza_name;

--5.

SELECT
  customer_id,
  SUM(CASE WHEN pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS Meatlovers,
  SUM(CASE WHEN pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS Vegetarian
FROM #customer_orders_temp c 
JOIN pizza_names p
  ON c.pizza_id = p.pizza_id
GROUP BY customer_id;

--6.

SELECT TOP 1
  c.order_id,
  COUNT(*) AS pizza_count
FROM #customer_orders_temp AS c
JOIN #runner_orders_temp AS r 
  ON c.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY c.order_id
ORDER BY pizza_count DESC;

--7.

SELECT 
  customer_id,
  SUM(CASE WHEN exclusions != '' OR extras != '' THEN 1 ELSE 0 END) AS has_changes,
  SUM(CASE WHEN exclusions = '' AND extras = '' THEN 1 ELSE 0 END) AS no_changes
FROM #customer_orders_temp c
JOIN #runner_orders_temp r 
  ON c.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY customer_id;

--8.

SELECT SUM(CASE WHEN exclusions != '' AND extras != '' THEN 1 ELSE 0 END) AS had_both_changes
FROM #customer_orders_temp c
JOIN #runner_orders_temp r 
  ON c.order_id = r.order_id
WHERE cancellation IS NULL;

--9.

SELECT 
  DATEPART(HOUR, order_time) AS hour_of_day,
  COUNT(*) AS pizza_volume
FROM #customer_orders_temp
GROUP BY DATEPART(HOUR, order_time)
ORDER BY hour_of_day;

--10.

SELECT
  DATENAME(WEEKDAY, order_time) AS day_of_week,
  COUNT(*) AS daily_pizza_volume
FROM #customer_orders_temp
GROUP BY DATENAME(WEEKDAY, order_time), DATEPART(WEEKDAY, order_time);


-- B. Runner and Customer Experience

--1. 

SELECT
  DATEPART(WEEK, registration_date) AS registration_week,
  COUNT(*) AS runner_signup
FROM runners
GROUP BY DATEPART(WEEK, registration_date);

--2.
WITH runners_pickup AS (
  SELECT
    r.runner_id,
    c.order_id, 
    c.order_time, 
    r.pickup_time, 
    DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS pickup_minutes
  FROM #customer_orders_temp c 
  JOIN #runner_orders_temp r 
    ON c.order_id = r.order_id 
  WHERE r.cancellation IS NULL
  GROUP BY r.runner_id, c.order_id, c.order_time, r.pickup_time
)

SELECT 
runner_id,
AVG(pickup_minutes) AS average_time
FROM runners_pickup
GROUP BY runner_id;

--3.