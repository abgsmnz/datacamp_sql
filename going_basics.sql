-- Count the unique titles
SELECT COUNT (DISTINCT title) AS nineties_english_films_for_teens
FROM films
-- Filter to release_years to between 1990 and 1999
WHERE release_year BETWEEN 1990 AND 1999
-- Filter to English-language films
	AND language = 'English'
-- Narrow it down to G, PG, and PG-13 certifications
	AND certification IN ('G', 'PG', 'PG-13');


-- Calculate the percentage of people who are no longer alive
SELECT COUNT(deathdate) * 100.0 / COUNT(*) AS percentage_dead
FROM people;

-- Find the number of decades in the films table
SELECT (MAX(release_year) - MIN(release_year)) / 10.0 AS number_of_decades
FROM films;

-- Round duration_hours to two decimal places
SELECT title, ROUND(duration / 60.0, 2) AS duration_hours
FROM films;

-- Select the release year, duration, and title sorted by release year and duration
SELECT release_year, duration, title
FROM films
ORDER BY certification, release_year DESC;

-- Find the release_year, country, and max_budget, then group and order by release_year and country
SELECT release_year, country, MAX(budget) AS max_budget
FROM films
GROUP BY release_year, country
ORDER BY release_year, country;

-- Answering business questions In the real world, every SQL query starts with a business question. Then it is up to you to decide how to write the query that answers the question. Let's try this out.
-- Which release_year had the most language diversity?
-- Take your time to translate this question into code. We'll get you started then it's up to you to test your queries in the console.
-- "Most language diversity" can be interpreted as COUNT(DISTINCT ___). Now over to you.--

SELECT release_year, COUNT(DISTINCT language) AS language_diversity
FROM films
GROUP BY release_year
ORDER BY language_diversity DESC;

-- Select the country and distinct count of certification as certification_count
SELECT country, COUNT(DISTINCT certification) AS certification_count
FROM films
-- Group by country
GROUP BY country
-- Filter results to countries with more than 10 different certifications
HAVING COUNT(DISTINCT certification) > 10;

-- Select the country and average_budget from films
SELECT country, AVG(budget) AS average_budget
FROM films
-- Group by country
GROUP BY country
-- Filter to countries with an average_budget of more than one billion
HAVING AVG(budget) > 1000000000
-- Order by descending order of the aggregated budget
ORDER BY average_budget DESC;

