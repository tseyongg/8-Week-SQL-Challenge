# :pizza: Case Study #2: Pizza runner - B. Runner and Customer Experience

## B. Runner and Customer Experience Questions

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
4. What was the average distance travelled for each customer?
5. What was the difference between the longest and shortest delivery times for all orders?
6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
7. What is the successful delivery percentage for each runner?

***

### Q1.  How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

````sql
SELECT
  DATEPART(WEEK, registration_date) AS registration_week,
  COUNT(*) AS runner_signup
FROM runners
GROUP BY DATEPART(WEEK, registration_date);
````

| registration_week | runner_signup |
| ----------------- | ------------- |
| 1                 | 1             |
| 2                 | 2             |
| 3                 | 1             |

***

### Q2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

````sql
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
````

| runner_id | average_time  |
| --------- | ------------- |
| 1         | 14            |
| 2         | 20            |
| 3         | 10            |

***

### Q3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql
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
````

| pizza_count | avg_prep_time  |
| ----------- | -------------- |
| 1           | 12             |
| 2           | 18             |
| 3           | 30             |

- With more pizzas, preparation time increased.

***

### Q4. What was the average distance travelled for each customer?

````sql
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
GROUP BY customer_id
````

| customer_id | avg_dist |
| ----------- | -------- |
| 101         | 20       |
| 102         | 18.4     |
| 103         | 23.4     |
| 104         | 10       |
| 105         | 25       |

***

### Q5. What was the difference between the longest and shortest delivery times for all orders?

````sql
SELECT MAX(duration) - MIN(duration) AS time_diff
FROM #runner_orders_temp;
````
|time_diff|
| ------- |
| 30      |

***

### Q6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql

````

***

### Q7. What is the successful delivery percentage for each runner?

````sql

````
