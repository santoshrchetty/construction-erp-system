-- Check for Duplicate Material Tiles
-- Identify potential duplicate tiles that might be causing the issue

-- 1. Check for tiles with similar titles
SELECT 'Tiles with similar titles:' as info;
SELECT title, subtitle, construction_action, auth_object, tile_category
FROM tiles 
WHERE title ILIKE '%material%' AND title ILIKE '%plant%'
ORDER BY title;

-- 2. Check for tiles with similar construction_action
SELECT 'Tiles with similar construction actions:' as info;
SELECT title, subtitle, construction_action, auth_object
FROM tiles 
WHERE construction_action ILIKE '%material%' AND construction_action ILIKE '%plant%'
ORDER BY construction_action;

-- 3. Check for exact duplicates by title
SELECT 'Exact duplicate titles:' as info;
SELECT title, COUNT(*) as count
FROM tiles 
WHERE title IN ('Extend Material to Plant', 'Material Plant Parameters', 'Material Pricing')
GROUP BY title
HAVING COUNT(*) > 1;

-- 4. Check all material-related tiles
SELECT 'All Material-related tiles:' as info;
SELECT title, subtitle, construction_action, auth_object, tile_category
FROM tiles 
WHERE tile_category = 'Materials' OR construction_action ILIKE '%material%'
ORDER BY title;

-- 5. Check for authorization object conflicts
SELECT 'Authorization object conflicts:' as info;
SELECT auth_object, COUNT(*) as count, STRING_AGG(title, ', ') as titles
FROM tiles 
WHERE auth_object IN ('MM_MAT_EXTEND', 'MM_PLANT_PARAM', 'MM_PRICING')
GROUP BY auth_object
HAVING COUNT(*) > 1;