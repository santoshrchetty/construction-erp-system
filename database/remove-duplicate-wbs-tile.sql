-- Remove the old WBS Management tile (keep the new one with independent project selection)
DELETE FROM tiles 
WHERE title = 'WBS Management' 
AND construction_action = 'wbs-management'
AND route = '/projects/wbs';

-- Verify only one WBS Management tile remains
SELECT 
    title,
    subtitle,
    icon,
    route,
    tile_category,
    construction_action,
    is_active
FROM tiles 
WHERE title = 'WBS Management';