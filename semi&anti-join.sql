-- Query from step 2
SELECT DISTINCT name
  FROM languages
-- Where in statement 
WHERE code IN 
  -- Query from step 1
  -- Subquery
  (SELECT code
   FROM countries
   WHERE region = 'Middle East')
-- Order by name
ORDER BY name;
