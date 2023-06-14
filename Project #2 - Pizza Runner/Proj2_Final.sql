--------------------------------
--CASE STUDY #2: PIZZA RUNNER--
--------------------------------

--Author: Lye Tse Yong
--Date: 14/06/2023 
--Tools used: MS SQL Server, VSCode 

WITH customer_orders_cte AS
    (SELECT
        order_id,
        customer_id,
        pizza_id,
        CASE 
  	        WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ''
    	    ELSE exclusions 
    	    END AS exclusions,
        CASE 
  	        WHEN extras IS NULL OR extras LIKE 'null' THEN ''
    	    ELSE extras 
    	    END AS extras,
        order_time
     FROM customer_orders
    )

SELECT *
FROM customer_orders_cte