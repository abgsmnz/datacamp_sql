-- Select all fields from economies2015
SELECT *
FROM economies2015    
-- Set operation
UNION
-- Select all fields from economies2019
SELECT *
FROM economies2019
ORDER BY code, year;

-- Query that determines all pairs of code and year from economies and populations, without duplicates
SELECT code, year
FROM economies
UNION
SELECT country_code AS code, year
FROM populations
ORDER BY code, year;

SELECT code, year
FROM economies
-- Set theory clause
UNION ALL
SELECT country_code, year
FROM populations
ORDER BY code, year;

-- INTERSECT
-- Return all cities with the same name as a country
SELECT name
FROM cities
INTERSECT
SELECT name
FROM countries;

-- EXCEPT
-- Return all cities that do not have the same name as a country
SELECT name
FROM cities
EXCEPT
SELECT name
FROM countries
ORDER BY name;

*/EXCEPTional! Note that if countries had been on the left and cities on the right, 
you would have returned the opposite: all countries that do not have the same name as a city./*
