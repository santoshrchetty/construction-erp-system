-- Get actual modules from database
SELECT DISTINCT module FROM authorization_objects WHERE module IS NOT NULL ORDER BY module;