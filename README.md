# [8-Week SQL Challenge](https://github.com/ndleah/8-Week-SQL-Challenge) 
![Star Badge](https://img.shields.io/static/v1?label=%F0%9F%8C%9F&message=If%20Useful&style=style=flat&color=BC4E99)
[![View Main Folder](https://img.shields.io/badge/View-Main_Folder-971901?)](https://github.com/ndleah/8-Week-SQL-Challenge)
[![View Repositories](https://img.shields.io/badge/View-My_Repositories-blue?logo=GitHub)](https://github.com/harshwadiya?tab=repositories)
[![View My Profile](https://img.shields.io/badge/View-My_Profile-green?logo=GitHub)](https://github.com/harshwadiya)

# 🍜 Case Study #1 - Danny's Diner
<p align="center">
<img src="/IMG/org-1.png" width=40% height=40%>

## 📕 Table Of Contents
* 🛠️ [Problem Statement](#problem-statement)
* 📂 [Dataset](#dataset)
* 🧙‍♂️ [Case Study Questions](#case-study-questions)
* 🚀 [Solutions](#solutions)

  
---

## 🛠️ Problem Statement

> Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

 <br /> 

---

## 📂 Dataset
Danny has shared with you 3 key datasets for this case study:

### **```sales```**

<details>
<summary>
View table
</summary>

The sales table captures all ```customer_id``` level purchases with an corresponding ```order_date``` and ```product_id``` information for when and what menu items were ordered.

|customer_id|order_date|product_id|
|-----------|----------|----------|
|A          |2021-01-01|1         |
|A          |2021-01-01|2         |
|A          |2021-01-07|2         |
|A          |2021-01-10|3         |
|A          |2021-01-11|3         |
|A          |2021-01-11|3         |
|B          |2021-01-01|2         |
|B          |2021-01-02|2         |
|B          |2021-01-04|1         |
|B          |2021-01-11|1         |
|B          |2021-01-16|3         |
|B          |2021-02-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-07|3         |

 </details>

### **```menu```**

<details>
<summary>
View table
</summary>

The menu table maps the ```product_id``` to the actual ```product_name``` and price of each menu item.

|product_id |product_name|price     |
|-----------|------------|----------|
|1          |sushi       |10        |
|2          |curry       |15        |
|3          |ramen       |12        |

</details>

### **```members```**

<details>
<summary>
View table
</summary>

The final members table captures the ```join_date``` when a ```customer_id``` joined the beta version of the Danny’s Diner loyalty program.

|customer_id|join_date |
|-----------|----------|
|A          |1/7/2021  |
|B          |1/9/2021  |

 </details>

## 🧙‍♂️ Case Study Questions
<p align="center">
<img src="https://ugokawaii.com/wp-content/uploads/2022/12/QA.gif" width=50% height=50%>

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

 <br /> 

## 🚀 Solutions

### **Q1. What is the total amount each customer spent at the restaurant?**
```sql
SELECT s.customer_id,
       SUM(m.price) AS Total_amount
FROM sales AS s
INNER JOIN menu AS m
    ON s.product_id = m.product_id
GROUP BY s.customer_id;
```

| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

---

### **Q2. How many days has each customer visited the restaurant?**
```sql
SELECT
     customer_id,
     COUNT (DISTINCT order_date) AS Visit_To_Restaurant
FROM sales
GROUP BY customer_id;

```

|customer_id|Visit_To_Restaurant|
|-----------|------------|
|A          |4           |
|B          |6           |
|C          |2           |


---

### **Q3. What was the first item from the menu purchased by each customer?**

```sql
SELECT customer_id,
       product_name
FROM (
        SELECT s.customer_id,
               s.order_date,
               m.product_name,
               ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY order_date ASC) ranking
        FROM members AS mem
        RIGHT JOIN sales AS s
            ON s.customer_id = mem.customer_id
        LEFT JOIN menu AS m
            ON m.product_id = s.product_id
     ) t
WHERE ranking = 1;

```

**Result:**
| customer_id | product_name |
| ----------- | ------------ |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

---

### **Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
```sql
SELECT TOP 1
      menu.product_name,
      COUNT(sales.product_id) AS order_count
FROM sales
INNER JOIN menu
      ON sales.product_id = menu.product_id
GROUP BY
      menu.product_name
ORDER BY order_count DESC;  
```

|product_name|order_count|
|------------|-----------|
|ramen       |8          |

---

### **Q5. Which item was the most popular for each customer?**

```sql
WITH cte_order_count AS (
  SELECT
    sales.customer_id,
    menu.product_name,
    COUNT(*) as order_count
  FROM dannys_diner.sales
  JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
  GROUP BY 
    customer_id,
    product_name
  ORDER BY
    customer_id,
    order_count DESC
),
cte_popular_rank AS (
  SELECT 
    *,
    RANK() OVER(PARTITION BY customer_id ORDER BY order_count DESC) AS rank
  FROM cte_order_count
)
SELECT * FROM cte_popular_rank
WHERE rank = 1;
```
| customer_id | product_id | product_name | order_count | ranking |
|-------------|------------|--------------|-------------|---------|
| A           | 1          | sushi        | 1           | 1       |
| B           | 1          | sushi        | 2           | 1       |
| B           | 2          | curry        | 2           | 1       |
| B           | 3          | ramen        | 2           | 1       |
| C           | 3          | ramen        | 3           | 1       |

---

---

### **Q6. Which item was purchased first by the customer after they became a member?**

```sql
WITH cte1 AS (
    SELECT s.customer_id,
           s.order_date,
           mem.join_date,
           m.product_name,
           DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) ranking
    FROM sales AS s
    JOIN members AS mem
        ON mem.customer_id = s.customer_id
    JOIN menu AS m
        ON m.product_id = s.product_id
    WHERE mem.join_date < s.order_date
)
SELECT customer_id,
       product_name
FROM cte1
WHERE ranking = 1;

```

| customer_id | product_name |
|-------------|--------------|
| A           | ramen        |
| B           | sushi        |


---

### **Q7. Which item was purchased just before the customer became a member?**

```sql
WITH cte1 AS (
        SELECT s.customer_id,
               mem.join_date,
               s.order_date,
               m.product_name,
               DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) ranking
        FROM sales AS s
        JOIN members AS mem
                ON mem.customer_id = s.customer_id
        JOIN menu AS m
                ON m.product_id = s.product_id
        WHERE mem.join_date > s.order_date
)
SELECT customer_id,
       product_name
FROM cte1
WHERE ranking = 1;

```

| customer_id | product_name |
|-------------|--------------|
| A           | sushi        |
| A           | curry        |
| B           | sushi        |


---

### **Q8. What is the total items and amount spent for each member before they became a member?**
```sql
SELECT s.customer_id,
       COUNT(m.product_id) AS no_of_orders,
       SUM(price) AS total_amount
FROM SALES AS s
INNER JOIN menu AS m
       ON m.product_id = s.product_id
INNER JOIN members AS mem
       ON mem.customer_id = s.customer_id
WHERE join_date > order_date
GROUP BY s.customer_id;

```

| customer_id | no_of_orders | total_amount |
|-------------|--------------|--------------|
| A           | 2            | 25           |
| B           | 3            | 40           |

---

### **Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```sql
WITH cte1 AS (
        SELECT s.customer_id,
               m.product_name,
               SUM(price) total_sales
        FROM SALES AS s
        FULL JOIN menu AS m
                ON m.product_id = s.product_id
        FULL JOIN members AS mem
                ON mem.customer_id = s.customer_id
        GROUP BY s.customer_id,
                 m.product_name
),
cte2 AS (
        SELECT customer_id,
               total_sales,
               CASE
                    WHEN product_name = 'sushi' THEN total_sales * 10 * 2
                    ELSE total_sales * 10
               END Points
        FROM cte1
)

SELECT customer_id,
       SUM(Points) AS total_points
FROM cte2
GROUP BY customer_id
ORDER BY customer_id;

```

| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |
| c           | 360          |

---

### **Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

I have created a timeline as illustration for wheareas we apply the conditions:
<p align="center">
<img src="https://github.com/ndleah/8-Week-SQL-Challenge/blob/main/IMG/timeline.png" width=100% height=100%>

  ```sql
WITH cte AS (
        SELECT s.customer_id,
               m.product_name,
               m.price,
               order_date,
               join_date,
               CASE
                    WHEN s.order_date BETWEEN mb.join_date AND DATEADD(day, 7, mb.join_date)
                         THEN m.price * 10 * 2
                    WHEN m.product_name = 'sushi'
                         THEN m.price * 10 * 2
                    ELSE m.price * 10
               END AS points
        FROM menu m
        JOIN sales s
             ON s.product_id = m.product_id
        JOIN members mb
             ON s.customer_id = mb.customer_id
        WHERE order_date < '2021-02-01'
)
SELECT customer_id,
       SUM(points) AS total_points
FROM cte
GROUP BY customer_id;

```

| customer_id | total_Points |
| ----------- | ------------ |
| A           | 1370         | 
| B           | 940          | 



---
<p>&copy; 2025 Harsh Wadiya </p>


