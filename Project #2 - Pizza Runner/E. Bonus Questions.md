# :pizza: Case Study #2: Pizza runner - E. Bonus Questions

## E. Bonus Questions

If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an *INSERT* statement to demonstrate what would happen if a new *Supreme* pizza with all the toppings was added to the Pizza Runner menu?

- Alter columns from limit 30 to 50 to fit all 12 toppings

````sql 
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES (3, 'Supreme');

ALTER TABLE pizza_recipes
ALTER COLUMN toppings VARCHAR(50);

INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');
````
