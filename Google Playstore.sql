CREATE DATABASE google_playstore_project;

--DATA CLEANING; REMOVING NULL VALUES
DELETE FROM dbo.googleplaystore
WHERE App IS NULL
OR Category IS NULL
OR Rating IS NULL
OR Reviews IS NULL
OR Size IS NULL
OR Installs IS NULL
OR Type IS NULL
OR Price IS NULL
OR Content_Rating IS NULL
OR Genres IS NULL
OR Last_Updated IS NULL
OR Current_Ver IS NULL
OR Android_Ver IS NULL;

--1. Showing the overview of the dataset
SELECT
	COUNT(DISTINCT App) AS total_apps,
	COUNT(DISTINCT Category) AS total_category
FROM dbo.googleplaystore

--2. Exploring the app categories
SELECT
	Category,
	COUNT(App) total_apps
FROM dbo.googleplaystore
GROUP BY Category
--ORDER by total_apps DESC;

--3. Showing the top-rated free apps
SELECT
	App,
	Rating
FROM dbo.googleplaystore
WHERE Type = 'Free'
ORDER BY Rating DESC;

--4. Showing the most reviewed apps
SELECT
	App,
	Reviews
FROM dbo.googleplaystore
ORDER BY Reviews DESC ;

--5. Showing the average rating for each category
SELECT
	Category,
	AVG(Rating) AS avg_rating
FROM dbo.googleplaystore
GROUP BY Category
--ORDER by avg_rating;

--6. Showing the categories with the highest number of installs
SELECT
	Category,
	SUM(Installs) AS total_installs
FROM dbo.googleplaystore
GROUP BY Category
ORDER BY total_installs DESC;

--7. Showing the average sentiment polarity by app category
SELECT 
	a.Category,
	AVG(b.Sentiment_Polarity) AS avg_sent_polarity
FROM googleplaystore a 
JOIN googleplaystore_user_reviews b
ON a.app = b.app
GROUP BY category
--ORDER BY avg_sent_polarity;

--8. Showing the distribution of sentiments across different app categories
SELECT
	Category,
	Sentiment,
	COUNT(*) AS total_sentiment
FROM googleplaystore a
JOIN googleplaystore_user_reviews b
ON a.app = b.app
GROUP BY category, sentiment
ORDER BY total_sentiment DESC;
