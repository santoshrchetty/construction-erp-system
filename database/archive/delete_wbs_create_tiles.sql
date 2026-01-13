-- Find and delete all WBS Management tiles with PS_WBS_CREATE
-- ===========================================================

-- First, find all WBS tiles
SELECT id, title, auth_object, is_active
FROM tiles 
WHERE title ILIKE '%WBS%'
ORDER BY title, auth_object;

-- Delete all WBS Management tiles with PS_WBS_CREATE
DELETE FROM tiles 
WHERE title = 'WBS Management' 
AND auth_object = 'PS_WBS_CREATE';

-- Verify deletion
SELECT id, title, auth_object, is_active
FROM tiles 
WHERE title ILIKE '%WBS%'
ORDER BY title, auth_object;