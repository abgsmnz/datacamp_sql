-- Select average life_expectancy
SELECT AVG(life_expectancy)
  -- From populations
  FROM populations
-- Where year is 2015
WHERE year = 2015

--second part--

-- Select fields
SELECT *
  -- From populations
  FROM populations
-- Where life_expectancy is greater than
WHERE life_expectancy > 
  -- 1.15 * subquery
  1.15 * (SELECT AVG(life_expectancy)
   FROM populations
  WHERE year = 2015)
  AND year = 2015 ;

-- Excersise 2--
-- Select fields
SELECT name, country_code, urbanarea_pop
  -- From cities
  FROM cities
-- Where city name in the field of capital cities
WHERE name IN
  -- Subquery
  (SELECT capital
   FROM countries)
ORDER BY urbanarea_pop DESC;

-Transforming codes-
/* 
SELECT countries.name AS country, COUNT(*) AS cities_num
  FROM cities
    INNER JOIN countries
    ON countries.code = cities.country_code
GROUP BY country
ORDER BY cities_num DESC, country
LIMIT 9;
*/
 
SELECT name AS country,
  (SELECT COUNT(cities)
   FROM cities
   WHERE countries.code = cities.country_code) AS cities_num
FROM countries
ORDER BY cities_num DESC, country
LIMIT 9;

--same same, different different

/*
SELECT countries.name AS country, COUNT(*) AS cities_num
  FROM cities
    INNER JOIN countries
    ON countries.code = cities.country_code
GROUP BY country
ORDER BY cities_num DESC, country
LIMIT 9;
*/

SELECT name AS country,
  -- Subquery
  (SELECT COUNT(name)
   FROM cities
   WHERE countries.code = cities.country_code) AS cities_num
FROM countries
ORDER BY cities_num DESC, country
LIMIT 9;

-- Subquery inside from --

-- Select fields
SELECT local_name, subquery.lang_num
  -- From countries
  FROM countries,
  	-- Subquery (alias as subquery)
  	(SELECT code, COUNT(*) AS lang_num
  	 FROM languages
  	 GROUP BY code) AS subquery
  -- Where codes match
  WHERE countries.code = subquery.code
-- Order by descending number of languages
ORDER BY lang_num DESC;

-- Advanced subquery step by step --
--Step 1: with Inner Join--

-- Select fields
SELECT name, continent, inflation_rate
  -- From countries
  FROM countries
  	-- Join to economies
  	INNER JOIN economies
    -- Match on code
    USING (code)
-- Where year is 2015
WHERE year = 2015;

--Step 2: selecting max inflation rate--
-- Select the maximum inflation rate as max_inf
SELECT MAX (inflation_rate) AS max_inf
  -- Subquery using FROM (alias as subquery)
  FROM (
      SELECT name, continent, inflation_rate
      FROM countries
      INNER JOIN economies
      USING (code)
      WHERE year = 2015) AS subquery
-- Group by continent
GROUP BY continent;

--Step 3: Advanced advanced!
-- Select fields
SELECT name, continent, inflation_rate
  -- From countries
  FROM countries
	-- Join to economies
	INNER JOIN economies
	-- Match on code
	ON countries.code = economies.code
  -- Where year is 2015
  WHERE year = 2015
    -- And inflation rate in subquery (alias as subquery)
    AND economies.inflation_rate IN (
        SELECT MAX(inflation_rate) AS max_inf
        FROM (
             SELECT name, continent, inflation_rate
             FROM countries
             INNER JOIN economies
             ON countries.code = economies.code
             WHERE year = 2015) AS subquery
      -- Group by continent
        GROUP BY continent);
        
        -- Subquery Challenge --
  SELECT code, inflation_rate, unemployment_rate
FROM economies
WHERE year = 2015 AND economies.code NOT IN ( 
  SELECT code 
  FROM countries
  WHERE (
    gov_form = 'Constitutional Monarchy' OR 
    gov_form LIKE '%Republic%'
  )
)
ORDER BY inflation_rate;
