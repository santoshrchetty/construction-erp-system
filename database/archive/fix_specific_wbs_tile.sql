-- Fix specific WBS tile with PS_WBS_UPDATE
-- =========================================

UPDATE tiles 
SET auth_object = 'PS_WBS_MODIFY'
WHERE id = 'c0b56116-8bde-4d9c-8c24-6ee324ade567';

-- Verify the fix
SELECT id, title, tile_category, auth_object, subtitle, construction_action
FROM tiles 
WHERE id = 'c0b56116-8bde-4d9c-8c24-6ee324ade567';