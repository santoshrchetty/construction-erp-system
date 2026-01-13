-- Check module to authorization object mapping
SELECT 
    ao.module,
    COUNT(ao.id) as object_count,
    STRING_AGG(ao.object_name, ', ' ORDER BY ao.object_name) as objects,
    COUNT(af.id) as total_fields
FROM authorization_objects ao
LEFT JOIN authorization_fields af ON ao.id = af.auth_object_id
WHERE ao.is_active = true
GROUP BY ao.module
ORDER BY ao.module;

-- Check specific objects per module
SELECT 
    ao.module,
    ao.object_name,
    ao.description,
    COUNT(af.id) as field_count,
    STRING_AGG(af.field_name, ', ' ORDER BY af.field_name) as fields
FROM authorization_objects ao
LEFT JOIN authorization_fields af ON ao.id = af.auth_object_id
WHERE ao.is_active = true
GROUP BY ao.module, ao.object_name, ao.description
ORDER BY ao.module, ao.object_name;

-- Check role assignments by module
SELECT 
    r.name as role_name,
    ao.module,
    COUNT(rao.id) as assignments,
    STRING_AGG(ao.object_name, ', ' ORDER BY ao.object_name) as assigned_objects
FROM roles r
JOIN role_authorization_objects rao ON r.id = rao.role_id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE rao.is_active = true AND ao.is_active = true
GROUP BY r.name, ao.module
ORDER BY r.name, ao.module;