-- Comparing Ourter Joins
--Parte 1
SELECT name AS country, code, region, basic_unit
FROM countries
-- Join to currencies
FULL JOIN currencies 
USING (code)
-- Where region is North America or name is null
WHERE region = 'North America' OR name IS NULL
ORDER BY region;

-- Parte 2
SELECT name AS country, code, region, basic_unit
FROM countries
-- Join to currencies
LEFT JOIN currencies 
USING (code)
WHERE region = 'North America' 
	OR name IS NULL
ORDER BY region;

-- Parte 3
SELECT name AS country, code, region, basic_unit
FROM countries
-- Join to currencies
INNER JOIN currencies 
USING (code)
WHERE region = 'North America' 
	OR name IS NULL
ORDER BY region;

-- Chaining FULL JOINs
*/As you have seen in the previous chapter on INNER JOIN, it is possible to chain joins in SQL, 
such as when looking to connect data from more than two tables.

Suppose you are doing some research on Melanesia and Micronesia, 
and are interested in pulling information about languages and currencies into the data we see for these regions 
in the countries table. Since languages and currencies exist in separate tables, 
this will require two consecutive full joins involving the countries, languages and currencies tables./*

SELECT 
	c1.name AS country, 
    region, 
    l.name AS language,
	basic_unit, 
    frac_unit
FROM countries as c1 
-- Full join with languages (alias as l)
FULL JOIN languages AS l
USING(code)
-- Full join with currencies (alias as c2)
FULL JOIN currencies AS c2
USING(code)
WHERE region LIKE 'M%esia';


/*Histories and languages
Well done getting to know all about CROSS JOIN! As you have learned, 
CROSS JOIN can be incredibly helpful when asking questions that involve looking at all possible combinations or pairings between two sets of data.
Imagine you are a researcher interested in the languages spoken in two countries: Pakistan and India. You are interested in asking:
What are the languages presently spoken in the two countries?
Given the shared history between the two countries, what languages could potentially have been spoken in either country over the course of their history?
In this exercise, we will explore how INNER JOIN and CROSS JOIN can help us answer these two questions, respectively.
Complete the code to perform an INNER JOIN of countries AS c with languages AS l using the code field to obtain the languages currently 
spoken in the two countries.*/
-- Parte 1
SELECT c.name AS country, l.name AS language
-- Inner join countries as c with languages as l on code
FROM countries AS c
INNER JOIN languages AS l 
USING(code)
WHERE c.code IN ('PAK','IND')
	AND l.code in ('PAK','IND');

-- Parte 2
--Change your INNER JOIN to a different kind of join to look at possible combinations of languages that could have been spoken in the two 
--countries given their history. Observe the differences in output for both joins.
SELECT c.name AS country, l.name AS language
FROM countries AS c        
-- Perform a cross join to languages (alias as l)
CROSS JOIN languages AS l 
WHERE c.code in ('PAK','IND')
	AND l.code in ('PAK','IND');
  
--Choosing your join
/*Now that you're fully equipped to use joins, try a challenge problem to test your knowledge!
You will determine the names of the five countries and their respective regions with the lowest life expectancy for the year 2010. 
Use your knowledge about joins, filtering, sorting and limiting to create this list!*/
-- Complete the join of countries AS c with populations as p. Filter on the year 2010. 
-- Sort your results by life expectancy in ascending order. Limit the result to five countries.
SELECT 
	c.name AS country,
    region,
    life_expectancy AS life_exp
FROM countries AS c
-- Join to populations (alias as p) using an appropriate join
LEFT JOIN populations AS p  
ON c.code = p.country_code
-- Filter for only results in the year 2010
WHERE year = 2010
-- Sort by life_exp
ORDER BY life_exp
-- Limit to five records
LIMIT 5;

-- SELF JOIN
*/Comparing a country to itself
Self joins are very useful for comparing data from one part of a table with another part of the same table. 
Suppose you are interested in finding out how much the populations for each country changed from 2010 to 2015. 
You can visualize this change by performing a self join.
In this exercise, you'll work to answer this question by joining the populations table with itself. 
Recall that, with self joins, tables must be aliased. Use this as an opportunity to practice your aliasing!
Since you'll be joining the populations table to itself, you can alias populations first as p1 and again as p2. 
This is good practice whenever you are aliasing tables with the same first letter.*/

--Perform an inner join of populations with itself ON country_code, aliased p1 and p2 respectively.
--Select the country_code from p1 and the size field from both p1 and p2, aliasing p1.size as size2010 and p2.size as size2015 (in that order).
-- Select aliased fields from populations as p1

SELECT p1.country_code, p1.size AS size2010, p2.size AS size2015
FROM populations AS p1
-- Join populations as p1 to itself, alias as p2, on country code
INNER JOIN populations AS p2
ON p1.country_code = p2.country_code

--Since you want to compare records from 2010 and 2015, 
--eliminate unwanted records by extending the WHERE statement to include only records where the p1.year matches p2.year - 5.

SELECT 
	p1.country_code, 
    p1.size AS size2010, 
    p2.size AS size2015
FROM populations AS p1
INNER JOIN populations AS p2
ON p1.country_code = p2.country_code
WHERE p1.year = 2010
-- Filter such that p1.year is always five years before p2.year
    AND p1.year = (p2.year - 5);

