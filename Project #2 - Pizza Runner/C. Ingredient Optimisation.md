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

a. Create temp table `newtoppings`, splitting the `toppings` column from `pizza_recipes` table

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

b. Add an identity column `record_id` to the `#customer_orders_temp` table 

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

c. Create a new temp table `newexclusions` which separates `exclusions` into multiple rows

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

d.  Create a new temp table `newextras` which separates `extras` into multiple rows

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