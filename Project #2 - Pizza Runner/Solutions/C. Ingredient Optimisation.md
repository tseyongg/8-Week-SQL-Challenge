# :pizza: Case Study #2: Pizza runner - C. Ingredient Optimisation

## C. Ingredient Optimisation Questions

1. What are the standard ingredients for each pizza?
2. What was the most commonly added extra?
3. What was the most common exclusion?
4. Generate an order item for each record in the `customers_orders` table in the format of one of the following:
- `Meat Lovers`
- `Meat Lovers - Exclude Beef`
- `Meat Lovers - Extra Bacon`
- `Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers`
5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the `customer_orders` table and add a `2x` in front of any relevant ingredients
- For example: `"Meat Lovers: 2xBacon, Beef, ... , Salami"`
6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

***

### Data Cleaning

**a. Create temp table `newtoppings`, splitting the `toppings` column from `pizza_recipes` table**

````sql
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
FROM #newtoppings
````

| pizza_id | topping_id | topping_name |
| -------- | ---------- | ------------ |
| 1        | 1          | Bacon        |
| 1        | 2          | BBQ Sauce    |
| 1        | 3          | Beef         |
| 1        | 4          | Cheese       |
| 1        | 5          | Chicken      |
| 1        | 6          | Mushrooms    |
| 1        | 8          | Pepperoni    |
| 1        | 10         | Salami       |
| 2        | 4          | Cheese       |
| 2        | 6          | Mushrooms    |
| 2        | 7          | Onions       |
| 2        | 9          | Peppers      |
| 2        | 11         | Tomatoes     |
| 2        | 12         | Tomato Sauce |

***

**b. Add an identity column `record_id` to the `#customer_orders_temp` table**

````sql
ALTER TABLE #customer_orders_temp
ADD record_id INT IDENTITY(1,1);

SELECT *
FROM #customer_orders_temp;
````
  
| order_id | customer_id | pizza_id | exclusions | extras | order_time              | record_id  |
| -------- | ----------- | -------- | ---------- | ------ | ----------------------- | ---------- |
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02.000 | 1          |
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52.000 | 2          |
| 3        | 102         | 1        |            |        | 2020-01-02 23:51:23.000 | 3          |
| 3        | 102         | 2        |            |        | 2020-01-02 23:51:23.000 | 4          |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000 | 5          |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000 | 6          |
| 4        | 103         | 2        | 4          |        | 2020-01-04 13:23:46.000 | 7          |
| 5        | 104         | 1        |            | 1      | 2020-01-08 21:00:29.000 | 8          |
| 6        | 101         | 2        |            |        | 2020-01-08 21:03:13.000 | 9          |
| 7        | 105         | 2        |            | 1      | 2020-01-08 21:20:29.000 | 10         |
| 8        | 102         | 1        |            |        | 2020-01-09 23:54:33.000 | 11         |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59.000 | 12         |
| 10       | 104         | 1        |            |        | 2020-01-11 18:34:49.000 | 13         |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11 18:34:49.000 | 14         |

***

**c. Create a new temp table `newexclusions` which separates `exclusions` into multiple rows**

````sql
SELECT 
  c.record_id,
  TRIM(e.value) AS exclusion_id
INTO #newexclusions 
FROM #customer_orders_temp c
  CROSS APPLY STRING_SPLIT(exclusions, ',') AS e;

SELECT *
FROM #newexclusions;
````

| record_id | exclusion_id  |
| --------- | ------------- |
| 1         |               |
| 2         |               |
| 3         |               |
| 4         |               |
| 5         | 4             |
| 6         | 4             |
| 7         | 4             |
| 8         |               |
| 9         |               |
| 10        |               |
| 11        |               |
| 12        | 4             |
| 13        |               |
| 14        | 2             |
| 14        | 6             |

*** 

**d.  Create a new temp table `newextras` which separates `extras` into multiple rows**

````sql
SELECT 
  c.record_id,
  TRIM(e.value) AS extra_id
INTO #newextras 
FROM #customer_orders_temp c
  CROSS APPLY STRING_SPLIT(extras, ',') AS e;

SELECT *
FROM #newextras;
````

| record_id | extra_id  |
|-----------|-----------|
| 1         |           |
| 2         |           |
| 3         |           |
| 4         |           |
| 5         |           |
| 6         |           |
| 7         |           |
| 8         | 1         |
| 9         |           |
| 10        | 1         |
| 11        |           |
| 12        | 1         |
| 12        | 5         |
| 13        |           |
| 14        | 1         |
| 14        | 4         |

***

### Q1. What are the standard ingredients for each pizza?

````sql
SELECT 
  p.pizza_name,
  STRING_AGG(topping_name, ', ') AS ingredients
FROM #newtoppings t
JOIN pizza_names p 
  ON t.pizza_id = p.pizza_id
GROUP BY p.pizza_name;
````

| pizza_name | ingredients                                                            |
| ---------- | ---------------------------------------------------------------------- |
| Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami  |
| Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce             |

***

### Q2. What was the most commonly added extra?

````sql
SELECT
  topping_name,
  COUNT(*) AS frequency
FROM #newextras e
JOIN pizza_toppings pt 
  ON e.extra_id = pt.topping_id
GROUP BY topping_name;
````

| topping_name | frequency |
| ------------ | --------- |
| Bacon        | 4         |
| Cheese       | 1         |
| Chicken      | 1         |

The most commonly added extra was Bacon.

***

### Q3. What was the most common exclusion?

````sql
SELECT 
  topping_name,
  COUNT(*) AS frequency
FROM #newexclusions e 
JOIN pizza_toppings pt 
  ON e.exclusion_id = pt.topping_id
GROUP BY topping_name
ORDER BY frequency DESC;
````

| topping_name | frequency |
| ------------ | --------- |
| Cheese       | 4         |
| Mushrooms    | 1         |
| BBQ Sauce    | 1         |

The most common exclusion was Cheese.

***

### Q4. Generate an order item for each record in the `customers_orders` table in the format of one of the following:
- `Meat Lovers`
- `Meat Lovers - Exclude Beef`
- `Meat Lovers - Extra Bacon`
- `Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers`

To solve this question: 

- I created 3 CTEs: `extras_cte`, `exclusions_cte`, and then combining them into `union_cte`
- I LEFT JOINED `union_cte` with `#customer_orders_temp`, then JOINED with `pizza_names`
- Then I used `CONCAT_WS` with `STRING_AGG` to obtain the result

````sql
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
````
**Table `extras_cte`**

| record_id | comments              |
| --------- | --------------------- |
| 8         | Extra Bacon           |
| 10        | Extra Bacon           |
| 12        | Extra Bacon, Chicken  |
| 14        | Extra Bacon, Cheese   |

**Table `exclusions_cte`**

| record_id | comments                       |
| --------- | ------------------------------ |
| 5         | Exclude Cheese                 |
| 6         | Exclude Cheese                 |
| 7         | Exclude Cheese                 |
| 12        | Exclude Cheese                 |
| 14        | Exclude BBQ Sauce, Mushrooms   |

**Table `unioncte`**
| record_id | comments                        |
| --------- | ------------------------------- |
| 5         | Exclude Cheese                  |
| 6         | Exclude Cheese                  |
| 7         | Exclude Cheese                  |
| 8         | Extra Bacon                     |
| 10        | Extra Bacon                     |
| 12        | Exclude Cheese                  |
| 12        | Extra Bacon, Chicken            |
| 14        | Exclude BBQ Sauce, Mushrooms    |
| 14        | Extra Bacon, Cheese             |

**Result**
  
| record_id | order_id | customer_id | pizza_id | order_time              | pizza_info                                                        |
| --------- | -------- | ----------- | -------- | ----------------------- | ----------------------------------------------------------------- |
| 1         | 1        | 101         | 1        | 2020-01-01 18:05:02.000 | Meatlovers                                                        |
| 2         | 2        | 101         | 1        | 2020-01-01 19:00:52.000 | Meatlovers                                                        |
| 3         | 3        | 102         | 1        | 2020-01-02 23:51:23.000 | Meatlovers                                                        |
| 4         | 3        | 102         | 2        | 2020-01-02 23:51:23.000 | Vegetarian                                                        |
| 5         | 4        | 103         | 1        | 2020-01-04 13:23:46.000 | Meatlovers - Exclude Cheese                                       |
| 6         | 4        | 103         | 1        | 2020-01-04 13:23:46.000 | Meatlovers - Exclude Cheese                                       |
| 7         | 4        | 103         | 2        | 2020-01-04 13:23:46.000 | Vegetarian - Exclude Cheese                                       |
| 8         | 5        | 104         | 1        | 2020-01-08 21:00:29.000 | Meatlovers - Extra Bacon                                          |
| 9         | 6        | 101         | 2        | 2020-01-08 21:03:13.000 | Vegetarian                                                        |
| 10        | 7        | 105         | 2        | 2020-01-08 21:20:29.000 | Vegetarian - Extra Bacon                                          |
| 11        | 8        | 102         | 1        | 2020-01-09 23:54:33.000 | Meatlovers                                                        |
| 12        | 9        | 103         | 1        | 2020-01-10 11:22:59.000 | Meatlovers - Exclude Cheese - Extra Bacon, Chicken                |
| 13        | 10       | 104         | 1        | 2020-01-11 18:34:49.000 | Meatlovers                                                        |
| 14        | 10       | 104         | 1        | 2020-01-11 18:34:49.000 | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese   |

***

### Q5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the `customer_orders` table and add a `2x` in front of any relevant ingredients
- For example: `"Meat Lovers: 2xBacon, Beef, ... , Salami"`

To solve this question:
- I created a CTE in which each line displays an ingredient for an ordered pizza (add '2x' for extras and remove exclusions as well)
- I used `CONCAT` and `STRING_AGG` to obtain the result

````sql
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
````

 
| record_id | order_id | customer_id | pizza_id | order_time              | ingredients_list                                                                     |
| --------- | -------- | ----------- | -------- | ----------------------- | ------------------------------------------------------------------------------------ |
| 1         | 1        | 101         | 1        | 2020-01-01 18:05:02.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami    |
| 2         | 2        | 101         | 1        | 2020-01-01 19:00:52.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami    |
| 3         | 3        | 102         | 1        | 2020-01-02 23:51:23.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami    |
| 4         | 3        | 102         | 2        | 2020-01-02 23:51:23.000 | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce               |
| 5         | 4        | 103         | 1        | 2020-01-04 13:23:46.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami            |
| 6         | 4        | 103         | 1        | 2020-01-04 13:23:46.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami            |
| 7         | 4        | 103         | 2        | 2020-01-04 13:23:46.000 | Vegetarian: Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                       |
| 8         | 5        | 104         | 1        | 2020-01-08 21:00:29.000 | Meatlovers: 2x Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni,Salami  |
| 9         | 6        | 101         | 2        | 2020-01-08 21:03:13.000 | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce               |
| 10        | 7        | 105         | 2        | 2020-01-08 21:20:29.000 | Vegetarian: Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce               |
| 11        | 8        | 102         | 1        | 2020-01-09 23:54:33.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami    |
| 12        | 9        | 103         | 1        | 2020-01-10 11:22:59.000 | Meatlovers: 2x Bacon, BBQ Sauce, Beef, 2x Chicken, Mushrooms, Pepperoni, Salami      |
| 13        | 10       | 104         | 1        | 2020-01-11 18:34:49.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami    |
| 14        | 10       | 104         | 1        | 2020-01-11 18:34:49.000 | Meatlovers: 2x Bacon, Beef, 2x Cheese, Chicken, Pepperoni, Salami                    |

***

### Q6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

To solve this question:
- Create a CTE to record the number of times each ingredient was used
  - if extra ingredient, add 2 
  - if excluded ingredient, add 0
  - no extras or no exclusions, add 1
- Also filter out non-delivered items, i.e. cancellaton IS NULL

````sql
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
````

| topping_name | times_used  |
| ------------ | ----------- |
| Bacon        | 11          |
| Mushrooms    | 11          |
| Cheese       | 10          |
| Chicken      | 9           |
| Pepperoni    | 9           |
| Salami       | 9           |
| Beef         | 9           |
| BBQ Sauce    | 8           |
| Peppers      | 3           |
| Onions       | 3           |
| Tomato Sauce | 3           |
| Tomatoes     | 3           |

***

Click [here](https://github.com/tseyongg/Tse_Yong_SQL_Projects/blob/main/Project%20%232%20-%20Pizza%20Runner/Solutions/D.%20Pricing%20and%20Ratings.md) to view my solutions to the next portion, **D. Pricing and Ratings!**
