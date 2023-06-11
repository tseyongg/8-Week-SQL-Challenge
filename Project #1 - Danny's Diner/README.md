# 🍜 Project #1: Danny's Diner
<img src="https://8weeksqlchallenge.com/images/case-study-designs/1.png" alt="Image" width="500" height="500">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Questions and Solutions](#questions-and-solutions)

Note: All information regarding the case study has been sourced from the following [link](https://8weeksqlchallenge.com/case-study-1/). 

***

## Business Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite.

***

## Entity Relationship Diagram

![image](https://user-images.githubusercontent.com/81607668/127271130-dca9aedd-4ca9-4ed8-b6ec-1e1920dca4a8.png)

***

## Questions and Solutions

Please join me in executing the queries using PostgreSQL on [DB Fiddle](https://www.db-fiddle.com/f/2rM8RAnq7h5LLDTzZiRWcd/138). It would be great to work together on the questions!

If you have any questions, do reach out to me on [LinkedIn](https://www.linkedin.com/in/lye-tse-yong/)!

**1. What is the total amount each customer spent at the restaurant?**

```sql
SELECT 
  s.customer_id, 
  SUM(price) AS total_sales
FROM dbo.sales AS s
JOIN dbo.menu AS m
  ON s.product_id = m.product_id
GROUP BY customer_id;
```

#### Steps:
- USE **JOIN** to merge `sales` and `menu` tables 
- USE **SUM** to calculate total sales from each customer
- Group the aggregated results by `customer_id`

#### Answer:
| customer_id | total_sales |
| ----------  | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.

***

**2. How many days has each customer visited the restaurant?**

````sql
SELECT 
  customer_id, 
  COUNT(DISTINCT(order_date)) AS visit_count
FROM dbo.sales
GROUP BY customer_id;
````

#### Steps:
- Utilize **COUNT(DISTINCT`order_date`)** to obtain each customer's unique number of visits.

#### Answer:
| customer_id | visit_count |
| ----------  | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.

***

**3. What was the first item from the menu purchased by each customer?**

````sql
WITH ordered_sales_cte AS
(
  SELECT 
    customer_id, 
    order_date, 
    product_name,
	DENSE_RANK() OVER (
      PARTITION BY s.customer_id 
      ORDER BY s.order_date) AS rank
  FROM dbo.sales AS s
  JOIN dbo.menu AS m
    ON s.product_id = m.product_id
)

SELECT 
  customer_id, 
  product_name
FROM ordered_sales_cte
WHERE rank = 1
GROUP BY customer_id, product_name;
````

#### Steps:
- Create a Common Table Expression (CTE) named `ordered_sales_cte`. Within the CTE, create a new column `rank` and rank each row using the **DENSE_RANK()** window function. The **PARTITION BY** clause divides the data by `customer_id`, and the **ORDER BY** clause orders the rows within each partition by `order_date`.

#### Answer:
| customer_id | product_name | 
| ----------- | ------------ |
| A           | curry        | 
| A           | sushi        | 
| B           | curry        | 
| C           | ramen        |

- Customer A placed an order for both curry and sushi simultaneously, making them the first items in the order.
- Customer B's first order is curry.
- Customer C's first order is ramen.

`DENSE_RANK()` over `ROW_NUMBER()`since Customer A has 2 simultaneous orders; `ROW_NUMBER()` would cause sushi to be ranked second.

***

**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

````sql
SELECT
  TOP 1 product_name,
  COUNT(product_name) AS most_purchased
FROM dbo.sales AS s
JOIN dbo.menu AS m
  ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY most_purchased DESC;
````

#### Steps:
- Perform a **COUNT** aggregation on the `product_name` column and **ORDER BY** the result in descending order using `most_purchased` field.
- Apply the **TOP 1** clause to filter and retrieve the highest purchased item.

#### Answer:
| product_name | most_purchased | 
| ------------ | -------------- |
| ramen        | 8              |

- Ramen was purchased the most at 8 times!

***

**5. Which item was the most popular for each customer?**

````sql
WITH fav_item_cte AS
(
 SELECT 
   s.customer_id, 
   m.product_name, 
   COUNT(m.product_id) AS order_count,
   DENSE_RANK() OVER (
     PARTITION BY s.customer_id 
     ORDER BY COUNT(s.customer_id) DESC) AS rank
 FROM dbo.menu AS m
 JOIN dbo.sales AS s
   ON m.product_id = s.product_id
 GROUP BY s.customer_id, m.product_name
)

SELECT 
  customer_id, 
  product_name, 
  order_count
FROM fav_item_cte 
WHERE rank = 1;
````

*Each user may have more than 1 favourite item.*

#### Steps:
- Create a CTE named `fav_item_cte` and within the CTE, join the `menu` and `sales` tables using the `product_id` column.
- Group results by `customer_id` and `product_name` and calculate the count of `product_id` occurrences for each group. 
- Utilize the **DENSE_RANK()** window function to calculate the ranking of each row, partitioned by `customer_id`, ordered by count of orders **COUNT(`sales.customer_id`)** in descending order.
- In the outer query, select the appropriate columns and apply a filter in the **WHERE** clause to retrieve only the rows where the rank column equals 1, representing the rows with the highest order count for each customer.

#### Answer:
| customer_id | product_name | order_count |
| ----------- | ------------ | ----------- |
| A           | ramen        |  3          |
| B           | sushi        |  2          |
| B           | curry        |  2          |
| B           | ramen        |  2          |
| C           | ramen        |  3          |

- Customer A and C's favourite items are ramen.
- Customer B enjoys all items on the menu!

***

**6. Which item was purchased first by the customer after they became a member?**

````sql
WITH member_sales_cte AS
(
  SELECT
    s.customer_id, 
    m.join_date, 
    s.order_date, 
    s.product_id,
    m2.product_name,
    DENSE_RANK() OVER (
      PARTITION BY s.customer_id 
      ORDER BY s.order_date) AS rank
  FROM dbo.members AS m
  JOIN dbo.sales AS s
    ON s.customer_id = m.customer_id
  JOIN dbo.menu AS m2
    ON s.product_id = m2.product_id
  WHERE s.order_date > m.join_date
)

SELECT 
  customer_id,
  order_date,
  join_date,
  product_name
FROM member_sales_cte
WHERE rank = 1;
````

#### Steps:
- Create a Common Table Expression (CTE) named `member_sales_cte`. Within the CTE, create a new column `rank` and rank each row using the **DENSE_RANK()** window function. The **PARTITION BY** clause divides the data by `customer_id`, and the **ORDER BY** clause orders the rows within each partition by `order_date`.
- Join tables `members` and `sales` on `customer_id` column, and then tables `menu` and `sales` on `product_id` column. Additionally, apply a condition to only include sales that occurred *after* the members' `join_date` (`sales.order_date > members.join_date`).
- In the outer query, using the  **WHERE** clause, filter to retrieve only the rows where rank equals 1, representing the first row within each `customer_id` partition.

#### Answer:
| customer_id | order_date | join_date  | product_name |
| ----------- | ---------- | ---------- | ------------ |
| A           | 2021-01-10 | 2021-01-07 | ramen        |
| B           | 2021-01-11 | 2021-01-09 | sushi        |

- Customer A's first order as a member is ramen.
- Customer B's first order as a member is sushi.

***

**7. Which item was purchased just before the customer became a member?**
````sql
WITH prior_member_purchased_cte AS
(
  SELECT
    s.customer_id, 
    m.join_date, 
    s.order_date, 
    s.product_id,
    m2.product_name,
    DENSE_RANK() OVER (
      PARTITION BY s.customer_id 
      ORDER BY s.order_date DESC) AS rank
  FROM dbo.members AS m
  JOIN dbo.sales AS s
    ON s.customer_id = m.customer_id
  JOIN dbo.menu AS m2
    ON s.product_id = m2.product_id
  WHERE s.order_date < m.join_date
)

SELECT customer_id,
       order_date,
       join_date,
       product_name
FROM prior_member_purchased_cte
WHERE rank = 1;
````

#### Steps:
- Create a Common Table Expression (CTE) named `prior_member_purchased_cte`. Within the CTE, create a new column `rank` and rank each row using the **DENSE_RANK()** window function. The **PARTITION BY** clause divides the data by `customer_id`, and the **ORDER BY** clause orders the rows within each partition by `order_date`descending.
- Join tables `members` and `sales` on `customer_id` column, and then tables `menu` and `sales` on `product_id` column. Additionally, apply a condition to only include sales that occurred *before* the members' `join_date` (`sales.order_date < members.join_date`).
- In the outer query, using the  **WHERE** clause, filter to retrieve only the rows where rank equals 1, representing the first rows within each `customer_id` partition.

#### Answer:
| customer_id | order_date | join_date  | product_name |
| ----------- | ---------- | ---------- | ------------ |
| A           | 2021-01-01 | 2021-01-07 | sushi        |
| A           | 2021-01-01 | 2021-01-07 | curry        |
| B           | 2021-01-04 | 2021-01-09 | sushi        |

- Customer A's last order before becoming a member is sushi and curry.

- Customer B's last order before becoming a member is sushi.

***

**8. How many items did each customer purchase, and how much did they spend in total before becoming members?**

````sql
SELECT
  s.customer_id,
  COUNT(s.product_id) AS total_unique_items,
  SUM(mm.price) AS total_sales
FROM sales AS s
JOIN members AS m
	ON s.customer_id = m.customer_id
JOIN menu AS mm
	ON s.product_id = mm.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;
````

#### Steps:
- Select the column `customer_id` and calculate the count of `product_id` as total_items for each customer and the sum of `menu.price` as total_sales.
- Join `sales` table with `members` table on `customer_id` column, then join `menu` table to `sales` table on `product_id` column, ensuring that `sales.order_date` is earlier than `members.join_date` (`sales.order_date < members.join_date`).
- Group the results by `sales.customer_id`.

#### Answer:
| customer_id | total_items | total_sales |
| ----------- | ----------- | ----------- |
| A           | 2           |  25         |
| B           | 3           |  40         |

Before becoming members,
- Customer A spent $25 on 2 items.
- Customer B spent $40 on 3 items.

***

**9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**

````sql
WITH price_points_cte AS
(
    SELECT *, 
	    CASE 
            WHEN product_name = 'sushi' THEN price * 20
		    ELSE price * 10 
        END AS points
	FROM menu
)

SELECT
  s.customer_id,
  SUM(p.points) AS total_pts
FROM price_points_cte AS p 
JOIN sales AS s
    ON p.product_id = s.product_id
GROUP BY s.customer_id;
````

#### Steps:
Let's break down the question to understand the point calculation for each customer's purchases.
- Each $1 spent = 10 points. However, `product_id` 1 sushi gets 2x points, so each $1 spent = 20 points.
- Here's how the calculation is performed using a conditional CASE statement:
	- If product_name = 'sushi', multiply every $1 by 20 points.
	- Otherwise, multiply $1 by 10 points.
- Then, calculate the total points for each customer.

#### Answer:
| customer_id | total_pts    | 
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| C           | 360          |

- Total points for Customer A is $860.
- Total points for Customer B is $940.
- Total points for Customer C is $360.

***

**10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?**

````sql
WITH dates_cte AS 
(
	SELECT 
    *, 
    DATEADD(DAY, 6, join_date) AS valid_date, 
		EOMONTH('2021-01-31') AS last_date
	FROM members AS m
)

SELECT
  d.customer_id,
  SUM(CASE
        WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
        WHEN s.order_date BETWEEN d.join_date AND d.valid_date THEN 2 * 10 * m.price
        ELSE 10 * m.price
      END) AS points
FROM dates_cte AS d 
JOIN sales AS s 
    ON d.customer_id = s.customer_id
JOIN menu AS m 
    ON s.product_id = m.product_id
WHERE s.order_date <= d.last_date
GROUP BY d.customer_id;
````
### Assumptions:
- On Day -X to Day 1 (the day a customer becomes a member), each $1 spent earns 10 points. However, for sushi, each $1 spent earns 20 points.
- From Day 1 to Day 7 (the first week of membership), each $1 spent for any items earns 20 points.
- From Day 8 to the last day of January 2021, each $1 spent earns 10 points. However, sushi continues to earn double the points at 20 points per $1 spent.

#### Steps:
- Create a CTE called `dates_cte`. 
- In `dates_cte`, calculate the `valid_date` by adding 6 days to the `join_date` and determine the `last_date` of the month by subtracting the `EOMONTH` function.
- From `sales` table, join `dates_cte` on `customer_id` column, ensuring that the `order_date` of the sale is not later than the `last_date` (`sales.order_date <= dates.last_date`).
- Then, join `menu` table on the `product_id` column.
- In the outer query, calculate the points by using a `CASE` statement to determine the points based on our assumptions above. 
    - If the `product_name` is 'sushi', multiply the price by 2 and then by 10. For orders placed between `join_date` and `valid_date`, also multiply the price by 2 and then by 10. 
    - For all other products, multiply the price by 10.
- Calculate the sum of points for each customer.

#### Answer:
| customer_id | total_points | 
| ----------- | ------------ |
| A           | 1370         |
| B           | 820          |

- Total points for Customer A is 1,370.
- Total points for Customer B is 820.

***

## BONUS QUESTIONS

**1. Join All: Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)**

````sql
SELECT
  s.customer_id,
  s.order_date,
  m.product_name,
  m.price,
  CASE
    WHEN mm.join_date <= s.order_date THEN 'Y'
    ELSE 'N'
  END AS member_status
FROM sales AS s
JOIN menu AS m 
    ON s.product_id = m.product_id
LEFT JOIN members AS mm
    ON s.customer_id = mm.customer_id;
````
#### Answer: 
| customer_id | order_date | product_name | price | member_status |
| ----------- | ---------- | -------------| ----- | ------------- |
| A           | 2021-01-01 | sushi        | 10    | N             |
| A           | 2021-01-01 | curry        | 15    | N             |
| A           | 2021-01-07 | curry        | 15    | Y             |
| A           | 2021-01-10 | ramen        | 12    | Y             |
| A           | 2021-01-11 | ramen        | 12    | Y             |
| A           | 2021-01-11 | ramen        | 12    | Y             |
| B           | 2021-01-01 | curry        | 15    | N             |
| B           | 2021-01-02 | curry        | 15    | N             |
| B           | 2021-01-04 | sushi        | 10    | N             |
| B           | 2021-01-11 | sushi        | 10    | Y             |
| B           | 2021-01-16 | ramen        | 12    | Y             |
| B           | 2021-02-01 | ramen        | 12    | Y             |
| C           | 2021-01-01 | ramen        | 12    | N             |
| C           | 2021-01-01 | ramen        | 12    | N             |
| C           | 2021-01-07 | ramen        | 12    | N             |

***

**2. Recreate the table with: customer_id, order_date, product_name, price, member (Y/N), ranking(null/123) - in terms of the order of items bought after becoming a member.**

````sql
WITH summary_cte AS
(
  SELECT
  s.customer_id,
  s.order_date,
  m.product_name,
  m.price,
  CASE
    WHEN mm.join_date <= s.order_date THEN 'Y'
    ELSE 'N'
  END AS member_status
FROM sales AS s
JOIN menu AS m 
    ON s.product_id = m.product_id
LEFT JOIN members AS mm
    ON s.customer_id = mm.customer_id
)

SELECT 
  *,
  CASE
    WHEN member_status = 'N' then NULL
    ELSE RANK() OVER (
      PARTITION BY customer_id, member_status 
      ORDER BY order_date)
  END AS ranking
FROM summary_cte;
````

#### Answer: 
| customer_id | order_date | product_name | price | member_status | ranking | 
| ----------- | ---------- | -------------| ----- | ------------- | ------- |
| A           | 2021-01-01 | sushi        | 10    | N             | NULL    |
| A           | 2021-01-01 | curry        | 15    | N             | NULL    |
| A           | 2021-01-07 | curry        | 15    | Y             | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y             | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y             | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y             | 3       |
| B           | 2021-01-01 | curry        | 15    | N             | NULL    |
| B           | 2021-01-02 | curry        | 15    | N             | NULL    |
| B           | 2021-01-04 | sushi        | 10    | N             | NULL    |
| B           | 2021-01-11 | sushi        | 10    | Y             | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y             | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y             | 3       |
| C           | 2021-01-01 | ramen        | 12    | N             | NULL    |
| C           | 2021-01-01 | ramen        | 12    | N             | NULL    |
| C           | 2021-01-07 | ramen        | 12    | N             | NULL    |

***