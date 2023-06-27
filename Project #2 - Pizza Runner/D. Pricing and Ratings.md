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
  ROUND(AVG(r.duration / r.duration * 60), 1) AS avg_speed,
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
