/*Future gold medalists
Fetching functions allow you to get values from different parts of the table into one row. 
If you have time-ordered data, you can "peek into the future" with the LEAD fetching function. 
This is especially useful if you want to compare a current value to a future value.*/

-- For each year, fetch the current gold medalist and the gold medalist 3 competitions ahead of the current row.

WITH Discus_Medalists AS (
  SELECT DISTINCT
    Year,
    Athlete
  FROM Summer_Medals
  WHERE Medal = 'Gold'
    AND Event = 'Discus Throw'
    AND Gender = 'Women'
    AND Year >= 2000)

SELECT
  -- For each year, fetch the current and future medalists
  Year,
  Athlete,
  LEAD(Athlete,3) OVER (ORDER BY Year ASC) AS Future_Champion
FROM Discus_Medalists
ORDER BY Year ASC;


/*First athlete by name
It's often useful to get the first or last value in a dataset to compare all other values to it. 
With absolute fetching functions like FIRST_VALUE, you can fetch a value at an absolute position in the table, like its beginning or end.*/

-- Return all athletes and the first athlete ordered by alphabetical order.

WITH All_Male_Medalists AS (
  SELECT DISTINCT
    Athlete
  FROM Summer_Medals
  WHERE Medal = 'Gold'
    AND Gender = 'Men')

SELECT
  -- Fetch all athletes and the first athlete alphabetically
  Athlete,
  FIRST_VALUE(athlete) OVER (
    ORDER BY athlete ASC
  ) AS First_Athlete
FROM All_Male_Medalists;

/*Last country by name
Just like you can get the first row's value in a dataset, you can get the last row's value. 
This is often useful when you want to compare the most recent value to previous values.*/

-- Return the year and the city in which each Olympic games were held.
-- Fetch the last city in which the Olympic games were held.

WITH Hosts AS (
  SELECT DISTINCT Year, City
    FROM Summer_Medals)

SELECT
  Year,
  City,
  -- Get the last city in which the Olympic games were held
  LAST_VALUE(city) OVER (
   ORDER BY year ASC
   RANGE BETWEEN
     UNBOUNDED PRECEDING AND
     UNBOUNDED FOLLOWING
  ) AS Last_City
FROM Hosts
ORDER BY Year ASC;

/*Ranking athletes by medals earned
In chapter 1, you used ROW_NUMBER to rank athletes by awarded medals. 
However, ROW_NUMBER assigns different numbers to athletes with the same count of awarded medals, so it's not a useful ranking function; 
if two athletes earned the same number of medals, they should have the same rank.*/

-- Rank each athlete by the number of medals they've earned -- the higher the count, the higher the rank -- 
-- with identical numbers in case of identical values.

WITH Athlete_Medals AS (
  SELECT
    Athlete,
    COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Athlete)

SELECT
  Athlete,
  Medals,
  -- Rank athletes by the medals they've won
  RANK() OVER (ORDER BY Medals DESC) AS Rank_N
FROM Athlete_Medals
ORDER BY Medals DESC;


/*Ranking athletes from multiple countries
In the previous exercise, you used RANK to assign rankings to one group of athletes. 
In real-world data, however, you'll often find numerous groups within your data. 
Without partitioning your data, one group's values will influence the rankings of the others.
Also, while RANK skips numbers in case of identical values, the most natural way to assign rankings is not to skip numbers. 
If two countries are tied for second place, the country after them is considered to be third by most people.*/

-- Rank each country's athletes by the count of medals they've earned -- the higher the count, the higher the rank -- 
-- without skipping numbers in case of identical values.

WITH Athlete_Medals AS (
  SELECT
    Country, Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  WHERE
    Country IN ('JPN', 'KOR')
    AND Year >= 2000
  GROUP BY Country, Athlete
  HAVING COUNT(*) > 1)

SELECT
  Country,
  -- Rank athletes in each country by the medals they've won
  Athlete,
  DENSE_RANK() OVER (PARTITION BY Country
                ORDER BY Medals DESC) AS Rank_N
FROM Athlete_Medals
ORDER BY Country ASC, RANK_N ASC;


/*Paging events
There are exactly 666 unique events in the Summer Medals Olympics dataset. 
If you want to chunk them up to analyze them piece by piece, you'll need to split the events into groups of approximately equal size.*/

-- Split the distinct events into exactly 111 groups, ordered by event in alphabetical order.

WITH Events AS (
  SELECT DISTINCT Event
  FROM Summer_Medals)
  
SELECT
  --- Split up the distinct events into 111 unique groups
  Event,
  NTILE(111) OVER (ORDER BY Event ASC) AS Page
FROM Events
ORDER BY Event ASC;


/*Top, middle, and bottom thirds
Splitting your data into thirds or quartiles is often useful to understand how the values in your dataset are spread. 
Getting summary statistics (averages, sums, standard deviations, etc.) of the top, middle, and bottom thirds 
can help you determine what distribution your values follow.*/

-- Parte 1: Split the athletes into top, middle, and bottom thirds based on their count of medals.

WITH Athlete_Medals AS (
  SELECT Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Athlete
  HAVING COUNT(*) > 1)
  
SELECT
  Athlete,
  Medals,
  -- Split athletes into thirds by their earned medals
  NTILE(3) OVER (ORDER BY Medals DESC) AS Third
FROM Athlete_Medals
ORDER BY Medals DESC, Athlete ASC;

-- Parte2: Return the average of each third.

WITH Athlete_Medals AS (
  SELECT Athlete, COUNT(*) AS Medals
  FROM Summer_Medals
  GROUP BY Athlete
  HAVING COUNT(*) > 1),
  
  Thirds AS (
  SELECT
    Athlete,
    Medals,
    NTILE(3) OVER (ORDER BY Medals DESC) AS Third
  FROM Athlete_Medals)
  
SELECT
  -- Get the average medals earned in each third
  Third,
  AVG(Medals) AS Avg_Medals
FROM Thirds
GROUP BY Third
ORDER BY Third ASC;




