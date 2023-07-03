# 🍕 Project #2 Pizza Runner
<img src="https://8weeksqlchallenge.com/images/case-study-designs/2.png" alt="Image" width="500" height="500">

## 📚 Table of Contents
- [Business Task](#business-task)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Data Cleaning](#data-cleaning)
- [Solutions](#solutions)

Note: All information regarding the case study has been sourced from the following [link](https://8weeksqlchallenge.com/case-study-2/).

***

## :dart: Business Task
Danny is expanding his new Pizza Empire and at the same time, he wants to Uberize it, so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers. 

***

## :link: Entity Relationship Diagram

![Pizza Runner](https://user-images.githubusercontent.com/81607668/242152356-78099a4e-4d0e-421f-a560-b72e4321f530.png)

***

## :construction: Data Cleaning

There are some known data issues with few tables. Data cleaning was performed and saved in temporary tables before attempting the case study solutions.

`customer_orders` table

- The exclusions and extras columns in customer_orders table will need to be cleaned up before using them in the queries.
- In the exclusions and extras columns, there are blank spaces and null values.

`runner_orders` table

- The pickup_time, distance, duration and cancellation columns in runner_orders table will need to be cleaned up before using them in the queries.
- In the pickup_time column, there are null values.
- In the distance column, there are null values. It contains the unit - km. The 'km' must be stripped
- In the duration column, there are null values. The 'minutes', 'mins', 'minute' units must be stripped
- In the cancellation column, there are blank spaces and null values.

***

## :bulb: Solutions

This is a lengthy case study, thus, it is divided into five sections (after data cleaning):

  - [0. Data Cleaning](https://github.com/tseyongg/Tse_Yong_SQL_Projects/blob/main/Project%20%232%20-%20Pizza%20Runner/Solutions/0.%20Data%20Clean.md)
  - [A. Pizza Metrics](https://github.com/tseyongg/Tse_Yong_SQL_Projects/blob/main/Project%20%232%20-%20Pizza%20Runner/Solutions/A.%20Pizza%20Metrics.md)
  - [B. Runner and Customer Experience](https://github.com/tseyongg/Tse_Yong_SQL_Projects/blob/main/Project%20%232%20-%20Pizza%20Runner/Solutions/B.%20Runner%20and%20Customer%20Experience.md)
  - [C. Ingredient Optimisation](https://github.com/tseyongg/Tse_Yong_SQL_Projects/blob/main/Project%20%232%20-%20Pizza%20Runner/Solutions/C.%20Ingredient%20Optimisation.md)
  - [D. Pricing and Ratings](https://github.com/tseyongg/Tse_Yong_SQL_Projects/blob/main/Project%20%232%20-%20Pizza%20Runner/Solutions/D.%20Pricing%20and%20Ratings.md)
  - [E. Bonus Questions](https://github.com/tseyongg/Tse_Yong_SQL_Projects/blob/main/Project%20%232%20-%20Pizza%20Runner/Solutions/E.%20Bonus%20Questions.md)
