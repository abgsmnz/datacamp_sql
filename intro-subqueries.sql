-- Semi Join
-- 1 Select country code for countries in the Middle East
SELECT code
FROM countries
WHERE region = 'Middle East';

-- 2 Select unique language names
SELECT DISTINCT name
FROM languages
-- Order by the name of the language
ORDER BY name;

-- 3
SELECT DISTINCT name
FROM languages
-- Add syntax to use bracketed subquery below as a filter
WHERE code IN
    (SELECT code
    FROM countries
    WHERE region = 'Middle East')
ORDER BY name;

-- Anti Join
-- 1 Select code and name of countries from Oceania
SELECT code, name
FROM countries
WHERE continent = 'Oceania';

-- 2
SELECT code, name
FROM countries
WHERE continent = 'Oceania'
-- Filter for countries not included in the bracketed subquery
  AND code NOT IN
    (SELECT code
    FROM currencies);
    
-- Subqueries inside SELECT 
-- 1 Select average life_expectancy from the populations table
SELECT AVG(life_expectancy)
FROM populations
-- Filter for the year 2015
WHERE year = 2015;


*/You can use SQL to do calculations for you. 
Suppose you only want records from 2015 with life_expectancy above 1.15 * avg_life_expectancy.*/
-- 1 Select average life_expectancy from the populations table
SELECT AVG(life_expectancy)
FROM populations
-- Filter for the year 2015
WHERE year = 2015;

-- 2
SELECT *
FROM populations
-- Filter for only those populations where life expectancy is 1.15 times higher than average
WHERE life_expectancy > 1.15 *
  (SELECT AVG(life_expectancy) AS avg_life_expectancy
   FROM populations
   WHERE year = 2015) 
	 AND year = 2015;
   
*/WHERE do people live?
In this exercise, you will strengthen your knowledge of subquerying using WHERE. 
Follow the instructions below to get the urban area population for capital cities only. 
Explore the tables displayed in the console to help identify columns of interest as you build your query.*/
-- Select relevant fields from cities table
SELECT name, country_code, urbanarea_pop
FROM cities
-- Filter using a subquery on the countries table
WHERE name IN
(SELECT capital
FROM countries)
ORDER BY urbanarea_pop DESC;


*/Subquery inside SELECT
As explored in the video, there are often multiple ways to produce the same result in SQL. 
You saw that subqueries can provide an alternative to joins to obtain the same result.
In this exercise, you'll go further in exploring how some queries can be written using either a join or a subquery.
In Step 1, you'll begin with a LEFT JOIN combined with a GROUP BY to obtain summarized information from two tables in order 
to select the nine countries with the most cities appearing in the cities table. 
In Step 2, you'll write a query that returns the same result as the join, but leveraging a nested query instead./*

-- 1 Do it on a LEFT JOIN 
-- Find top nine countries with the most cities
SELECT countries.name AS country, COUNT(cities.name) AS cities_num
FROM countries
LEFT JOIN cities
ON code = country_code
GROUP BY country
-- Order by count of cities as cities_num
ORDER BY cities_num DESC
LIMIT 9;

-- 2 Subquery inside a SELECT = LEFT JOIN in this case
SELECT countries.name AS country,
-- Subquery that provides the count of cities 
  (SELECT COUNT(cities.name) 
  FROM cities
  WHERE countries.code = cities.country_code) AS cities_num
FROM countries
ORDER BY cities_num DESC, country
LIMIT 9;
