-- Check and fix WBS Management tiles
-- ===================================

-- First, check what WBS tiles exist
SELECT id, title, tile_category, auth_object, subtitle, construction_action
FROM tiles 
WHERE tile_category = 'Project Management' 
AND (title LIKE '%WBS%' OR title LIKE '%Work Breakdown%')
ORDER BY title;

-- Update different WBS tiles to have different auth objects
-- One for creating WBS structure, one for modifying/editing
UPDATE tiles 
SET auth_object = 'PS_WBS_MODIFY',
    construction_action = 'Edit WBS Structure'
WHERE title ILIKE '%WBS%' 
AND tile_category = 'Project Management'
AND (subtitle ILIKE '%edit%' OR subtitle ILIKE '%manage%' OR subtitle ILIKE '%update%');

-- Keep PS_WBS_CREATE for creation-focused tiles
UPDATE tiles 
SET auth_object = 'PS_WBS_CREATE',
    construction_action = 'Create WBS Structure'
WHERE title ILIKE '%WBS%' 
AND tile_category = 'Project Management'
AND (subtitle ILIKE '%create%' OR subtitle ILIKE '%build%' OR subtitle ILIKE '%new%');

-- Final verification
SELECT id, title, tile_category, auth_object, subtitle, construction_action
FROM tiles 
WHERE tile_category = 'Project Management' 
AND (title LIKE '%WBS%' OR title LIKE '%Work Breakdown%')
ORDER BY auth_object, title;