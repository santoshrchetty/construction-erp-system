-- Fix duplicate WBS Management titles by making them unique
UPDATE tiles 
SET title = 'WBS Structure Management'
WHERE title = 'WBS Management' 
AND construction_action = 'manage'
AND route = '/wbs-management';

-- Remove the old duplicate tile
DELETE FROM tiles 
WHERE title = 'WBS Management' 
AND construction_action = 'wbs-management'
AND route = '/projects/wbs';

-- Verify tiles are now unique
SELECT 
    title,
    subtitle,
    construction_action,
    route,
    is_active
FROM tiles 
WHERE title LIKE '%WBS%'
ORDER BY title;