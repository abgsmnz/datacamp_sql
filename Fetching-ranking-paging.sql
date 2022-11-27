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




