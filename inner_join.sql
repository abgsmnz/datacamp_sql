-- Select name fields (with alias) and region 
SELECT cities.name AS city, countries.name AS country, countries.region
FROM cities
INNER JOIN countries
ON cities.country_code = countries.code;

-- Select fields with aliases
SELECT c.code AS country_code, name, year, inflation_rate
FROM countries AS c
-- Join to economies (alias e)
INNER JOIN economies AS e
-- Match on code field using table aliases
ON c.code = e.code

--Notice that only the code field is ambiguous, so it requires a table name or alias before it. 
-- All the other fields (name, year, and inflation_rate) do not occur in more than one table name, 
-- so do not require table names or aliasing in the SELECT statement. 
-- Using table aliases takes some getting used to, but it will save you a lot of typing, especially when your query involves joining tables!

SELECT c.name AS country, l.name AS language, official
FROM countries AS c
INNER JOIN languages AS l
-- Match using the code column
USING (code);

