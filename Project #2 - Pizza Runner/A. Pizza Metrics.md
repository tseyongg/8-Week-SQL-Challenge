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
GROUP BY runner_id
````

| runner_id | successful_orders_count  |
| --------- | ------------------------ |
| 1         | 4                        |
| 2         | 3                        |
| 3         | 1                        |

