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

WITH pizza_prep AS (
  SELECT
    r.runner_id,
    c.order_id, 
    c.order_time, 
    r.pickup_time, 
    DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time,
    COUNT(pizza_id) AS pizza_count
  FROM #customer_orders_temp c 
  JOIN #runner_orders_temp r 
    ON c.order_id = r.order_id 
  WHERE r.cancellation IS NULL
  GROUP BY r.runner_id, c.order_id, c.order_time, r.pickup_time
)

SELECT 
pizza_count,
AVG(prep_time) AS avg_prep_time
FROM pizza_prep
GROUP BY pizza_count;

--4. 

WITH travels AS (
  SELECT
    customer_id,
    c.order_id,
    distance
  FROM #customer_orders_temp c 
  JOIN #runner_orders_temp r 
    ON c.order_id = r.order_id 
  WHERE r.cancellation IS NULL
  GROUP BY customer_id, c.order_id, distance)

SELECT 
  customer_id,
  AVG(distance) AS avg_dist
FROM travels
GROUP BY customer_id;

--5.

SELECT MAX(duration) - MIN(duration) AS time_diff
FROM #runner_orders_temp;

--6.

SELECT 
  r.runner_id,
  r.order_id,
  r.distance,
  r.duration AS duration_min,
  ROUND(AVG((r.distance / r.duration) * 60), 1) AS avg_speed
FROM #runner_orders_temp r
JOIN #customer_orders_temp c
  ON r.order_id = c.order_id
WHERE r.cancellation IS NULL
GROUP BY r.runner_id, r.order_id, r.distance, r.duration;

--7.

SELECT
  runner_id,
  COUNT(order_id) AS orders,
  COUNT(distance) AS fufilled,
  100 * COUNT(distance) / COUNT(order_id) AS delivered_percentage
FROM #runner_orders_temp
GROUP BY runner_id;


-- C. Ingredient Optimisation

-- Data Cleaning

--a.

SELECT 
  pr.pizza_id,
  TRIM(t.value) AS topping_id,
  pt.topping_name
INTO #newtoppings
FROM pizza_recipes pr 
  CROSS APPLY STRING_SPLIT(toppings, ',') AS t 
JOIN pizza_toppings pt 
  ON TRIM(t.value) = pt.topping_id;

SELECT *
FROM #newtoppings;

--b.

ALTER TABLE #customer_orders_temp
ADD record_id INT IDENTITY(1,1);

SELECT *
FROM #customer_orders_temp;

--c.

SELECT 
  c.record_id,
  TRIM(e.value) AS exclusion_id
INTO #newexclusions 
FROM #customer_orders_temp c
  CROSS APPLY STRING_SPLIT(exclusions, ',') AS e;

SELECT *
FROM #newexclusions;

--d.

SELECT 
  c.record_id,
  TRIM(e.value) AS extra_id
INTO #newextras 
FROM #customer_orders_temp c
  CROSS APPLY STRING_SPLIT(extras, ',') AS e;

SELECT *
FROM #newextras;

--1.

SELECT 
  p.pizza_name,
  STRING_AGG(topping_name, ', ') AS ingredients
FROM #newtoppings t
JOIN pizza_names p 
  ON t.pizza_id = p.pizza_id
GROUP BY p.pizza_name;

--2.

SELECT
  topping_name,
  COUNT(*) AS frequency
FROM #newextras e
JOIN pizza_toppings pt 
  ON e.extra_id = pt.topping_id
GROUP BY topping_name;

--3.

SELECT 
  topping_name,
  COUNT(*) AS frequency
FROM #newexclusions e 
JOIN pizza_toppings pt 
  ON e.exclusion_id = pt.topping_id
GROUP BY topping_name
ORDER BY frequency DESC;

--4.

WITH extras_cte AS (
  SELECT 
    e.record_id,
    'Extra ' + STRING_AGG(t.topping_name, ', ') AS comments
  FROM #newextras e
  JOIN pizza_toppings t
    ON e.extra_id = t.topping_id
  GROUP BY e.record_id
),
exclusions_cte AS (
  SELECT 
    e.record_id,
    'Exclude ' + STRING_AGG(t.topping_name, ', ') AS comments
  FROM #newexclusions e
  JOIN pizza_toppings t
    ON e.exclusion_id = t.topping_id
  GROUP BY e.record_id
),
union_cte AS (
  SELECT * FROM extras_cte
  UNION
  SELECT * FROM exclusions_cte
)

SELECT
  c.record_id,
  c.order_id,
  c.customer_id,
  c.pizza_id,
  c.order_time,
  CONCAT_WS(' - ', p.pizza_name, STRING_AGG(u.comments, ' - ')) AS pizza_info
FROM #customer_orders_temp c 
LEFT JOIN union_cte u 
  ON c.record_id = u.record_id
JOIN pizza_names p
  ON c.pizza_id = p.pizza_id
GROUP BY 
  c.record_id,
  c.order_id,
  c.customer_id,
  c.pizza_id,
  c.order_time,
  p.pizza_name;

--5.

WITH ingredients AS (
  SELECT 
    c.*,
    p.pizza_name,

    -- Add '2x' in front of topping_names if topping_id appears in the #extrasBreak table
    CASE WHEN t.topping_id IN (
          SELECT extra_id 
          FROM #newextras e 
          WHERE e.record_id = c.record_id)
      THEN '2x ' + t.topping_name
      ELSE t.topping_name
    END AS topping

  FROM #customer_orders_temp c
  JOIN #newtoppings t
    ON t.pizza_id = c.pizza_id
  JOIN pizza_names p
    ON p.pizza_id = c.pizza_id

  -- Exclude toppings if topping_id appears in the #exclusionBreak table
  WHERE t.topping_id NOT IN (
      SELECT exclusion_id 
      FROM #newexclusions e 
      WHERE c.record_id = e.record_id)
)

SELECT 
  record_id,
  order_id,
  customer_id,
  pizza_id,
  order_time,
  CONCAT(pizza_name + ': ', STRING_AGG(topping, ', ')) AS ingredients_list
FROM ingredients
GROUP BY 
  record_id, 
  record_id,
  order_id,
  customer_id,
  pizza_id,
  order_time,
  pizza_name
ORDER BY record_id;

--6.

WITH freq_ingredients AS (
  SELECT
  c.record_id,
  t.topping_name,
    CASE
      -- if extra ingredient, add 2
      WHEN t.topping_id IN (
          SELECT extra_id 
          FROM #newextras e
          WHERE e.record_id = c.record_id) 
      THEN 2
      -- if excluded ingredient, add 0
      WHEN t.topping_id IN (
          SELECT exclusion_id 
          FROM #newexclusions e 
          WHERE c.record_id = e.record_id)
      THEN 0
      -- no extras, no exclusions, add 1
      ELSE 1
    END AS times_used  
  FROM #customer_orders_temp c 
  JOIN #newtoppings t
    ON c.pizza_id = t.pizza_id
  JOIN #runner_orders_temp r 
    ON c.order_id = r.order_id
  WHERE r.cancellation IS NULL
)

SELECT 
  topping_name,
  SUM(times_used) AS times_used 
FROM freq_ingredients
GROUP BY topping_name
ORDER BY times_used DESC;


-- D. Pricing and Ratings

--1.

SELECT SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS money_earned
FROM #customer_orders_temp c
JOIN #runner_orders_temp r
  ON c.order_id = r.order_id
WHERE cancellation IS NULL;

--2. 

DECLARE @basecost INT
SET @basecost = 138

SELECT
  @basecost + SUM(CASE WHEN t.topping_name = 'Cheese' THEN 2 
  ELSE 1 END) AS updated_money_earned
FROM #newextras e 
JOIN pizza_toppings t 
  ON e.extra_id = t.topping_id