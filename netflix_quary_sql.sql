--NETFLIX_PROJECT--

create table netflix
(
    show_id varchar(10),
    type varchar(10),
    title varchar(200),
    director varchar(300),
    casts varchar(1000),
    country varchar(200),
    date_added varchar(50),
    release_year int,
    rating varchar(10),
    duration varchar(20),
    listed_in varchar(100),
    description varchar(300)
);

select * from netflix;

select 
    count(*) as Total_Content
from netflix;

-- 20 BUSINESS PROBLEMS

--Content Analysis

1. How many Movies vs TV Shows are available on Netflix?

SELECT
    type,
    COUNT(*) as Total_Content
FROM netflix
GROUP BY type;


2. Find the most common rating for movies and TV shows.

SELECT 
    type,
	rating,
	rating_count
FROM (
    SELECT
        type, 
        rating, 
        COUNT(*) AS rating_count,
        RANK() over (PARTITION BY type ORDER BY COUNT(*) DESC) AS rank
    FROM netflix
    GROUP BY type, rating
) t
WHERE rank = 1;


3. List all movies released in a specific year
--Filter - movie,2020

SELECT 
    title AS movies,
	release_year
FROM netflix
WHERE 
   type = 'Movie'
   AND
   release_year = 2020;


4. Find the top 5 countries with the most content on Netflix.

SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS Countries,
	COUNT(show_id) as Total_Content
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY COUNT(show_id) DESC
LIMIT 5;


5. Identity the longest movie?
 
SELECT
    title AS movies,
	duration
FROM netflix
WHERE
    type = 'Movie'
	AND
	duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::int DESC
LIMIT 1;

   
6. Find content added in the last 5 years?

SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


7. Find all the movies/TV shows by director 'Rajiv Chilaka'.

SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';


8. List all TV shows with more than 5 seasons.

SELECT 
	title AS tv_shows,
	duration
FROM netflix
WHERE
    type = 'TV Show'
    AND duration is not null
    AND split_part(duration, ' ', 1)::int > 5;
   

9. Count the number of content items in each genre.

SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY 1;


10. Find each year and the average numbers of content release in india on netflix.
return top 5 year with highest avg content release!

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;


11. List all movies that are documentaries

SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';


12. Find all content without a director.

SELECT * 
FROM netflix
WHERE director IS NULL;


13. Find how many movies actor "Salman Khan" appeared in last 10 years.

SELECT
    title AS movies,
	casts,
	release_year
FROM netflix
WHERE 
    casts ILIKE '%Salman Khan%' 
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 
    TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) AS actor,
    COUNT(*) AS total_content
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY total_content DESC
LIMIT 10;


15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT 
    category,
    COUNT(*) AS tatal_content
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad_Content'
            ELSE 'Good_Content'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
