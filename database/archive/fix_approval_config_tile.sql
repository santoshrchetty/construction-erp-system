-- FIX APPROVAL CONFIGURATION TILE TO AVOID DUPLICATE ICONS
-- Update to use unique icon following standards

UPDATE tiles 
SET icon = 'fas fa-check-circle'
WHERE title = 'Approval Configuration';

-- Verify no duplicate icons in configuration tiles
SELECT 'CONFIGURATION TILES ICONS:' as info;
SELECT title, icon FROM tiles 
WHERE title ILIKE '%config%' 
ORDER BY title;