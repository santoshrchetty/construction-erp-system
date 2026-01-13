-- Comprehensive module mapping verification
-- =====================================

-- 1. Check if authorization_objects table exists and has data
SELECT 'authorization_objects' as table_name, COUNT(*) as record_count FROM authorization_objects;

-- 2. Check module distribution
SELECT 
    COALESCE(module, 'NULL') as module_name,
    COUNT(*) as object_count,
    ARRAY_AGG(object_name ORDER BY object_name) as objects
FROM authorization_objects 
GROUP BY module 
ORDER BY module;

-- 3. Check authorization_fields mapping
SELECT 
    ao.module,
    ao.object_name,
    COUNT(af.id) as field_count,
    ARRAY_AGG(af.field_name ORDER BY af.field_name) as fields
FROM authorization_objects ao
LEFT JOIN authorization_fields af ON ao.id = af.auth_object_id
GROUP BY ao.module, ao.object_name, ao.id
ORDER BY ao.module, ao.object_name;

-- 4. Check role_authorization_objects assignments
SELECT 
    r.name as role_name,
    ao.module,
    ao.object_name,
    rao.field_values,
    rao.module_full_access,
    rao.object_full_access
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
JOIN roles r ON rao.role_id = r.id
WHERE rao.is_active = true
ORDER BY r.name, ao.module, ao.object_name;

-- 5. Check for orphaned records
SELECT 'Orphaned fields' as issue, COUNT(*) as count
FROM authorization_fields af
LEFT JOIN authorization_objects ao ON af.auth_object_id = ao.id
WHERE ao.id IS NULL

UNION ALL

SELECT 'Orphaned role assignments' as issue, COUNT(*) as count
FROM role_authorization_objects rao
LEFT JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE ao.id IS NULL

UNION ALL

SELECT 'Role assignments without roles' as issue, COUNT(*) as count
FROM role_authorization_objects rao
LEFT JOIN roles r ON rao.role_id = r.id
WHERE r.id IS NULL;

-- 6. Verify module consistency
SELECT DISTINCT module FROM authorization_objects WHERE module IS NOT NULL ORDER BY module;