-- CHECK APPROVAL TILES STATUS
-- Verify if approval tiles are loaded and accessible

-- Check if approval tiles exist
SELECT 'CHECKING APPROVAL TILES:' as info;
SELECT 
    title,
    category,
    route,
    is_active
FROM tiles 
WHERE title ILIKE '%approval%' 
   OR route ILIKE '%approval%'
   OR category = 'Administration'
ORDER BY category, title;

-- Check if flexible approval tiles were loaded
SELECT 'CHECKING FLEXIBLE APPROVAL TILES:' as info;
SELECT COUNT(*) as total_tiles
FROM tiles 
WHERE created_at > NOW() - INTERVAL '1 day'
AND (title ILIKE '%approval%' OR category = 'Administration');

-- Check user authorization for approval tiles
SELECT 'CHECKING USER AUTHORIZATION:' as info;
SELECT 
    t.title,
    t.route,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM user_role_assignments ura
            JOIN role_authorization_assignments raa ON ura.role_id = raa.role_id
            JOIN authorization_objects ao ON raa.auth_object_id = ao.id
            WHERE ura.user_id = '550e8400-e29b-41d4-a716-446655440001'
            AND ao.object_name ILIKE '%approval%'
        ) THEN 'AUTHORIZED'
        ELSE 'NOT AUTHORIZED'
    END as auth_status
FROM tiles t
WHERE t.title ILIKE '%approval%'
LIMIT 5;

-- List all Administration category tiles
SELECT 'ADMINISTRATION TILES:' as info;
SELECT 
    title,
    route,
    icon,
    is_active
FROM tiles 
WHERE category = 'Administration'
ORDER BY title;

-- Quick fix: Insert Approval Configuration tile if missing
INSERT INTO tiles (
    title, description, category, route, icon, 
    color_from, color_to, is_active
) 
SELECT 
    'Approval Configuration',
    'Configure approval workflows and policies',
    'Administration',
    '/approval-configuration',
    'Settings',
    '#3B82F6',
    '#1E40AF',
    true
WHERE NOT EXISTS (
    SELECT 1 FROM tiles WHERE title = 'Approval Configuration'
);

SELECT 'APPROVAL CONFIGURATION TILE STATUS:' as result;
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM tiles WHERE title = 'Approval Configuration')
        THEN '✅ Approval Configuration tile EXISTS'
        ELSE '❌ Approval Configuration tile MISSING'
    END as tile_status;