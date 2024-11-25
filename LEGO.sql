-- for this project, I also made use of views.

CREATE VIEW dbo.analytics_main AS
SELECT
	s.set_num,
	s.name AS set_name,
	s.year,
	s.theme_id,
	CAST(s.num_parts AS NUMERIC) num_parts,
	t.name AS theme_name,
	t.parent_id,
	p.name AS parent_theme_name,
	CASE
		WHEN s.year BETWEEN 1901 AND 2000 THEN '20th_Century'
		WHEN s.year BETWEEN 2001 AND 2100 THEN '21st_Century'
	END AS Century
FROM dbo.sets s
LEFT JOIN dbo.themes t
ON s.theme_id = t.id
LEFT JOIN dbo.themes p
ON t.parent_id = p.id;

--1. Showing the total number of parts per theme
SELECT
	t.name AS theme_name,
	SUM(CAST(s.num_parts AS NUMERIC)) AS total_num_parts
FROM dbo.sets s
LEFT JOIN dbo.themes t
ON s.theme_id = t.id
GROUP BY t.name
ORDER BY total_num_parts DESC;

/* using the views created
SELECT
	theme_name,
	SUM(num_parts) AS total_num_parts		
FROM dbo.analytics_main
GROUP BY theme_name
ORDER BY total_num_parts DESC;
*/

--2. Showing the total number of parts per year
SELECT 
	year,
	SUM(CAST(num_parts AS NUMERIC)) AS total_num_parts
FROM dbo.sets
GROUP BY year
ORDER BY total_num_parts DESC;

/* using the views created
SELECT
	year,
	SUM(num_parts) AS total_num_parts
FROM dbo.analytics_main
GROUP BY year
ORDER BY total_num_parts DESC;
*/

--3.  Showing how many sets where created in each century in the dataset
WITH cte AS
(
SELECT 
	CASE
		WHEN year BETWEEN 1901 AND 2000 THEN '20th_Century'
		WHEN year BETWEEN 2001 AND 2100 THEN '21th_Century'
	END AS Century
	, COUNT(set_num) AS total_set_num
FROM sets
GROUP BY (CASE
			WHEN year BETWEEN 1901 AND 2000 THEN '20th_Century'
			WHEN year BETWEEN 2001 AND 2100 THEN '21th_Century'
		 END)

/* using the views created
SELECT 
	Century,  
	COUNT(set_num) AS total_set_num
FROM dbo.analytics_main
GROUP BY century
*/

--4. Showing the percentage of sets ever released in the 21st Century that were trains themed
WITH cte AS
(
SELECT
	CASE
		WHEN year BETWEEN 1901 AND 2000 THEN '20th_Century'
		WHEN year BETWEEN 2001 AND 2100 THEN '21st_Century'
	END AS Century,
	t.name AS theme_name,
	COUNT(set_num) AS total_set_num
FROM dbo.sets s
LEFT JOIN dbo.themes t
ON s.theme_id = t.id
GROUP BY t.name,
		CASE
			WHEN year BETWEEN 1901 AND 2000 THEN '20th_Century'
			WHEN year BETWEEN 2001 AND 2100 THEN '21st_Century'
		END
)
SELECT *, 
	SUM(total_set_num) OVER() AS total,
	total_set_num / SUM(total_set_num) OVER() * 100 AS percentage
FROM cte
WHERE century = '21st_century' AND theme_name = 'trains'
ORDER BY 3 DESC;

/* using the views created
WITH cte AS
(
SELECT 
	century,
	theme_name,
	COUNT(set_num) AS total_set_num
FROM dbo.analytics_main
WHERE century = '21st_century'
GROUP BY century, theme_name
)
SELECT 
	century,
	theme_name,
	total_set_num,
	SUM(total_set_num) OVER() AS total,
	total_set_num / SUM(total_set_num) OVER() * 100 AS percentage
FROM cte
WHERE theme_name = 'trains'
ORDER BY 3 DESC;
*/

--5. Showing the popular theme by year in terms of set released in the 21st century
WITH cte AS
(
SELECT
	s.year,
	t.name AS theme_name,
	COUNT(set_num) AS total_set_num,
	RANK() OVER(PARTITION BY year ORDER BY COUNT(set_num) DESC) AS rnk,
	CASE
		WHEN s.year BETWEEN 1901 AND 2000 THEN '20th_Century'
		WHEN s.year BETWEEN 2001 AND 2100 THEN '21st_Century'
	END AS Century
FROM dbo.sets s
LEFT JOIN dbo.themes t
ON s.theme_id = t.id
GROUP BY year, t.name
)
SELECT year, theme_name, total_set_num
FROM cte
WHERE century = '21st_century' AND rnk = 1
ORDER BY year DESC;

/* using the views created
WITH cte AS
(
SELECT
	year,
	theme_name, 
	COUNT(set_num) AS total_set_num,
	RANK() OVER(PARTITION BY year ORDER BY count(set_num) DESC) rnk
FROM dbo.analytics_main
WHERE century =  '21st_century'
GROUP BY year, theme_name
) 
SELECT year, theme_name, total_set_num
FROM cte
WHERE rnk = 1
ORDER BY year DESC;
*/

--6. Showing the most produced color of lego ever in terms of quantity of parts
SELECT 
	c.name AS color_name,
	SUM(CAST(inv.quantity AS NUMERIC)) AS quantity_of_parts
FROM dbo.colors c
JOIN inventory_parts inv
ON inv.color_id = c.id
GROUP BY name
ORDER BY 2 DESC
