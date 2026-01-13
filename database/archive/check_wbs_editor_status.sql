-- Check WBS Editor tile status
-- ============================

SELECT id, title, tile_category, auth_object, is_active, sequence_order
FROM tiles 
WHERE title = 'WBS Editor';

-- Check all Project Management tiles
SELECT title, auth_object, is_active
FROM tiles 
WHERE tile_category = 'Project Management'
ORDER BY sequence_order, title;