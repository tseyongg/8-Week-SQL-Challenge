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

````

***

### Q3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

````sql

````

***

### Q4. What was the average distance travelled for each customer?

````sql

````

***

### Q5. What was the difference between the longest and shortest delivery times for all orders?

````sql

````

***

### Q6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

````sql

````

***

### Q7. What is the successful delivery percentage for each runner?

````sql

````
