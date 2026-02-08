-- ============================================================================
-- STEP 5: Test Authorization Flow
-- ============================================================================
-- Purpose: Verify authorization system works correctly with friendly module names
-- Safe to run: YES (read-only queries + optional data fixes)
-- ============================================================================

-- 5.1 FIX: Remove materials module from HR role (fixes unwanted tile visibility)
-- This is the main issue we're solving - HR should only see HR tiles
DELETE FROM role_authorization_objects
WHERE role_id = (SELECT id FROM roles WHERE name = 'HR')
  AND auth_object_id IN (
    SELECT id FROM authorization_objects WHERE module = 'materials'
  );

-- Verify deletion
SELECT 
    'HR role modules after cleanup' as test,
    ao.module,
    COUNT(*) as object_count
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE rao.role_id = (SELECT id FROM roles WHERE name = 'HR')
GROUP BY ao.module
ORDER BY ao.module;
-- Expected: Only 'hr' module

-- 5.2 Test HR User (emy@prom.com)
-- Get HR user's modules
SELECT 
    'HR user modules' as test,
    module_code
FROM get_user_modules((SELECT id FROM users WHERE email = 'emy@prom.com'))
ORDER BY module_code;
-- Expected: ['hr'] only

-- Get tiles visible to HR user
SELECT 
    'HR user tiles' as test,
    t.title,
    t.module_code,
    t.tile_category,
    t.route
FROM tiles t
WHERE t.module_code IN (
    SELECT module_code 
    FROM get_user_modules((SELECT id FROM users WHERE email = 'emy@prom.com'))
)
  AND t.is_active = true
ORDER BY t.module_code, t.title;
-- Expected: Only HR category tiles

-- Count tiles by module for HR user
SELECT 
    'HR user tile count by module' as test,
    t.module_code,
    COUNT(*) as tile_count
FROM tiles t
WHERE t.module_code IN (
    SELECT module_code 
    FROM get_user_modules((SELECT id FROM users WHERE email = 'emy@prom.com'))
)
  AND t.is_active = true
GROUP BY t.module_code;
-- Expected: Only 'hr' module with tile count

-- 5.3 Test Admin User
-- Get admin user's modules
SELECT 
    'Admin user modules' as test,
    module_code
FROM get_user_modules((SELECT id FROM users WHERE email = 'admin@prom.com'))
ORDER BY module_code;
-- Expected: Multiple modules (admin, configuration, finance, materials, projects, etc.)

-- Count tiles by module for admin user
SELECT 
    'Admin user tile count by module' as test,
    t.module_code,
    COUNT(*) as tile_count
FROM tiles t
WHERE t.module_code IN (
    SELECT module_code 
    FROM get_user_modules((SELECT id FROM users WHERE email = 'admin@prom.com'))
)
  AND t.is_active = true
GROUP BY t.module_code
ORDER BY t.module_code;

-- 5.4 Test Engineer User
-- Get engineer user's modules
SELECT 
    'Engineer user modules' as test,
    module_code
FROM get_user_modules((SELECT id FROM users WHERE email = 'engineer@prom.com'))
ORDER BY module_code;

-- Count authorization objects by module for Engineer role
SELECT 
    'Engineer role auth objects by module' as test,
    ao.module,
    COUNT(*) as object_count
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE rao.role_id = (SELECT id FROM roles WHERE name = 'Engineer')
GROUP BY ao.module
ORDER BY ao.module;

-- 5.5 Test PlanEng User
-- Get PlanEng user's modules
SELECT 
    'PlanEng user modules' as test,
    module_code
FROM get_user_modules((SELECT id FROM users WHERE email = 'planeng@prom.com'))
ORDER BY module_code;
-- Expected: materials, procurement, projects

-- Count authorization objects by module for PlanEng role
SELECT 
    'PlanEng role auth objects by module' as test,
    ao.module,
    COUNT(*) as object_count
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE rao.role_id = (SELECT id FROM roles WHERE name = 'PlanEng')
GROUP BY ao.module
ORDER BY ao.module;

-- 5.6 Verify Module Consistency
-- Check that all modules in authorization_objects exist in tiles
SELECT 
    'Modules in auth_objects but not in tiles' as check,
    ao.module
FROM (SELECT DISTINCT module FROM authorization_objects WHERE module IS NOT NULL) ao
WHERE ao.module NOT IN (SELECT DISTINCT module_code FROM tiles)
ORDER BY ao.module;
-- Expected: Empty result (all modules should have tiles)

-- Check that all modules in tiles exist in authorization_objects
SELECT 
    'Modules in tiles but not in auth_objects' as check,
    t.module_code
FROM (SELECT DISTINCT module_code FROM tiles) t
WHERE t.module_code NOT IN (SELECT DISTINCT module FROM authorization_objects WHERE module IS NOT NULL)
ORDER BY t.module_code;
-- Expected: Possibly some modules (tiles can exist without auth objects)

-- 5.7 Verify No SAP Codes in System
-- Check tiles
SELECT 
    'SAP codes in tiles' as check,
    COUNT(*) as count
FROM tiles
WHERE module_code IN ('AD', 'CF', 'DM', 'EH', 'EM', 'FI', 'HR', 'IN', 'MM', 'MT', 'PS', 'QM', 'RP', 'WM');
-- Expected: 0

-- Check authorization_objects (should already be friendly names)
SELECT 
    'SAP codes in authorization_objects' as check,
    COUNT(*) as count
FROM authorization_objects
WHERE module IN ('AD', 'CF', 'DM', 'EH', 'EM', 'FI', 'HR', 'IN', 'MM', 'MT', 'PS', 'QM', 'RP', 'WM');
-- Expected: 0

-- 5.8 Summary Report
SELECT 
    'MIGRATION SUMMARY' as report_section,
    '' as detail
UNION ALL
SELECT 
    'Total Roles',
    COUNT(*)::text
FROM roles
WHERE is_active = true
UNION ALL
SELECT 
    'Total Authorization Objects',
    COUNT(*)::text
FROM authorization_objects
WHERE is_active = true
UNION ALL
SELECT 
    'Total Modules',
    COUNT(DISTINCT module)::text
FROM authorization_objects
WHERE module IS NOT NULL
UNION ALL
SELECT 
    'Total Tiles',
    COUNT(*)::text
FROM tiles
WHERE is_active = true
UNION ALL
SELECT 
    'Total Module Codes in Tiles',
    COUNT(DISTINCT module_code)::text
FROM tiles
UNION ALL
SELECT 
    'Materials + Procurement Split',
    CASE 
        WHEN EXISTS (SELECT 1 FROM tiles WHERE module_code = 'materials')
         AND EXISTS (SELECT 1 FROM tiles WHERE module_code = 'procurement')
        THEN 'SUCCESS - MM split into materials and procurement'
        ELSE 'FAILED - MM not properly split'
    END;
