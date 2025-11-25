/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
  
													/* --------------------
														Solutions
													--------------------*/

   select * from members
   select * from sales
   select * from menu


   /*view Full Joined Table*/
 
			select	s.customer_id,
				s.product_id ,
				mem.join_date,
				s.order_date,
				m.product_name, 
				m.price from members as mem
		full join sales as s
		on s.customer_id = mem.customer_id
		full join menu as m
		on m.product_id = s.product_id


-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id,
       SUM(m.price) AS Total_amount
FROM sales AS s
INNER JOIN menu AS m
    ON s.product_id = m.product_id
GROUP BY s.customer_id;


-- 2. How many days has each customer visited the restaurant?
	SELECT
		 customer_id,
		COUNT (DISTINCT order_date) AS Visit_To_Restaurant
		FROM sales
		GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
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

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP 1
      menu.product_name,
      COUNT(sales.product_id) AS order_count
FROM sales
INNER JOIN menu
      ON sales.product_id = menu.product_id
GROUP BY
      menu.product_name
ORDER BY order_count DESC;


-- 5. Which item was the most popular for each customer?
SELECT * 
FROM (
        SELECT  s.customer_id,
                m.product_id,
                m.product_name,
                COUNT(product_name) order_count,
                DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(product_name)) AS ranking
        FROM sales AS s
        INNER JOIN menu AS m
                ON s.product_id = m.product_id
        GROUP BY s.customer_id,
                 m.product_id,
                 m.product_name
     ) t
WHERE ranking = 1;


-- 6. Which item was purchased first by the customer after they became a member?
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

-- 7. Which item was purchased just before the customer became a member?
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


-- 8. What is the total items and amount spent for each member before they became a member?
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

/* 9. If each $1 spent equates to 10 points 
	and sushi has a 2x points multiplier - 
	how many points would each customer have? */
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


/*10. In the first week after a customer joins the program 
(including their join date) they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January?*/

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
