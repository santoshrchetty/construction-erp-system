-- Check Current Authorization Objects Status
-- =========================================

-- 1. Total count of authorization objects
SELECT 'Total Authorization Objects:' as info, COUNT(*) as total_count
FROM authorization_objects;

-- 2. Count by module
SELECT 'Objects by Module:' as info, module, COUNT(*) as count
FROM authorization_objects 
GROUP BY module
ORDER BY count DESC, module;

-- 3. Check configuration objects specifically
SELECT 'Configuration Objects:' as info, object_name, description, module, is_active
FROM authorization_objects 
WHERE module = 'configuration'
ORDER BY object_name;

-- 4. Check if role assignments exist for configuration objects
SELECT 'Config Role Assignments:' as info, 
       r.name as role_name,
       ao.object_name,
       rao.field_values,
       rao.is_active
FROM role_authorization_objects rao
JOIN roles r ON rao.role_id = r.id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE ao.module = 'configuration'
ORDER BY r.name, ao.object_name;

-- 5. Latest 10 authorization objects (recently added)
SELECT 'Latest Objects:' as info, object_name, description, module, created_at
FROM authorization_objects 
ORDER BY created_at DESC
LIMIT 10;