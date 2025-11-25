create database netflix_project;
use netflix_project;

-- creating table
CREATE TABLE Movie_Table (
    show_id VARCHAR(20),
    type VARCHAR(20),
    title VARCHAR(300),
    director VARCHAR(500),
    cast TEXT,
    country VARCHAR(300),
    date_added DATE,
    release_year INT,
    rating VARCHAR(20),
    duration VARCHAR(50),
    listed_in VARCHAR(300),
    description TEXT
);

SELECT COUNT(*) FROM Movie_Table;
SELECT * from Movie_Table;

# ---------------- 15 BUISNESS PROBLEMS & SOLUTIONS ----------------

-- 1. Count the Number of Movies vs TV Shows.
SELECT 
    type as Type, COUNT(*) AS total_content
FROM
    Movie_Table
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
select
type,
rating,
max_rated
from
(select 
	type,
    rating,
    count(*) as max_rated,
    rank() over(partition by type order by count(*) desc) as ranking
from movie_table
group by 1,2 ) as Table1
where ranking = 1;
    

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT 
    *
FROM
    movie_table
WHERE
    type = 'Movie' AND release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix
SELECT 
    RANK() OVER (ORDER BY total_content DESC) AS ranking,
    country,
    total_content
FROM (
    SELECT
        country,
        COUNT(*) AS total_content
    FROM movie_table
    WHERE country IS NOT NULL 
      AND country <> ''
    GROUP BY country
) AS t1
ORDER BY total_content DESC
LIMIT 5;



-- 5. Identify the longest movie
SELECT 
    *
FROM
    movie_table
WHERE
    type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;

-- 6. Find content added in the last 5 years
SELECT 
    *
FROM
    movie_table
WHERE
    date_added >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT 
    *
FROM
    movie_table
WHERE
    director LIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons
SELECT 
    *
FROM
    movie_table
WHERE
    type = 'TV Show'
        AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;


-- 9. Count the number of content items in each genre
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n),',',- 1)) AS genre,
    COUNT(*) AS total_content
FROM
    movie_table
        JOIN
    (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) AS n
WHERE
    listed_in IS NOT NULL
GROUP BY genre;


-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
SELECT 
    release_year,
    COUNT(*) AS total_release,
    round((COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            movie_table
        WHERE
            country LIKE '%India%') * 100),1) AS avg_release
FROM
    movie_table
WHERE
    country LIKE '%India%'
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;


-- 11. List all movies that are documentaries
SELECT 
    *
FROM
    movie_table
WHERE
    type = 'Movie'
        AND listed_in LIKE '%Documentaries%';

-- 12. Find all content without a director
SELECT 
    *
FROM
    movie_table
WHERE
		director IS NULL 
		OR director = ''
        OR director = ' ';


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT 
    *
FROM
    movie_table
WHERE
    type = 'Movie'
        AND cast LIKE '%Salman Khan%'
        AND release_year >= YEAR(CURDATE()) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
    ROW_NUMBER() OVER (ORDER BY total_movies DESC) AS ranking,
    actor,
    total_movies
FROM (
    SELECT 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n.n), ',', -1)) AS actor,
        COUNT(*) AS total_movies
    FROM movie_table
    JOIN (
        SELECT 1 AS n UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5
    ) AS n
    WHERE type = 'Movie'
      AND country LIKE '%India%'
      AND cast IS NOT NULL
      AND TRIM(cast) <> ''
    GROUP BY actor
) AS t
ORDER BY total_movies DESC
LIMIT 10;

-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.
SELECT 
    CASE
        WHEN
            description LIKE '%kill%'
			OR description LIKE '%violence%'
        THEN
            'Bad'
        ELSE 'Good'
    END AS content_type,
    COUNT(*) AS total_items
FROM
    movie_table
GROUP BY content_type;

-- End of reports
