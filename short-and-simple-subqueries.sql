-- Number 1.1: Filtering using scalar subqueries
-- Calculate triple the average home + away goals scored across all matches. 
-- This will become your subquery in the next step. Note that this column does not have an alias, so it will be called ?column? in your results.

-- Select the average of home + away goals, multiplied by 3
SELECT 
	3 * AVG(home_goal + away_goal)
FROM matches_2013_2014;

-- Number 1.2
-- Select the date, home goals, and away goals in the main query.
-- Filter the main query for matches where the total goals scored exceed the value in the subquery.

SELECT 
	-- Select the date, home goals, and away goals scored
    date,
	home_goal,
	away_goal
FROM  matches_2013_2014
-- Filter for matches where total goals exceeds 3x the average
WHERE (home_goal + away_goal) > 
       (SELECT 3 * AVG(home_goal + away_goal)
        FROM matches_2013_2014); 
        
-- Number 2: Filtering using a subquery with a list
-- Create a subquery in the WHERE clause that retrieves all unique hometeam_ID values from the match table.
-- Select the team_long_name and team_short_name from the team table. Exclude all values from the subquery in the main query.

SELECT 
	-- Select the team long and short names
	team_long_name,
	team_short_name
FROM team 
-- Exclude all values from the subquery
WHERE team_api_id NOT IN
     (SELECT DISTINCT hometeam_ID FROM match);
     
-- Number 3: Filtering with more complex subquery conditions
Create a subquery in WHERE clause that retrieves all hometeam_ID values from match with a home_goal score greater than or equal to 8.
Select the team_long_name and team_short_name from the team table. Include all values from the subquery in the main query.

SELECT
	-- Select the team long and short names
	team_long_name,
	team_short_name
FROM team
-- Filter for teams with 8 or more home goals
WHERE team_api_id IN
	  (SELECT hometeam_ID 
       FROM match
       WHERE home_goal >= 8);
       
-- Number 4.1: Joining Subqueries in FROM
-- Create the subquery to be used in the next step, which selects the country ID and match ID (id) from the match table.
-- Filter the query for matches with greater than or equal to 10 goals.

SELECT 
	-- Select the country ID and match ID
	country_id, 
    id 
FROM match
-- Filter for matches with 10 or more goals in total
WHERE (home_goal + away_goal) >= 10;

-- Number 4.2
-- Construct a subquery that selects only matches with 10 or more total goals.
-- Inner join the subquery onto country in the main query.
-- Select name from country and count the id column from match.

SELECT
	-- Select country name and the count match IDs
    c.name AS country_name,
    COUNT(c.id) AS matches
FROM country AS c
-- Inner join the subquery onto country
-- Select the country id and match id columns
INNER JOIN (SELECT country_id, id 
           FROM match
           -- Filter the subquery by matches with 10+ goals
           WHERE (home_goal + away_goal) >= 10) AS sub
ON c.id = sub.country_id
GROUP BY c.name;

-- Number 5: Building on Subqueries in FROM
-- Complete the subquery inside the FROM clause. Select the country name from the country table, along with the date, the home goal, the away goal, and the total goals columns from the match table.
-- Create a column in the subquery that adds home and away goals, called total_goals. This will be used to filter the main query.
-- Select the country, date, home goals, and away goals in the main query.
-- Filter the main query for games with 10 or more total goals.

SELECT
	-- Select country, date, home, and away goals from the subquery
    country,
    date,
    home_goal,
    away_goal
FROM 
	-- Select country name, date, home_goal, away_goal, and total goals in the subquery
	(SELECT c.name AS country, 
     	    m.date, 
     		m.home_goal, 
     		m.away_goal,
           (m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN country AS c
    ON m.country_id = c.id) AS subq
-- Filter by total goals scored in the main query
WHERE total_goals >= 10;
