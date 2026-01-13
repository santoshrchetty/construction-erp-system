-- Comprehensive RBAC System Audit
-- =================================

-- 1. ROLES AUDIT
SELECT 'ROLES IN SYSTEM' as audit_section, name, description, is_active
FROM roles
ORDER BY name;

-- 2. AUTHORIZATION OBJECTS AUDIT
SELECT 'AUTHORIZATION OBJECTS' as audit_section, object_name, description, module
FROM authorization_objects
ORDER BY module, object_name;

-- 3. TILES AUDIT
SELECT 'TILES BY CATEGORY' as audit_section, tile_category, title, auth_object, construction_action
FROM tiles
WHERE is_active = true
ORDER BY tile_category, title;

-- 4. ROLE-AUTHORIZATION MAPPINGS
SELECT 'ROLE AUTHORIZATIONS' as audit_section, role_name, auth_object_name, field_values
FROM role_authorization_mapping
ORDER BY role_name, auth_object_name;

-- 5. USER AUTHORIZATIONS FOR ADMIN
SELECT 'ADMIN USER AUTHORIZATIONS' as audit_section, 
       ao.object_name, 
       ao.description,
       ua.field_values
FROM user_authorizations ua
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ua.user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
ORDER BY ao.object_name;

-- 6. TILES WITHOUT AUTHORIZATION OBJECTS
SELECT 'TILES WITHOUT AUTH' as audit_section, title, tile_category
FROM tiles
WHERE auth_object IS NULL AND is_active = true
ORDER BY tile_category, title;

-- 7. AUTHORIZATION OBJECTS NOT USED BY TILES
SELECT 'UNUSED AUTH OBJECTS' as audit_section, ao.object_name, ao.description
FROM authorization_objects ao
WHERE ao.object_name NOT IN (SELECT DISTINCT auth_object FROM tiles WHERE auth_object IS NOT NULL)
ORDER BY ao.object_name;

-- 8. SUMMARY COUNTS
SELECT 'SUMMARY' as audit_section,
       'Total Roles' as item, COUNT(*)::text as count
FROM roles
UNION ALL
SELECT 'SUMMARY', 'Total Auth Objects', COUNT(*)::text FROM authorization_objects
UNION ALL
SELECT 'SUMMARY', 'Total Active Tiles', COUNT(*)::text FROM tiles WHERE is_active = true
UNION ALL
SELECT 'SUMMARY', 'Admin Authorizations', COUNT(*)::text 
FROM user_authorizations WHERE user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f';