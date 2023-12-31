# :pizza: Case Study #2: Pizza runner - A. Pizza Metrics

## A. Pizza Metrics Questions

1. How many pizzas were ordered?
2. How many unique customer orders were made?
3. How many successful orders were delivered by each runner?
4. How many of each type of pizza was delivered?
5. How many Vegetarian and Meatlovers were ordered by each customer?
6. What was the maximum number of pizzas delivered in a single order?
7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8. How many pizzas were delivered that had both exclusions and extras?
9. What was the total volume of pizzas ordered for each hour of the day?
10. What was the volume of orders for each day of the week?

***

### Q1. How many pizzas were ordered?

````sql
SELECT COUNT(order_id) AS pizza_count
FROM #customer_orders_temp;
````

| pizza_count |
| ----------- |
| 14          |

***

### Q2. How many unique customer orders were made?

````sql
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM #customer_orders_temp;
````

| unique_orders |
| ------------- | 
| 10            |

***

### Q3. How many successful orders were delivered by each runner?

````sql
SELECT 
  runner_id,
  COUNT(order_id) AS successful_orders_count
FROM #runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id;
````

| runner_id | successful_orders_count  |
| --------- | ------------------------ |
| 1         | 4                        |
| 2         | 3                        |
| 3         | 1                        |

***

### Q4. How many of each type of pizza was delivered?

````sql
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
````

| pizza_name | delivered_count |
| ---------- | --------------- |
| Meatlovers | 9               |
| Vegetarian | 3               |

***

### Q5. How many Vegetarian and Meatlovers were ordered by each customer?

````sql
SELECT
  customer_id,
  SUM(CASE WHEN pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS Meatlovers,
  SUM(CASE WHEN pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS Vegetarian
FROM #customer_orders_temp c 
JOIN pizza_names p
  ON c.pizza_id = p.pizza_id
GROUP BY customer_id;
````

| customer_id | Meatlovers | Vegetarian  |
| ----------- | ---------- | ----------- |
| 101         | 2          | 1           |
| 102         | 2          | 1           |
| 103         | 3          | 1           |
| 104         | 3          | 0           |
| 105         | 0          | 1           |

***

### Q6. What was the maximum number of pizzas delivered in a single order?

````sql
SELECT TOP 1
  c.order_id,
  COUNT(*) AS pizza_count
FROM #customer_orders_temp AS c
JOIN #runner_orders_temp AS r 
  ON c.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY c.order_id
ORDER BY pizza_count DESC;
````

| order_id | pizza_count |
| -------- | ----------- |
| 4        | 3           |

***

## Q7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

````sql
SELECT 
  customer_id,
  SUM(CASE WHEN exclusions != '' OR extras != '' THEN 1 ELSE 0 END) AS had_changes,
  SUM(CASE WHEN exclusions = '' AND extras = '' THEN 1 ELSE 0 END) AS no_changes
FROM #customer_orders_temp c
JOIN #runner_orders_temp r 
  ON c.order_id = r.order_id
WHERE cancellation IS NULL
GROUP BY customer_id;
````

| customer_id | had_changes | no_changes |
| ----------- | ----------- | ---------- |
| 101         | 0           | 2          |
| 102         | 0           | 3          |
| 103         | 3           | 0          |
| 104         | 2           | 1          |
| 105         | 1           | 0          |

***

## Q8. How many pizzas were delivered that had both exclusions and extras?

````sql
SELECT SUM(CASE WHEN exclusions != '' AND extras != '' THEN 1 ELSE 0 END) AS had_both_changes
FROM #customer_orders_temp c
JOIN #runner_orders_temp r 
  ON c.order_id = r.order_id
WHERE cancellation IS NULL;
````

| had_both_changes |
| ---------------- |
| 1                |

***

## Q9. What was the total volume of pizzas ordered for each hour of the day?

````sql
SELECT 
  DATEPART(HOUR, order_time) AS hour_of_day,
  COUNT(*) AS pizza_volume
FROM #customer_orders_temp
GROUP BY DATEPART(HOUR, order_time)
ORDER BY hour_of_day;
````

| hour_of_day | pizza_volume  |
| ----------- | ------------- |
| 11          | 1             |
| 13          | 3             |
| 18          | 3             |
| 19          | 1             |
| 21          | 3             |
| 23          | 3             |

***

## Q10. What was the volume of orders for each day of the week?

````sql
SELECT
  DATENAME(WEEKDAY, order_time) AS day_of_week,
  COUNT(*) AS daily_pizza_volume
FROM #customer_orders_temp
GROUP BY DATENAME(WEEKDAY, order_time), DATEPART(WEEKDAY, order_time);
````

| day_of_week | daily_pizza_volume |
|-------------|--------------------|
| Wednesday   | 5                  |
| Thursday    | 3                  |
| Friday      | 1                  |
| Saturday    | 5                  |

***

Click [here](https://github.com/tseyongg/Tse_Yong_SQL_Projects/blob/main/Project%20%232%20-%20Pizza%20Runner/Solutions/B.%20Runner%20and%20Customer%20Experience.md) to view my solutions to the next portion, **B. Runner and Customer Experience!**