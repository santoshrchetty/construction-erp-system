-- FIX ALL DUPLICATE TILES

-- Remove exact duplicates (keep first occurrence)
DELETE FROM tiles 
WHERE ctid NOT IN (
    SELECT MIN(ctid) 
    FROM tiles 
    GROUP BY title
);

-- Remove WBS duplicate tiles (keep WBS Management only)
DELETE FROM tiles 
WHERE title IN ('WBS Create', 'Create WBS', 'WBS Builder', 'WBS Editor')
  AND title != 'WBS Management';

-- Remove Material duplicate tiles
DELETE FROM tiles 
WHERE title ILIKE '%material%' 
  AND title NOT IN ('Material Master', 'Material Management');

-- Remove Project duplicate tiles  
DELETE FROM tiles 
WHERE title ILIKE '%project%'
  AND title NOT IN ('Project Management', 'Create Project');

-- Remove Finance duplicate tiles
DELETE FROM tiles 
WHERE title ILIKE '%finance%'
  AND title NOT IN ('Finance Management', 'Financial Reports');

-- Remove Admin duplicate tiles
DELETE FROM tiles 
WHERE title ILIKE '%admin%'
  AND title NOT IN ('Admin Management', 'User Management');

-- Remove Approval duplicate tiles
DELETE FROM tiles 
WHERE title ILIKE '%approval%'
  AND title NOT IN ('Approval Management', 'Approval Configuration');

-- Standardize remaining tile titles
UPDATE tiles SET title = 'WBS Management' WHERE title ILIKE '%wbs%' AND title != 'WBS Management';
UPDATE tiles SET title = 'Material Management' WHERE title ILIKE '%material%' AND title != 'Material Management';
UPDATE tiles SET title = 'Project Management' WHERE title ILIKE '%project%' AND title NOT IN ('Create Project', 'Project Management');
UPDATE tiles SET title = 'Finance Management' WHERE title ILIKE '%finance%' AND title != 'Finance Management';
UPDATE tiles SET title = 'Admin Management' WHERE title ILIKE '%admin%' AND title != 'Admin Management';

-- Remove any remaining duplicates after standardization
DELETE FROM tiles 
WHERE ctid NOT IN (
    SELECT MIN(ctid) 
    FROM tiles 
    GROUP BY title
);

-- Final verification
SELECT 'DUPLICATE CHECK' as status;
SELECT title, COUNT(*) as count
FROM tiles 
GROUP BY title 
HAVING COUNT(*) > 1;