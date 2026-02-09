-- Remove duplicate activities from the activities table
-- Keep only the first occurrence of each duplicate based on project_code and code

DELETE FROM public.activities 
WHERE ctid NOT IN (
    SELECT MIN(ctid) 
    FROM public.activities 
    GROUP BY project_code, code
);

-- Verify no duplicates remain
SELECT project_code, code, COUNT(*) as count
FROM public.activities 
GROUP BY project_code, code 
HAVING COUNT(*) > 1;