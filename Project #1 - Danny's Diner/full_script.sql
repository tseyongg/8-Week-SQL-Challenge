--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

--Author: Lye Tse Yong
--Date: 05/06/2023 
--Tools used: MS SQL Server, VSCode 


------------------------
--CASE STUDY QUESTIONS--
------------------------

--1. What is the total amount each customer spent at the restaurant?
SELECT 
  s.customer_id, 
  SUM(price) AS total_sales
FROM dbo.sales AS s
JOIN dbo.menu AS m
  ON s.product_id = m.product_id
GROUP BY customer_id;

--2. How many days has each customer visited the restaurant?
SELECT 
  customer_id, 
  COUNT(DISTINCT(order_date)) AS visit_count
FROM dbo.sales
GROUP BY customer_id;

--3. What was the first item from the menu purchased by each customer?
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

--4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
  TOP 1 product_name,
  COUNT(product_name) AS most_purchased
FROM dbo.sales AS s
JOIN dbo.menu AS m
  ON s.product_id = m.product_id
GROUP BY product_name
ORDER BY most_purchased DESC;

--5. Which item was the most popular for each customer?
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

--6. Which item was purchased first by the customer after they became a member?
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

--7. Which item was purchased just before the customer became a member?
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

--8. How many items did each customer purchase, and how much did they spend in total before becoming members?
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

--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
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

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
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

------------------------
--BONUS QUESTIONS-------
------------------------

-- 1. Join All : Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
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

-- 2. Recreate the table with: customer_id, order_date, product_name, price, member (Y/N), ranking(null/123)
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
