-- SCHEMAS of Netflix
create database Net;
use Net;
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix;

-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems
-- 1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY 1

-- 2. Find the most common rating for movies and TV shows
SELECT type, rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix
    GROUP BY type, rating
) t
WHERE rnk = 1;


-- 4. Find the top 5 countries with the most content on Netflix
SELECT country, COUNT(*) AS total_content
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n.n), ',', -1)) AS country
    FROM netflix
    JOIN (
        SELECT a.N + b.N * 10 + 1 AS n
        FROM (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
        CROSS JOIN 
             (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    ) n
    ON n.n <= 1 + LENGTH(country) - LENGTH(REPLACE(country, ',', ''))
) AS c
WHERE country IS NOT NULL AND country <> ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;


-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT *
FROM (
    SELECT *,
           TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(director, ',', n.n), ',', -1)) AS director_name
    FROM netflix
    JOIN (
        SELECT a.N + b.N * 10 + 1 AS n
        FROM (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
        CROSS JOIN 
             (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    ) n
    ON n.n <= 1 + LENGTH(director) - LENGTH(REPLACE(director, ',', ''))
) t
WHERE director_name = 'Rajiv Chilaka';


-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;


-- 9. Count the number of content items in each genre
SELECT genre, COUNT(*) AS total_content
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1)) AS genre
    FROM netflix
    JOIN (
        SELECT a.N + b.N * 10 + 1 AS n
        FROM (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
        CROSS JOIN 
             (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    ) n
    ON n.n <= 1 + LENGTH(listed_in) - LENGTH(REPLACE(listed_in, ',', ''))
) t
WHERE genre IS NOT NULL AND genre <> ''
GROUP BY genre;


-- 10. Find each year and the average numbers of content release by India on Netflix. 
-- return top 5 years with highest avg content release
SELECT 
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) / (SELECT COUNT(show_id) FROM netflix WHERE country LIKE '%India%') * 100, 2
    ) AS avg_release
FROM netflix
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;


-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%';


-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL OR director = '';


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years
SELECT *
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > YEAR(CURDATE()) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India
SELECT actor, COUNT(*) AS total_movies
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(casts, ',', n.n), ',', -1)) AS actor
    FROM netflix
    JOIN (
        SELECT a.N + b.N * 10 + 1 AS n
        FROM (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
        CROSS JOIN 
             (SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 
              UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
    ) n
    ON n.n <= 1 + LENGTH(casts) - LENGTH(REPLACE(casts, ',', ''))
    WHERE country LIKE '%India%'
) t
WHERE actor IS NOT NULL AND actor <> ''
GROUP BY actor
ORDER BY total_movies DESC
LIMIT 10;


-- 15. Categorize content based on keywords 'kill' or 'violence' in description
SELECT 
    category,
    type,
    COUNT(*) AS content_count
FROM (
    SELECT *,
           CASE 
               WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
               ELSE 'Good'
           END AS category
    FROM netflix
) t
GROUP BY category, type
ORDER BY type;







