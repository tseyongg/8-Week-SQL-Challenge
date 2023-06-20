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

- Create temp table `newtoppingss`, splitting the `toppings` column from `pizza_recipes` table

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