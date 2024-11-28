-- SQL SERVER --
CREATE DATABASE pizza_project;

USE pizza_project;

 /* Tables and their columns
order_details --order_details_id, order_id, pizza_id, quantity
orders --order_id, date, time
pizza_types --pizza_type_id, name, category, ingredients
pizzas --pizza_id, pizza_type_id, size, price
*/

-- 1. Showing total number of orders placed.
SELECT COUNT(DISTINCT Order_id) Total_no_orders
FROM Orders;

--2. Showing total revenue generated from pizza sales.
SELECT CAST(SUM(od.Quantity * p.Price) AS DECIMAL(12,2)) AS Total_Revenue
FROM order_details AS od
JOIN pizzas AS p
ON od.pizza_id = p.pizza_id;

--3. Showing the total pizzas sold
SELECT SUM(quantity) AS Total_pizza_sold
FROM order_details;

--4. Showing the average pizza per order
SELECT SUM(quantity) / COUNT(DISTINCT o.Order_id) AS Avg_pizza_per_order
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id;

--5. Showing the highest-priced pizza.
SELECT TOP 1
pt.Name, p.Price
FROM pizza_types AS pt
JOIN pizzas AS p
ON pt.pizza_type_id = p.pizza_type_id
ORDER BY price DESC;

  /* Using window function
WITH cte AS(
SELECT pt.Name, p.Price,
RANK() OVER(ORDER BY price DESC) AS rnk
FROM pizza_types AS pt
JOIN pizzas AS p
ON pt.pizza_type_id = p.pizza_type_id)
SELECT Name, Price
FROM cte
WHERE rnk = 1;
*/

--6. Showing the most common pizza size ordered
SELECT p.Size, COUNT(DISTINCT od.order_id) No_of_Orders, SUM(od.quantity) Total_Quantity_Ordered
FROM pizzas AS p
JOIN order_details AS od
ON p.pizza_id = od.pizza_id
GROUP BY size
ORDER BY Total_Quantity_Ordered DESC;

--7. Showing the top 5 most ordered pizza types along with their quantities.
SELECT TOP 5
pt.Name, SUM(od.quantity) Total_Quantity_Ordered
FROM order_details od
JOIN pizzas AS p
ON p.pizza_id = od.pizza_id
JOIN pizza_types AS pt
ON p.pizza_type_id = pt.pizza_type_id 
GROUP BY Name
ORDER BY Total_Quantity_Ordered DESC;

--8. Showing the total quantity of each pizza category ordered
SELECT pt.Category AS 'Pizza Category', SUM(od.quantity) AS Total_Quantity_Ordered
FROM order_details od
JOIN pizzas AS p
ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY Category
ORDER BY Total_Quantity_Ordered DESC;

--9. Showing the distribution of orders by hour of the day
SELECT DATEPART(HOUR,time) AS Hour_of_day, COUNT(order_id) AS No_of_Orders
FROM orders
GROUP BY DATEPART(HOUR,time)
ORDER BY No_of_Orders DESC;

--10. Showing the distribution of orders by Month
SELECT CASE MONTH(date)
			WHEN 1 THEN 'January'
			WHEN 2 THEN 'February'
			WHEN 3 THEN 'March'
			WHEN 4 THEN 'April'
			WHEN 5 THEN 'May'
			WHEN 6 THEN 'June'
			WHEN 7 THEN 'July'
			WHEN 8 THEN 'August'
			WHEN 9 THEN 'September'
			WHEN 10 THEN 'October'
			WHEN 11 THEN 'November'
			ELSE 'December'
		END Month,
COUNT(order_id) No_of_Orders
FROM orders
GROUP BY MONTH(Date)
ORDER BY MONTH(Date);

--11. Showing category-wise distribution of pizzas.
SELECT Category , COUNT(DISTINCT pizza_type_id) AS 'No of Pizzas'
FROM pizza_types
GROUP BY Category;

--12. Showing the orders by date and calculate the average number of pizzas ordered per day.
WITH cte AS (
SELECT o.Date AS 'Date', SUM(od.quantity) AS Total_Quantity_Ordered
FROM orders o
JOIN order_details od
ON o.order_id = od.order_id
GROUP BY Date)
SELECT AVG(Total_Quantity_Ordered) AS 'Avg Number of pizzas ordered per day'
FROM cte;

--13. Showing the top 3 most ordered pizza types based on revenue
SELECT TOP 3
pt.Name AS 'Pizza types',
CAST(SUM(od.Quantity * p.Price) AS DECIMAL(12,2)) AS Total_Revenue
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od
ON p.pizza_id = od.pizza_id
GROUP BY Name
ORDER BY Total_Revenue DESC;

  /* Using window function
WITH cte AS(
SELECT pt.Name, CAST(SUM(od.Quantity * p.Price) AS DECIMAL(12,2)) AS 'Revenue from Pizza',
RANK() OVER(ORDER BY SUM(od.Quantity * p.Price) DESC) rnk
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od
ON p.pizza_id = od.pizza_id
GROUP BY Name)
SELECT Name, [Revenue from Pizza]
FROM cte
WHERE rnk <4
*/

--14. Showing the top 3 most ordered pizza types based on revenue for each pizza category
WITH cte1 AS(
SELECT pt.Category, pt.Name, CAST(SUM(od.Quantity * p.Price) AS DECIMAL(10,2)) AS Revenue
FROM pizzas p
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od
ON p.pizza_id = od.pizza_id
GROUP BY category,name
),
cte2 AS
(SELECT *, RANK() OVER(PARTITION BY category ORDER BY Revenue DESC) AS rnk
FROM cte1
)
SELECT Category, Name, Revenue
FROM cte2
WHERE rnk IN (1,2,3)
ORDER BY Category, Name, Revenue; 

--15. Showing the cumulative revenue generated over time.
WITH cte AS(
SELECT o.Date, CAST(SUM(od.Quantity * p.Price) AS DECIMAL(12,2)) AS Revenue
FROM Order_details od
JOIN orders o
ON od.order_id = o.order_id
JOIN pizzas p
ON od.pizza_id = p.pizza_id
GROUP BY Date)
SELECT Date, Revenue, SUM(Revenue) OVER(ORDER BY date) AS 'Cumulative Revenue'
FROM cte;

--16. Showing cumulative monthly revenue
WITH cte AS(
SELECT CASE MONTH(date)
			WHEN 1 THEN 'January'
			WHEN 2 THEN 'February'
			WHEN 3 THEN 'March'
			WHEN 4 THEN 'April'
			WHEN 5 THEN 'May'
			WHEN 6 THEN 'June'
			WHEN 7 THEN 'July'
			WHEN 8 THEN 'August'
			WHEN 9 THEN 'September'
			WHEN 10 THEN 'October'
			WHEN 11 THEN 'November'
			ELSE 'December'
		END Month,
 MONTH(date) AS Month_no,
CAST(SUM(od.Quantity * p.Price) AS DECIMAL(12,2)) AS Revenue
FROM Order_details od
JOIN orders o
ON od.order_id = o.order_id
JOIN pizzas p
ON od.pizza_id = p.pizza_id
GROUP BY MONTH(date))
SELECT Month, Revenue, SUM(Revenue) OVER(ORDER BY Month_no) AS 'Monthly Cumulative Revenue'
FROM cte;
