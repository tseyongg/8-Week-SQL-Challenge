# :pizza: Case Study #2: Pizza runner - D. Pricing and Ratings

## D. Pricing and Rating Questions

1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
2. What if there was an additional $1 charge for any pizza extras?
- Add cheese is $1 extra
3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
- `customer_id`
- `order_id`
- `runner_id`
- `rating`
- `order_time`
- `pickup_time`
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas
5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

***

### Q1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

````sql
SELECT SUM(CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS money_earned
FROM #customer_orders_temp c
JOIN #runner_orders_temp r
  ON c.order_id = r.order_id
WHERE cancellation IS NULL;
````

| money_earned |
| ------------ |
| 138          |

***

### Q2. What if there was an additional $1 charge for any pizza extras?
- Add cheese is $1 extra

````sql
DECLARE @basecost INT
SET @basecost = 138

SELECT
  @basecost + SUM(CASE WHEN t.topping_name = 'Cheese' THEN 2 
  ELSE 1 END) AS updated_money_earned
FROM #newextras e 
JOIN pizza_toppings t 
  ON e.extra_id = t.topping_id
````

| updated_money_earned |
| -------------------- |
| 145                  |

***

### Q3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

````sql
DROP TABLE IF EXISTS ratings
CREATE TABLE ratings (
  order_id INT,
  rating INT
);
INSERT INTO ratings 
  (order_id, rating)
VALUES
  (1,4),
  (2,1),
  (3,4),
  (4,5),
  (5,3),
  (6,4),
  (7,2),
  (8,5),
  (9,3),
  (10,4);

  SELECT *
  FROM ratings;
````

| order_id | rating |
| -------- | ------ |
| 1        | 4      |
| 2        | 1      |
| 3        | 4      |
| 4        | 5      |
| 5        | 3      |
| 6        | 4      |
| 7        | 2      |
| 8        | 5      |
| 9        | 3      |
| 10       | 4      |

***

### Q4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
- `customer_id`
- `order_id`
- `runner_id`
- `rating`
- `order_time`
- `pickup_time`
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas

````sql
SELECT
  c.customer_id,
  c.order_id,
  r.runner_id,
  ra.rating,
  c.order_time,
  r.pickup_time,
  DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS time_btwn,
  r.duration,
  ROUND(AVG(r.distance / r.duration * 60), 1) AS avg_speed,
  COUNT(c.order_id) AS pizza_count
FROM #customer_orders_temp c 
JOIN #runner_orders_temp r 
  ON c.order_id = r.order_id
JOIN ratings ra 
  ON c.order_id = ra.order_id
WHERE r.cancellation IS NULL
GROUP BY
  c.customer_id,
  c.order_id,
  r.runner_id,
  ra.rating,
  c.order_time,
  r.pickup_time,
  r.duration
ORDER BY customer_id;
````
| customer_id | order_id | runner_id | rating | order_time             | pickup_time             | time_btwn | duration | avg_speed | pizza_count  |
| ----------- | -------- | --------- | ------ | ---------------------- | ----------------------- | --------- | -------- | --------- |--------------|
| 101         | 1        | 1         | 4      |2020-01-01 18:05:02.000 | 2020-01-01 18:15:34.000 | 10        | 32       | 37.5      | 1            |
| 101         | 2        | 1         | 1      |2020-01-01 19:00:52.000 | 2020-01-01 19:10:54.000 | 10        | 27       | 44.4      | 1            |
| 102         | 3        | 1         | 4      |2020-01-02 23:51:23.000 | 2020-01-03 00:12:37.000 | 21        | 20       | 40.2      | 2            |
| 102         | 8        | 2         | 5      |2020-01-09 23:54:33.000 | 2020-01-10 00:15:02.000 | 21        | 15       | 93.6      | 1            |
| 103         | 4        | 2         | 5      |2020-01-04 13:23:46.000 | 2020-01-04 13:53:03.000 | 30        | 40       | 35.1      | 3            |
| 104         | 5        | 3         | 3      |2020-01-08 21:00:29.000 | 2020-01-08 21:10:57.000 | 10        | 15       | 40        | 1            |
| 104         | 10       | 1         | 4      |2020-01-11 18:34:49.000 | 2020-01-11 18:50:20.000 | 16        | 10       | 60        | 2            |
| 105         | 7        | 2         | 2      |2020-01-08 21:20:29.000 | 2020-01-08 21:30:45.000 | 10        | 25       | 60        | 1            |

***

### Q5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

````sql
DECLARE @basecost INT
SET @basecost = 138

SELECT 
  @basecost AS revenue,
  ROUND(SUM(distance) * 0.3, 2) AS paid_to_runners,
  @basecost - SUM(distance) * 0.3 AS money_left
FROM #runner_orders_temp;
````

| revenue | paid_to_runners | money_left  |
| ------- | --------------- | ----------- |
| 138     | 43.56           | 94.44       |

***

Click [here]() to view my solutions to the next portion, **E. Bonus Questions!**