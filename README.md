# Netflix Movies & TV Shows Data Analysis Using MySQL

## 🌟 Overview
This project delivers a complete data analysis of **Netflix Movies & TV Shows** using **pure MySQL**.  
It explores Netflix’s content library through **15 real-world business problems**, each solved with optimized SQL queries.

The analysis covers:
- Content distribution trends  
- Ratings insights  
- Country-wise contributions  
- Genre patterns  
- Actor & director analytics  
- Violence-keyword classification  
- Yearly trends for Indian content  
- And much more!

This project is perfect for enhancing SQL portfolio skills and demonstrating real data analysis capabilities.

---

## 🎯 Objectives

- 🎬 **Compare Movies vs TV Shows**  
  Analyze how Netflix's content is distributed across major content types.

- ⭐ **Identify the most common ratings**  
  Understand audience maturity levels targeted by Netflix.

- 🕒 **Analyze recently added content**  
  Study additions in the last 5 years to track content growth.

- 🎥 **Find the longest movies & 5+ season shows**  
  Extract detailed insights into duration-based content.

- 🌎 **Study geographic content trends**  
  Understand which countries contribute the most to Netflix.

- 🎭 **Explore genres & regional patterns**  
  Break down content based on genre and category.

- 🔪 **Detect violent vs non-violent content (keyword-based)**  
  Categorize content using descriptions containing words like *kill* or *violence*.

- 👤 **Actor & Director analytics**  
  Identify frequently appearing actors and prolific directors, with special focus on India.

---


## Dataset
Source: https://www.kaggle.com/datasets/shivamb/netflix-shows

## Database & Schema (MySQL)
```sql
CREATE DATABASE netflix_project;
USE netflix_project;

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
SELECT * FROM Movie_Table;
```

## Business Problems & MySQL Solutions

### 1. Count Movies vs TV Shows
```sql
SELECT type AS Type, COUNT(*) AS total_content
FROM Movie_Table
GROUP BY type;
```

### 2. Most Common Rating
```sql
SELECT type, rating, max_rated
FROM (
    SELECT type, rating, COUNT(*) AS max_rated,
           RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM movie_table
    GROUP BY 1,2
) AS Table1
WHERE ranking = 1;
```

### 3. Movies Released in 2020
```sql
SELECT * FROM movie_table WHERE type='Movie' AND release_year=2020;
```

### 4. Top 5 Countries by Content
```sql
SELECT RANK() OVER (ORDER BY total_content DESC) AS ranking,
       country, total_content
FROM (
    SELECT country, COUNT(*) AS total_content
    FROM movie_table
    WHERE country IS NOT NULL AND country <> ''
    GROUP BY country
) AS t1
LIMIT 5;
```

### 5. Longest Movie
```sql
SELECT *
FROM movie_table
WHERE type='Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED) DESC
LIMIT 1;
```

### 6. Content Added in Last 5 Years
```sql
SELECT *
FROM movie_table
WHERE date_added >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);
```

### 7. Titles by Rajiv Chilaka
```sql
SELECT * FROM movie_table WHERE director LIKE '%Rajiv Chilaka%';
```

### 8. TV Shows with More Than 5 Seasons
```sql
SELECT *
FROM movie_table
WHERE type='TV Show'
AND CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED) > 5;
```

### 9. Genre Count
```sql
SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1)) AS genre,
       COUNT(*) AS total_content
FROM movie_table
JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3) AS n
WHERE listed_in IS NOT NULL
GROUP BY genre;
```

### 10. India – Top 5 Years by Avg Release %
```sql
SELECT release_year,
       COUNT(*) AS total_release,
       ROUND((COUNT(*) /
       (SELECT COUNT(*) FROM movie_table WHERE country LIKE '%India%')) * 100, 1) AS avg_release
FROM movie_table
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;
```

### 11. Documentaries
```sql
SELECT * FROM movie_table WHERE type='Movie' AND listed_in LIKE '%Documentaries%';
```

### 12. Missing Director
```sql
SELECT * FROM movie_table WHERE director IS NULL OR director='' OR director=' ';
```

### 13. Salman Khan Movies (Last 10 Years)
```sql
SELECT * FROM movie_table
WHERE type='Movie'
AND cast LIKE '%Salman Khan%'
AND release_year >= YEAR(CURDATE()) - 10;
```

### 14. Top 10 Actors in Indian Movies
```sql
SELECT ROW_NUMBER() OVER (ORDER BY total_movies DESC) AS ranking,
       actor, total_movies
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ',', n.n), ',', -1)) AS actor,
           COUNT(*) AS total_movies
    FROM movie_table
    JOIN (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) AS n
    WHERE type='Movie'
      AND country LIKE '%India%'
      AND cast IS NOT NULL
      AND TRIM(cast) <> ''
    GROUP BY actor
) AS t
ORDER BY total_movies DESC
LIMIT 10;
```

### 15. Good vs Bad Content (Violence Keywords)
```sql
SELECT CASE
         WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
         ELSE 'Good'
       END AS content_type,
       COUNT(*) AS total_items
FROM movie_table
GROUP BY content_type;
```

## 🔍 Detailed Findings & Insights

### 🎬 1. Movies dominate Netflix’s catalog  
Netflix hosts **significantly more Movies than TV Shows**, suggesting that its content strategy historically focused on film licensing and movie-based additions. TV Show growth appears steady, but movies remain the platform’s largest content category.

---

### ⭐ 2. TV-MA and TV-14 are the most common ratings  
The ratings analysis reveals that **TV-MA** (mature audiences) and **TV-14** (teen audiences) are the dominant rating categories.  
This means the majority of Netflix content is geared toward **older teens and adults**, aligning with global streaming consumption trends.

---

### 🌎 3. USA contributes the highest amount of content  
The **United States is the top content contributor** on Netflix.  
This reflects:  
- Hollywood’s global dominance  
- Netflix’s strong US catalog licensing  
- A large volume of Netflix Originals produced in the US  

Other key contributors include India, UK, and Canada.

---

### 🇮🇳 4. Indian content shows rapid growth  
The year-wise Indian content analysis shows **a major surge after 2016**, especially during Netflix’s expansion into India.  
This rise aligns with:  
- Netflix Originals in regional languages  
- Local partnerships and production houses  
- Targeted investment in India’s fast-growing streaming market  

---

### ⚠️ 5. Missing director information indicates metadata issues  
A considerable number of titles contain **NULL or empty 'director' fields**.  
This points to:  
- Incomplete metadata within the dataset  
- Potential challenges when performing director-based insights  
- The importance of data cleaning before analysis  

---

### 🎭 6. Drama, Comedy, and International titles dominate genres  
The genre breakdown shows that **Drama** and **Comedy** lead Netflix’s content library, followed closely by **International TV/Movies**.  
This highlights:  
- Strong global storytelling presence  
- Broad audience appeal for emotional & humorous genres  
- Netflix’s push toward global and culturally diverse content  

---

### 🔪 7. Keyword-based text analysis identifies violent content  
Using keywords like **“kill”** and **“violence”**, content was classified into “Good” vs “Bad” categories.  
This simple NLP technique demonstrates:  
- How descriptions can reveal content tone  
- Potential use for parental guidance filters  
- Relevance for content flagging or sensitivity analysis  

---


## Author
**Mohd Faaiz**  
Email: mohdfaaizbly@outlook.com  
LinkedIn: https://www.linkedin.com/in/mohd-faaiz-669730388/
