-- Introduction to Windows Functions

/*Numbering rows
The simplest application for window functions is numbering rows. Numbering rows allows you to easily fetch the nth row. 
For example, it would be very difficult to get the 35th row in any given table if you didn't have a column with each row's number.*/

-- Number each row in the dataset.

SELECT
  *,
  -- Assign numbers to each row
  ROW_NUMBER() OVER() AS Row_N
FROM Summer_Medals
ORDER BY Row_N ASC;


/*Numbering Olympic games in ascending order
The Summer Olympics dataset contains the results of the games between 1896 and 2012. 
The first Summer Olympics were held in 1896, the second in 1900, and so on. 
What if you want to easily query the table to see in which year the 13th Summer Olympics were held? You'd need to number the rows for that.

Assign a number to each year in which Summer Olympic games were held.*/

SELECT
  Year,

  -- Assign numbers to each year
  ROW_NUMBER() OVER() AS Row_N
FROM (
  SELECT DISTINCT year
  FROM Summer_Medals
  ORDER BY Year ASC
) AS Years
ORDER BY Year ASC;


/*Numbering Olympic games in descending order
You've already numbered the rows in the Summer Medals dataset. 
What if you need to reverse the row numbers so that the most recent Olympic games' rows have a lower number?

Assign a number to each year in which Summer Olympic games were held so that rows with the most recent years have lower row numbers.*/

SELECT
  Year,
  -- Assign the lowest numbers to the most recent years
  ROW_NUMBER() OVER (ORDER BY Year DESC) AS Row_N
FROM (
  SELECT DISTINCT Year
  FROM Summer_Medals
) AS Years
ORDER BY Year;


/*Numbering Olympic athletes by medals earned
Row numbering can also be used for ranking. For example, numbering rows and ordering by the count of medals 
each athlete earned in the OVER clause will assign 1 to the highest-earning medalist, 2 to the second highest-earning medalist, and so on.*/

-- Parte 1: For each athlete, count the number of medals he or she has earned.

SELECT
  -- Count the number of medals each athlete has earned
  athlete,
  COUNT(medal) AS Medals
FROM Summer_Medals
GROUP BY Athlete
ORDER BY Medals DESC;

-- Parte 2: Having wrapped the previous query in the Athlete_Medals CTE, rank each athlete by the number of medals they've earned.

WITH Athlete_Medals AS (
  SELECT
    -- Count the number of medals each athlete has earned
    Athlete,
    COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Athlete)

SELECT
  -- Number each athlete by how many medals they've earned
  athlete,
  ROW_NUMBER() OVER (ORDER BY Medals DESC) AS Row_N
FROM Athlete_Medals
ORDER BY Medals DESC;


/*Reigning weightlifting champions
A reigning champion is a champion who's won both the previous and current years' competitions. 
To determine if a champion is reigning, the previous and current years' results need to be in the same row, in two different columns.*/

-- Parte 1: Return each year's gold medalists in the Men's 69KG weightlifting competition.

SELECT
  -- Return each year's champions' countries
  year,
  country AS champion
FROM Summer_Medals
WHERE
  Discipline = 'Weightlifting' AND
  Event = '69KG' AND
  Gender = 'Men' AND
  Medal = 'Gold';
  
-- Parte 2: Having wrapped the previous query in the Weightlifting_Gold CTE, get the previous year's champion for each year.

WITH Weightlifting_Gold AS (
  SELECT
    -- Return each year's champions' countries
    Year,
    Country AS champion
  FROM Summer_Medals
  WHERE
    Discipline = 'Weightlifting' AND
    Event = '69KG' AND
    Gender = 'Men' AND
    Medal = 'Gold')

SELECT
  Year, Champion,
  -- Fetch the previous year's champion
  LAG(Champion,1) OVER
    (ORDER BY Year ASC) AS Last_Champion
FROM Weightlifting_Gold
ORDER BY Year ASC;


/*Reigning champions by gender
You've already fetched the previous year's champion for one event. However, if you have multiple events, genders, 
or other metrics as columns, you'll need to split your table into partitions to avoid having a champion from one event or 
gender appear as the previous champion of another event or gender.*/

-- Return the previous champions of each year's event by gender.

WITH Tennis_Gold AS (
  SELECT DISTINCT
    Gender, Year, Country
  FROM Summer_Medals
  WHERE
    Year >= 2000 AND
    Event = 'Javelin Throw' AND
    Medal = 'Gold')

SELECT
  Gender, Year,
  Country AS Champion,
  -- Fetch the previous year's champion by gender
  LAG(country) OVER (PARTITION BY gender
            ORDER BY year ASC, gender ASC) AS Last_Champion
FROM Tennis_Gold
ORDER BY Gender ASC, Year ASC;


/*Reigning champions by gender and event
In the previous exercise, you partitioned by gender to ensure that data about one gender doesn't get mixed into data about the other gender. 
If you have multiple columns, however, partitioning by only one of them will still mix the results of the other columns.*/

-- Return the previous champions of each year's events by gender and event.

WITH Athletics_Gold AS (
  SELECT DISTINCT
    Gender, Year, Event, Country
  FROM Summer_Medals
  WHERE
    Year >= 2000 AND
    Discipline = 'Athletics' AND
    Event IN ('100M', '10000M') AND
    Medal = 'Gold')

SELECT
  Gender, Year, Event,
  Country AS Champion,
  -- Fetch the previous year's champion by gender and event
  LAG(country) OVER (PARTITION BY gender, event
            ORDER BY Year ASC) AS Last_Champion
FROM Athletics_Gold
ORDER BY Event ASC, Gender ASC, Year ASC;


/*Running totals of athlete medals
The running total (or cumulative sum) of a column helps you determine what each row's contribution is to the total sum.*/
-- Return the athletes, the number of medals they earned, and the medals running total, ordered by the athletes' names in alphabetical order.

WITH Athlete_Medals AS (
  SELECT
    Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country = 'USA' AND Medal = 'Gold'
    AND Year >= 2000
  GROUP BY Athlete)

SELECT
  -- Calculate the running total of athlete medals
  athlete,
  Medals,
  SUM(Medals) OVER (ORDER BY Athlete ASC) AS Max_Medals
FROM Athlete_Medals
ORDER BY Athlete ASC;


/*Maximum country medals by year
Getting the maximum of a country's earned medals so far helps you determine whether a country has broken its 
medals record by comparing the current year's earned medals and the maximum so far.*/

-- Return the year, country, medals, and the maximum medals earned so far for each country, ordered by year in ascending order.

WITH Country_Medals AS (
  SELECT
    Year, Country, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country IN ('CHN', 'KOR', 'JPN')
    AND Medal = 'Gold' AND Year >= 2000
  GROUP BY Year, Country)

SELECT
  -- Return the max medals earned so far per country
  year,
  country,
  medals,
  MAX(medals) OVER (PARTITION BY Country
                ORDER BY Year ASC) AS Max_Medals
FROM Country_Medals
ORDER BY Country ASC, Year ASC;


/*Minimum country medals by year
So far, you've seen MAX and SUM, aggregate functions normally used with GROUP BY, being used as window functions. 
You can also use the other aggregate functions, like MIN, as window functions.*/

-- Return the year, medals earned, and minimum medals earned so far.

WITH France_Medals AS (
  SELECT
    Year, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country = 'FRA'
    AND Medal = 'Gold' AND Year >= 2000
  GROUP BY Year)

SELECT
  year,
  medals,
  MIN(medals) OVER (ORDER BY year ASC) AS Min_Medals
FROM France_Medals
ORDER BY Year ASC;





