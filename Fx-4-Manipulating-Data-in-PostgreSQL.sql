/*Adding and subtracting date and time values
In this exercise, you will calculate the actual number of days rented as well as the true expected_return_date 
by using the rental_duration column from the film table along with the familiar rental_date from the rental table.

This will require that you dust off the skills you learned from prior courses on how to join two or more tables together. 
To select columns from both the film and rental tables in a single query, we'll need to use the inventory table to join 
these two tables together since there is no explicit relationship between them. Let's give it a try!*/

-- Parte 1: Subtract the rental_date from the return_date to calculate the number of days_rented.
SELECT f.title, f.rental_duration,
    -- Calculate the number of days rented
    r.return_date - r.rental_date AS days_rented
FROM film AS f
     INNER JOIN inventory AS i ON f.film_id = i.film_id
     INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

-- Parte 2: Now use the AGE() function to calculate the days_rented
SELECT f.title, f.rental_duration,
    -- Calculate the number of days rented
	AGE(return_date, rental_date) AS days_rented
FROM film AS f
	INNER JOIN inventory AS i ON f.film_id = i.film_id
	INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;


/*INTERVAL arithmetic
If you were running a real DVD Rental store, there would be times when you would need to determine what film titles were currently 
out for rental with customers. In the previous exercise, we saw that some of the records in the results had a NULL value for the return_date. 
This is because the rental was still outstanding.
Each rental in the film table has an associated rental_duration column which represents the number of days that a DVD can be rented by a customer 
before it is considered late. In this example, you will exclude films that have a NULL value for the return_date and also convert 
the rental_duration to an INTERVAL type. Here's a reminder of one method for performing this conversion.

SELECT INTERVAL '1' day * timestamp '2019-04-10 12:34:56'*/

-- Convert rental_duration by multiplying it with a 1 day INTERVAL
-- Subtract the rental_date from the return_date to calculate the number of days_rented.
-- Exclude rentals with a NULL value for return_date.
SELECT
	f.title,
 	-- Convert the rental_duration to an interval
    INTERVAL '1' day * f.rental_duration,
 	-- Calculate the days rented as we did previously
    r.return_date - r.rental_date AS days_rented
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
-- Filter the query to exclude outstanding rentals
WHERE r.return_date IS NOT NULL
ORDER BY f.title;


/*Calculating the expected return date
So now that you've practiced how to add and subtract timestamps and perform relative calculations using intervals, 
let's use those new skills to calculate the actual expected return date of a specific rental. 
As you've seen in previous exercises, the rental_duration is the number of days allowed for a rental before it's considered late. 
To calculate the expected_return_date you will want to use the rental_duration and add it to the rental_date.*/

-- Convert rental_duration by multiplying it with a 1-day INTERVAL.
-- Add it to the rental date.
SELECT
    f.title,
	r.rental_date,
    f.rental_duration,
    -- Add the rental duration to the rental date
    INTERVAL '1' day * f.rental_duration + r.rental_date AS expected_return_date,
    r.return_date
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;


/*Working with the current date and time
Because the Sakila database is a bit dated and most of the date and time values are from 2005 or 2006, 
you are going to practice using the current date and time in our queries without using Sakila. 
You'll get back into working with this database in the next video and throughout the remainder of the course. 
For now, let's practice the techniques you learned about so far in this chapter to work with the current date and time.

As you learned in the video, NOW() and CURRENT_TIMESTAMP can be used interchangeably.*/

-- PARTE 1: Use NOW() to select the current timestamp with timezone.
-- Select the current timestamp
SELECT NOW();

-- PARTE 2: Select the current date without any time value.
-- Select the current date
SELECT CURRENT_DATE;

-- PARTE 3: Now, let's use the CAST() function to eliminate the timezone from the current timestamp.
--Select the current timestamp without a timezone
SELECT CAST( NOW() AS timestamp )

-- PARTE 4: Finally, let's select the current date.
-- Use CAST() to retrieve the same result from the NOW() function.
SELECT 
	-- Select the current date
	CURRENT_DATE,
    -- CAST the result of the NOW() function to a date
    CAST( NOW() AS date )
    

/*Manipulating the current date and time
Most of the time when you work with the current date and time, you will want to transform, manipulate, or perform operations 
on the value in your queries. In this exercise, you will practice adding an INTERVAL to the current timestamp as well as perform 
some more advanced calculations.

Let's practice retrieving the current timestamp. For this exercise, 
please use CURRENT_TIMESTAMP instead of the NOW() function and if you need to convert a date or time value to a timestamp data type, 
please use the PostgreSQL specific casting rather than the CAST() function.*/

-- PARTE 1: Select the current timestamp without timezone and alias it as right_now.
--Select the current timestamp without timezone
SELECT CURRENT_TIMESTAMP::timestamp AS right_now;

-- Parte 2: Now select a timestamp five days from now and alias it as five_days_from_now.
SELECT
	CURRENT_TIMESTAMP::timestamp AS right_now,
    INTERVAL '5 days' + CURRENT_TIMESTAMP AS five_days_from_now;
    
-- Parte 3: Finally, let's use a second-level precision with no fractional digits for both the right_now and five_days_from_now fields.
SELECT
	CURRENT_TIMESTAMP(0)::timestamp AS right_now,
    interval '5 days' + CURRENT_TIMESTAMP(0) AS five_days_from_now;


/*Using EXTRACT
You can use EXTRACT() and DATE_PART() to easily create new fields in your queries by extracting sub-fields from a source timestamp field.

Now suppose you want to produce a predictive model that will help forecast DVD rental activity by day of the week. 
You could use the EXTRACT() function with the dow field identifier in our query to create a new field called dayofweek 
as a sub-field of the rental_date column from the rental table.

You can COUNT() the number of records in the rental table for a given date range and aggregate by the newly created dayofweek column.*/

-- Parte 1: Get the day of the week from the rental_date column.
SELECT 
  -- Extract day of week from rental_date
  EXTRACT(dow FROM rental_date) AS dayofweek 
FROM rental 
LIMIT 100;

-- Parte 2: Count the total number of rentals by day of the week.
-- Extract day of week from rental_date
SELECT 
  EXTRACT(dow FROM rental_date) AS dayofweek, 
  -- Count the number of rentals
  COUNT(rental_date) as rentals 
FROM rental 
GROUP BY 1;



/*Using DATE_TRUNC
The DATE_TRUNC() function will truncate timestamp or interval data types to return a timestamp or interval at a specified precision. 
The precision values are a subset of the field identifiers that can be used with the EXTRACT() and DATE_PART() functions. 
DATE_TRUNC() will return an interval or timestamp rather than a number. For example

SELECT DATE_TRUNC('month', TIMESTAMP '2005-05-21 15:30:30');
Result: 2005-05-01 00;00:00

Now, let's experiment with different precisions and ultimately modify the queries from the previous exercises to aggregate rental activity.*/

-- Parte 1: Truncate the rental_date field by year.
-- Truncate rental_date by year
SELECT DATE_TRUNC('year', rental_date) AS rental_year
FROM rental;

-- Parte 2: Now modify the previous query to truncate the rental_date by month.
-- Truncate rental_date by month
SELECT DATE_TRUNC('month', rental_date) AS rental_month
FROM rental;

-- Parte 3: Let's see what happens when we truncate by day of the month.
-- Truncate rental_date by day of the month 
SELECT DATE_TRUNC('day', rental_date) AS rental_day 
FROM rental;

-- Parte 4: Finally, count the total number of rentals by rental_day and alias it as rentals.
SELECT 
  DATE_TRUNC('day', rental_date) AS rental_day,
  -- Count total number of rentals 
  COUNT(rental_date) AS rentals 
FROM rental
GROUP BY 1;


/*Putting it all together
Many of the techniques you've learned in this course will be useful when building queries to extract data for model training. 
Now let's use some date/time functions to extract and manipulate some DVD rentals data from our fictional DVD rental store.

In this exercise, you are going to extract a list of customers and their rental history over 90 days. 
You will be using the EXTRACT(), DATE_TRUNC(), and AGE() functions that you learned about during this chapter along with 
some general SQL skills from the prerequisites to extract a data set that could be used to determine what day of the week 
customers are most likely to rent a DVD and the likelihood that they will return the DVD late.*/

-- Parte 1: Extract the day of the week from the rental_date column using the alias dayofweek.
-- Use an INTERVAL in the WHERE clause to select records for the 90 day period starting on 5/1/2005.
SELECT
  -- Extract the day of week date part from the rental_date
  EXTRACT('day' FROM rental_date) AS dayofweek,
  AGE(return_date, rental_date) AS rental_days
FROM rental AS r 
WHERE 
  -- Use an INTERVAL for the upper bound of the rental_date 
  rental_date BETWEEN CAST('2005-05-01' AS timestamp)
   AND CAST('2005-05-01' AS timestamp) + INTERVAL '90 day';
   
-- Parte 2: Finally, use a CASE statement and DATE_TRUNC() to create a new column called past_due which will be TRUE 
-- if the rental_days is greater than the rental_duration otherwise, it will be FALSE.
SELECT 
  c.first_name || ' ' || c.last_name AS customer_name,
  f.title,
  r.rental_date,
  -- Extract the day of week date part from the rental_date
  EXTRACT(dow FROM r.rental_date) AS dayofweek,
  AGE(r.return_date, r.rental_date) AS rental_days,
  -- Use DATE_TRUNC to get days from the AGE function
  CASE WHEN DATE_TRUNC('day', AGE(r.return_date, r.rental_date)) > 
  -- Calculate number of d
    f.rental_duration * INTERVAL '1' day 
  THEN TRUE 
  ELSE FALSE END AS past_due 
FROM 
  film AS f 
  INNER JOIN inventory AS i 
  	ON f.film_id = i.film_id 
  INNER JOIN rental AS r 
  	ON i.inventory_id = r.inventory_id 
  INNER JOIN customer AS c 
  	ON c.customer_id = r.customer_id 
WHERE 
  -- Use an INTERVAL for the upper bound of the rental_date 
  r.rental_date BETWEEN CAST('2005-05-01' AS DATE) 
  AND CAST('2005-05-01' AS DATE) + INTERVAL '90 day';
  
  

/*Concatenating strings
In this exercise and the ones that follow, we are going to derive new fields from columns within the customer and film tables of the DVD rental database.

We'll start with the customer table and create a query to return the customers name and email address formatted such 
that we could use it as a "To" field in an email script or program. This format will look like the following:
Brian Piccolo <bpiccolo@datacamp.com>
In the first step of the exercise, use the || operator to do the string concatenation and in the second step, use the CONCAT() functions.*/

-- Parte 1: Concatenate the first_name and last_name columns separated by a single space followed by email surrounded by < and >.
-- Concatenate the first_name and last_name and email 
SELECT first_name || ' ' || last_name || ' <' || email || '>' AS full_email 
FROM customer;

-- Parte 2: Now use the CONCAT() function to do the same operation as the previous step.
-- Concatenate the first_name and last_name and email
SELECT CONCAT(first_name, ' ', last_name,  ' <', email, '>') AS full_email 
FROM customer;


/*Changing the case of string data
Now you are going to use the film and category tables to create a new field called 
film_category by concatenating the category name with the film's title. 
You will also format the result using functions you learned about in the video to transform the case of the fields you are selecting in the query; 
for example, the INITCAP() function which converts a string to title case.*/

-- Convert the film category name to uppercase.
-- Convert the first letter of each word in the film's title to upper case.
-- Concatenate the converted category name and film title separated by a colon.
-- Convert the description column to lowercase.
SELECT 
  -- Concatenate the category name to coverted to uppercase
  -- to the film title converted to title case
  UPPER(c.name)  || ': ' || INITCAP(title) AS film_category, 
  -- Convert the description column to lowercase
  LOWER(description) AS description
FROM 
  film AS f 
  INNER JOIN film_category AS fc 
  	ON f.film_id = fc.film_id 
  INNER JOIN category AS c 
  	ON fc.category_id = c.category_id;
    

/*Replacing string data
Sometimes you will need to make sure that the data you are extracting does not contain any whitespace. 
There are many different approaches you can take to cleanse and prepare your data for these situations. 
A common technique is to replace any whitespace with an underscore.

In this example, we are going to practice finding and replacing whitespace characters in the title column 
of the film table using the REPLACE() function.*/

-- Replace all whitespace with an underscore.
SELECT 
  -- Replace whitespace in the film title with an underscore
  REPLACE(title, ' ', '_') AS title
FROM film; 



/*Determining the length of strings
Determining the number of characters in a string is something that you will use frequently when working with data in a SQL database. 
Many situations will require you to find the length of a string stored in your database. 
For example, you may need to limit the number of characters that are displayed in an application or you may need 
to ensure that a column in your dataset contains values that are all the same length. 
In this example, we are going to determine the length of the description column in the film table of the DVD Rental database.*/

-- Select the title and description columns from the film table.
-- Find the number of characters in the description column with the alias desc_len.
SELECT 
  -- Select the title and description columns
  title,
  description,
  -- Determine the length of the description column
  LENGTH(description) AS desc_len
FROM film;


/*Truncating strings
In the previous exercise, you calculated the length of the description column and noticed that the number of 
characters varied but most of the results were over 75 characters. 
There will be many times when you need to truncate a text column to a certain length to meet specific criteria for an application. 
In this exercise, we will practice getting the first 50 characters of the description column.*/

-- Select the first 50 characters of the description column with the alias short_desc
SELECT 
  -- Select the first 50 characters of description
  LEFT(description, 50) AS short_desc
FROM 
  film AS f; 
  
 
/*Extracting substrings from text data
In this exercise, you are going to practice how to extract substrings from text columns. 
The Sakila database contains the address table which stores the street address for all the rental store locations. 
You need a list of all the street names where the stores are located but the address column also contains the street number. 
You'll use several functions that you've learned about in the video to manipulate the address column and return only the street address.*/

-- Extract only the street address without the street number from the address column.
-- Use functions to determine the starting and ending position parameters.
SELECT 
  -- Select only the street name from the address table
  SUBSTRING(address FROM POSITION(' ' IN address)+1 FOR CHAR_LENGTH(address))
FROM 
  address;
  
  
/*Combining functions for string manipulation
In the next example, we are going to break apart the email column from the customer table into three new derived fields. 
Parsing a single column into multiple columns can be useful when you need to work with certain subsets of data. 
Email addresses have embedded information stored in them that can be parsed out to derive additional information about our data. 
For example, we can use the techniques we learned about in the video to determine how many of our customers use an email from a specific domain.*/

-- Extract the characters to the left of the @ of the email column in the customer table and alias it as username.
-- Now use SUBSTRING to extract the characters after the @ of the email column and alias the new derived field as domain.
SELECT
  -- Extract the characters to the left of the '@'
  LEFT(email, POSITION('@' IN email)-1) AS username,
  -- Extract the characters to the right of the '@'
  SUBSTRING(email FROM POSITION('@' IN email)+1 FOR LENGTH(email)) AS domain
FROM customer;


/*Padding
Padding strings is useful in many real-world situations. 
Earlier in this course, we learned about string concatenation and how to combine the customer's first and last name 
separated by a single blank space and also combined the customer's full name with their email address.

The padding functions that we learned about in the video are an alternative approach to do this task. 
To use this approach, you will need to combine and nest functions to determine the length of a string to produce the desired result. 
Remember when calculating the length of a string you often need to adjust the integer returned to get the proper length or position of a string.
Let's revisit the string concatenation exercise but use padding functions.*/

-- Parte 1: Add a single space to the end or right of the first_name column using a padding function.
-- Use the || operator to concatenate the padded first_name to the last_name column.
-- Concatenate the padded first_name and last_name 
SELECT 
	RPAD(first_name, LENGTH(first_name)+1) || last_name AS full_name
FROM customer;

-- Parte 2: Now add a single space to the left or beginning of the last_name column using a different padding function than the first step.
-- Use the || operator to concatenate the first_name column to the padded last_name.
-- Concatenate the first_name and last_name 
SELECT 
	first_name || LPAD(last_name, LENGTH(last_name)+1) AS full_name
FROM customer; 

-- Parte 3: Add a single space to the right or end of the first_name column.
-- Add the characters < to the right or end of last_name column.
-- Finally, add the characters > to the right or end of the email column.
-- Concatenate the first_name and last_name 
SELECT 
	RPAD(first_name, LENGTH(first_name)+1) 
    || RPAD(last_name, LENGTH(last_name)+2, ' <') 
    || RPAD(email, LENGTH(email)+1, '>') AS full_email
FROM customer; 


/*The TRIM function
In this exercise, we are going to revisit and combine a couple of exercises from earlier in this chapter. 
If you recall, you used the LEFT() function to truncate the description column to 50 characters 
but saw that some words were cut off and/or had trailing whitespace. 
We can use trimming functions to eliminate the whitespace at the end of the string after it's been truncated.*/

-- Convert the film category name to uppercase and use the CONCAT() concatenate it with the title.
-- Truncate the description to the first 50 characters and make sure there is no leading or trailing whitespace after truncating.
-- Concatenate the uppercase category name and film title
SELECT 
  CONCAT(UPPER(c.name), ': ', f.title) AS film_category, 
  -- Truncate the description remove trailing whitespace
  TRIM(LEFT(description, 50)) AS film_desc
FROM 
  film AS f 
  INNER JOIN film_category AS fc 
  	ON f.film_id = fc.film_id 
  INNER JOIN category AS c 
  	ON fc.category_id = c.category_id;
    

/*Putting it all together
In this exercise, we are going to use the film and category tables to create a new field called film_category by concatenating
the category name with the film's title. 
You will also practice how to truncate text fields like the film table's description column without cutting off a word.

To accomplish this we will use the REVERSE() function to help determine the position of the last whitespace character 
in the description before we reach 50 characters. 
This technique can be used to determine the position of the last character that you want to truncate and ensure 
that it is less than or equal to 50 characters AND does not cut off a word.

This is an advanced technique but I know you can do it! Let's dive in.*/

-- Get the first 50 characters of the description column
/*Determine the position of the last whitespace character of the truncated description column and subtract it from the number 50 as 
the second parameter in the first function above.*/
SELECT 
  UPPER(c.name) || ': ' || f.title AS film_category, 
  -- Truncate the description without cutting off a word
  LEFT(description, 50 - 
    -- Subtract the position of the first whitespace character
    POSITION(
      ' ' IN REVERSE(LEFT(description, 50))
    )
  ) 
FROM 
  film AS f 
  INNER JOIN film_category AS fc 
  	ON f.film_id = fc.film_id 
  INNER JOIN category AS c 
  	ON fc.category_id = c.category_id;


/*A review of the LIKE operator
The LIKE operator allows us to filter our queries by matching one or more characters in text data. 
By using the % wildcard we can match one or more characters in a string. 
This is useful when you want to return a result set that matches certain characteristics and can also be very helpful during 
exploratory data analysis or data cleansing tasks.
Let's explore how different usage of the % wildcard will return different results by looking at the film table of the Sakila DVD Rental database.*/

-- Parte 1: Select all columns for all records that begin with the word GOLD.
-- Select all columns
SELECT *
FROM film
-- Select only records that begin with the word 'GOLD'
WHERE title LIKE 'GOLD%';

-- Parte 2: Now select all records that end with the word GOLD.
SELECT *
FROM film
-- Select only records that end with the word 'GOLD'
WHERE title LIKE '%GOLD';

-- Parte 3: Finally, select all records that contain the word 'GOLD'.
SELECT *
FROM film
-- Select only records that contain the word 'GOLD'
WHERE title LIKE '%GOLD%';


What is a tsvector?
You saw how to convert strings to tsvector and tsquery in the video and, in this exercise, we are going to dive deeper 
into what these functions actually return after converting a string to a tsvector. 
In this example, you will convert a text column from the film table to a tsvector and inspect the results. 
Understanding how full-text search works is the first step in more advanced machine learning and data science concepts like natural language processing.

-- Select the film description and convert it to a tsvector data type.
-- Select the film description as a tsvector
SELECT to_tsvector(description)
FROM film;



/*Basic full-text search
Searching text will become something you do repeatedly when building applications or exploring data sets for data science. 
Full-text search is helpful when performing exploratory data analysis for a natural language processing model 
or building a search feature into your application.

In this exercise, you will practice searching a text column and match it against a string. 
The search will return the same result as a query that uses the LIKE operator with the % wildcard at the beginning and end of the string, 
but will perform much better and provide you with a foundation for more advanced full-text search queries. Let's dive in.*/

-- Select the title and description columns from the film table.
-- Perform a full-text search on the title column for the word elf.
-- Select the title and description
SELECT title, description
FROM film
-- Convert the title to a tsvector and match it against the tsquery 
WHERE to_tsvector(title) @@ to_tsquery('elf');



/*User-defined data types
ENUM or enumerated data types are great options to use in your database when you have a column where you want to store a fixed 
list of values that rarely change. 
Examples of when it would be appropriate to use an ENUM include days of the week and states or provinces in a country.

Another example can be the directions on a compass (i.e., north, south, east and west.) 
In this exercise, you are going to create a new ENUM data type called compass_position.*/

-- Parte 1: Create a new enumerated data type called compass_position.
-- Use the four positions of a compass as the values.
-- Create an enumerated data type, compass_position
CREATE TYPE compass_position AS ENUM (
  	-- Use the four cardinal directions
  	'North', 
  	'South',
  	'East', 
  	'West'
);

-- Parte 2: Verify that the new data type has been created by looking in the pg_type system table.
-- Confirm the new data type is in the pg_type system table
SELECT typname, typcategory
FROM pg_type
WHERE typname='compass_position';


/*Getting info about user-defined data types
The Sakila database has a user-defined enum data type called mpaa_rating. 
The rating column in the film table is an mpaa_rating type and contains the familiar rating for that film like PG or R. 
This is a great example of when an enumerated data type comes in handy. Film ratings have a limited number of standard values that rarely change.

When you want to learn about a column or data type in your database the best place to start is the INFORMATION_SCHEMA. 
You can find information about the rating column that can help you learn about the type of data you can expect to find. 
For enum data types, you can also find the specific values that are valid for a particular enum by looking in the pg_enum system table. 
Let's dive into the exercises and learn more.*/

-- Parte 1: Select the column_name, data_type, udt_name.
-- Filter for the rating column in the film table.
-- Select the column name, data type and udt name columns
SELECT column_name, data_type, udt_name
FROM INFORMATION_SCHEMA.COLUMNS 
-- Filter by the rating column in the film table
WHERE table_name ='film' AND column_name='rating';

-- Parte 2: Select all columns from the pg_type table where the type name is equal to mpaa_rating.
SELECT *
FROM pg_type
WHERE typname='mpaa_rating';


/*User-defined functions in Sakila
If you were running a real-life DVD Rental store, there are many questions that you may need to answer repeatedly like 
whether a film is in stock at a particular store or the outstanding balance for a particular customer. 
These types of scenarios are where user-defined functions will come in very handy. The Sakila database has several user-defined functions pre-defined. 
These functions are available out-of-the-box and can be used in your queries like many of the built-in functions we've learned about in this course.

In this exercise, you will build a query step-by-step that can be used to produce a report to determine which film title is currently 
held by which customer using the inventory_held_by_customer() function.*/

-- Parte 1: Select the title and inventory_id columns from the film and inventory tables in the database.
-- Select the film title and inventory ids
SELECT 
	f.title, 
    i.inventory_id
FROM film AS f 
	-- Join the film table to the inventory table
	INNER JOIN inventory AS i ON f.film_id=i.film_id; 
 
-- Parte 2: inventory_id is currently held by a customer and alias the column as held_by_cust
-- Select the film title, rental and inventory ids
SELECT 
	f.title, 
    i.inventory_id,
    -- Determine whether the inventory is held by a customer
    inventory_held_by_customer(i.inventory_id) AS held_by_cust 
FROM film as f 
	-- Join the film table to the inventory table
	INNER JOIN inventory AS i ON f.film_id=i.film_id; 
  
-- Parte 3: Now filter your query to only return records where the inventory_held_by_customer() function returns a non-null value.
-- Select the film title and inventory ids
SELECT 
	f.title, 
    i.inventory_id,
    -- Determine whether the inventory is held by a customer
    inventory_held_by_customer(i.inventory_id) as held_by_cust
FROM film as f 
	INNER JOIN inventory AS i ON f.film_id=i.film_id 
WHERE
	-- Only include results where the held_by_cust is not null
    inventory_held_by_customer(i.inventory_id) IS NOT NULL


/*Enabling extensions
Before you can use the capabilities of an extension it must be enabled. 
As you have previously learned, most PostgreSQL distributions come pre-bundled with many useful extensions to help extend 
the native features of your database. You will be working with fuzzystrmatch and pg_trgm in upcoming exercises but before 
you can practice using the capabilities of these extensions you will need to first make sure they are enabled in our database. 
In this exercise you will enable the pg_trgm extension and confirm that the fuzzystrmatch extension, which was enabled in the video, 
is still enabled by querying the pg_extension system table.*/

-- Parte 1: Enable the pg_trgm extension
-- Enable the pg_trgm extension
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Parte 2: Now confirm that both fuzzystrmatch and pg_trgm are enabled by selecting all rows from the appropriate system table.
-- Select all rows extensions
SELECT * 
FROM pg_extension;


/*Measuring similarity between two strings
Now that you have enabled the fuzzystrmatch and pg_trgm extensions you can begin to explore their capabilities. 
First, we will measure the similarity between the title and description from the film table of the Sakila database.*/

-- Select the film title and description.
-- Calculate the similarity between the title and description.
-- Select the title and description columns
SELECT 
  title, 
  description, 
  -- Calculate the similarity
  similarity(title, description)
FROM 
  film;
  

/*Levenshtein distance examples
Now let's take a closer look at how we can use the levenshtein function to match strings against text data. 
If you recall, the levenshtein distance represents the number of edits required to convert one string to another string being compared.

In a search application or when performing data analysis on any data that contains manual user input, 
you will always want to account for typos or incorrect spellings. The levenshtein function provides a great method for performing this task. 
In this exercise, we will perform a query against the film table using a search string with a misspelling and use the results 
from levenshtein to determine a match. Let's check it out.*/

-- Select the film title and film description.
-- Calculate the levenshtein distance for the film title with the string JET NEIGHBOR.
-- Select the title and description columns
SELECT  
  title, 
  description, 
  -- Calculate the levenshtein distance
  levenshtein(title, 'JET NEIGHBOR') AS distance
FROM 
  film
ORDER BY 3;


/*Putting it all together
In this exercise, we are going to use many of the techniques and concepts we learned throughout the course to generate a data set 
that we could use to predict whether the words and phrases used to describe a film have an impact on the number of rentals.

First, you need to create a tsvector from the description column in the film table. 
You will match against a tsquery to determine if the phrase "Astounding Drama" leads to more rentals per month. 
Next, create a new column using the similarity function to rank the film descriptions based on this phrase.*/

-- Parte 1: Select the title and description for all DVDs from the film table.
-- Perform a full-text search by converting the description to a tsvector and match it to the phrase 'Astounding & Drama' 
-- using a tsquery in the WHERE clause.
-- Select the title and description columns
SELECT  
  title, 
  description 
FROM 
  film
WHERE 
  -- Match "Astounding Drama" in the description
  to_tsvector(description) @@ 
  to_tsquery('Astounding & Drama');
 
-- Parte 2: Add a new column that calculates the similarity of the description with the phrase 'Astounding Drama'.
-- Sort the results by the new similarity column in descending order.
SELECT 
  title, 
  description, 
  -- Calculate the similarity
  similarity(description, 'Astounding & Drama')
FROM 
  film 
WHERE 
  to_tsvector(description) @@ 
  to_tsquery('Astounding & Drama') 
ORDER BY 
	similarity(description, 'Astounding & Drama') DESC;



