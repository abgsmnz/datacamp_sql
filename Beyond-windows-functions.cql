/*A basic pivot
You have the following table of Pole Vault gold medalist countries by gender in 2008 and 2012.

| Gender | Year | Country |
|--------|------|---------|
| Men    | 2008 | AUS     |
| Men    | 2012 | FRA     |
| Women  | 2008 | RUS     |
| Women  | 2012 | USA     |
Pivot it by Year to get the following reshaped, cleaner table.

| Gender | 2008 | 2012 |
|--------|------|------|
| Men    | AUS  | FRA  |
| Women  | RUS  | USA  |*/

-- Create the correct extension.
-- Fill in the column names of the pivoted table.

-- Create the correct extention to enable CROSSTAB
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
  SELECT
    Gender, Year, Country
  FROM Summer_Medals
  WHERE
    Year IN (2008, 2012)
    AND Medal = 'Gold'
    AND Event = 'Pole Vault'
  ORDER By Gender ASC, Year ASC;
-- Fill in the correct column names for the pivoted table
$$) AS ct (Gender VARCHAR,
           "2008" VARCHAR,
           "2012" VARCHAR)

ORDER BY Gender ASC;


/*Pivoting with ranking
You want to produce an easy scannable table of the rankings of the three most populous EU countries by how many gold 
medals they've earned in the 2004 through 2012 Olympic games. The table needs to be in this format:

| Country | 2004 | 2008 | 2012 |
|---------|------|------|------|
| FRA     | ...  | ...  | ...  |
| GBR     | ...  | ...  | ...  |
| GER     | ...  | ...  | ...  |
You'll need to count the gold medals each country has earned, produce the ranks of each country by medals earned, 
then pivot the table to this shape.*/

-- Parte 1: Count the gold medals that France (FRA), the UK (GBR), and Germany (GER) have earned per country and year.
-- Count the gold medals per country and year
SELECT
  Country,
  Year,
  COUNT(*) AS Awards
FROM Summer_Medals
WHERE
  Country IN ('FRA', 'GBR', 'GER')
  AND Year IN (2004, 2008, 2012)
  AND Medal = 'Gold'
GROUP BY Country, Year
ORDER BY Country ASC, Year ASC

-- Parte 2: Select the country and year columns, then rank the three countries by how many gold medals they earned per year.
WITH Country_Awards AS (
  SELECT
    Country,
    Year,
    COUNT(*) AS Awards
  FROM Summer_Medals
  WHERE
    Country IN ('FRA', 'GBR', 'GER')
    AND Year IN (2004, 2008, 2012)
    AND Medal = 'Gold'
  GROUP BY Country, Year)

SELECT
  -- Select Country and Year
  Country,
  Year,
  -- Rank by gold medals earned per year
  RANK() OVER (PARTITION BY Year ORDER BY Awards DESC) :: INTEGER AS rank
FROM Country_Awards
ORDER BY Country ASC, Year ASC;

-- Parte 3: Pivot the query's results by Year by filling in the new table's correct column names.
CREATE EXTENSION IF NOT EXISTS tablefunc;

SELECT * FROM CROSSTAB($$
  WITH Country_Awards AS (
    SELECT
      Country,
      Year,
      COUNT(*) AS Awards
    FROM Summer_Medals
    WHERE
      Country IN ('FRA', 'GBR', 'GER')
      AND Year IN (2004, 2008, 2012)
      AND Medal = 'Gold'
    GROUP BY Country, Year)

  SELECT
    Country,
    Year,
    RANK() OVER
      (PARTITION BY Year
       ORDER BY Awards DESC) :: INTEGER AS rank
  FROM Country_Awards
  ORDER BY Country ASC, Year ASC;
-- Fill in the correct column names for the pivoted table
$$) AS ct (Country VARCHAR,
           "2004" INTEGER,
           "2008" INTEGER,
           "2012" INTEGER)

Order by Country ASC;

/* ROLLUP and CUBE
Country-level subtotals
You want to look at three Scandinavian countries' earned gold medals per country and gender in the year 2004. 
You're also interested in Country-level subtotals to get the total medals earned for each country, 
but Gender-level subtotals don't make much sense in this case, so disregard them.*/

-- Count the gold medals awarded per country and gender.
-- Generate Country-level gold award counts.
-- Count the gold medals per country and gender
SELECT
  Country,
  Gender,
  COUNT(*) AS Gold_Awards
FROM Summer_Medals
WHERE
  Year = 2004
  AND Medal = 'Gold'
  AND Country IN ('DEN', 'NOR', 'SWE')
-- Generate Country-level subtotals
GROUP BY Country, ROLLUP(Gender)
ORDER BY Country ASC, Gender ASC;

/*All group-level subtotals
You want to break down all medals awarded to Russia in the 2012 Olympic games per gender and medal type. 
Since the medals all belong to one country, Russia, it makes sense to generate all possible subtotals (Gender- and Medal-level subtotals), 
as well as a grand total.
Generate a breakdown of the medals awarded to Russia per country and medal type, including all group-level subtotals and a grand total.*/

-- Count the medals awarded per gender and medal type.
-- Generate all possible group-level counts (per gender and medal type subtotals and the grand total).
-- Count the medals per gender and medal type
SELECT
  Gender,
  Medal,
  COUNT(*) AS Awards
FROM Summer_Medals
WHERE
  Year = 2012
  AND Country = 'RUS'
-- Get all possible group-level subtotals
GROUP BY CUBE(Gender, Medal)
ORDER BY Gender ASC, Medal ASC;


/*Cleaning up results
Returning to the breakdown of Scandinavian awards you previously made, 
you want to clean up the results by replacing the nulls with meaningful text.*/

-- Turn the nulls in the Country column to All countries, and the nulls in the Gender column to All genders.
SELECT
  -- Replace the nulls in the columns with meaningful text
  COALESCE(Country, 'All countries') AS Country,
  COALESCE(Gender, 'All genders') AS Gender,
  COUNT(*) AS Awards
FROM Summer_Medals
WHERE
  Year = 2004
  AND Medal = 'Gold'
  AND Country IN ('DEN', 'NOR', 'SWE')
GROUP BY ROLLUP(Country, Gender)
ORDER BY Country ASC, Gender ASC;



/*Summarizing results
After ranking each country in the 2000 Olympics by gold medals awarded, you want to return the top 3 countries in one row, 
as a comma-separated string. In other words, turn this:

| Country | Rank |
|---------|------|
| USA     | 1    |
| RUS     | 2    |
| AUS     | 3    |
| ...     | ...  |
into this:

USA, RUS, AUS*/

-- Parte 1: Rank countries by the medals they've been awarded.
WITH Country_Medals AS (
  SELECT
    Country,
    COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE Year = 2000
    AND Medal = 'Gold'
  GROUP BY Country)

  SELECT
    Country,
    -- Rank countries by the medals awarded
    RANK() OVER(ORDER BY Medals DESC) AS Rank
  FROM Country_Medals
  ORDER BY Rank ASC;
  
  -- Parte 2: Return the top 3 countries by medals awarded as one comma-separated string.
  WITH Country_Medals AS (
  SELECT
    Country,
    COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE Year = 2000
    AND Medal = 'Gold'
  GROUP BY Country),

  Country_Ranks AS (
  SELECT
    Country,
    RANK() OVER (ORDER BY Medals DESC) AS Rank
  FROM Country_Medals
  ORDER BY Rank ASC)

-- Compress the countries column
SELECT STRING_AGG(Country, ', ')
FROM Country_Ranks
-- Select only the top three ranks
WHERE Rank <= 3;



/*Accessing data in an ARRAY
In our DVD Rentals database, the film table contains an ARRAY for special_features which has a type of TEXT[]. 
Much like any ARRAY data type in PostgreSQL, a TEXT[] array can store an array of TEXT values. 
This comes in handy when you want to store things like phone numbers or email addresses as we saw in the lesson.
Let's take a look at the special_features column and also practice accessing data in the ARRAY.*/

-- Parte 1: Select the title and special features from the film table and compare the results between the two columns.
-- Select the title and special features column 
SELECT 
  title, 
  special_features 
FROM film;

-- Parte 2: Select all films that have a special feature Trailers by filtering on the first index of the special_features ARRAY.
- Select the title and special features column 
SELECT 
  title, 
  special_features 
FROM film
-- Use the array index of the special_features column
WHERE special_features[1] = 'Trailers';

-- Parte 3: Now let's select all films that have Deleted Scenes in the second index of the special_features ARRAY.
-- Select the title and special features column 
SELECT 
  title, 
  special_features 
FROM film
-- Use the array index of the special_features column
WHERE special_features[2] = 'Deleted Scenes';


/*Searching an ARRAY with ANY
As we saw in the video, PostgreSQL also provides the ability to filter results by searching for values in an ARRAY. 
The ANY function allows you to search for a value in any index position of an ARRAY. Here's an example.

WHERE 'search text' = ANY(array_name)
When using the ANY function, the value you are filtering on appears on the left side of the equation with the name of the 
ARRAY column as the parameter in the ANY function.*/

-- Match 'Trailers' in any index of the special_features ARRAY regardless of position.
SELECT
  title, 
  special_features 
FROM film 
-- Modify the query to use the ANY function 
WHERE 'Trailers' = ANY (special_features);



/*Searching an ARRAY with @>
The contains operator @> operator is alternative syntax to the ANY function and matches data in an ARRAY using the following syntax.

WHERE array_name @> ARRAY['search text'] :: type[]
So let's practice using this operator in the exercise.*/

-- Use the contains operator to match the text Deleted Scenes in the special_features column.
SELECT 
  title, 
  special_features 
FROM film 
-- Filter where special_features contains 'Deleted Scenes'
WHERE special_features @> ARRAY['Deleted Scenes'];












