-- Final Verification: Engineer Role Module Assignments
-- This shows what Engineer role should now see in the UI

-- 1. Engineer role summary
SELECT 
    r.name as role_name,
    COUNT(DISTINCT ao.module) as modules_assigned,
    COUNT(DISTINCT rao.auth_object_id) as total_objects_assigned,
    (SELECT COUNT(DISTINCT module) FROM authorization_objects WHERE module IS NOT NULL) as total_available_modules
FROM roles r
JOIN role_authorization_objects rao ON r.id = rao.role_id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE r.name = 'Engineer'
GROUP BY r.name;

-- 2. Engineer role - objects by module
SELECT 
    ao.module,
    COUNT(DISTINCT rao.auth_object_id) as assigned_objects,
    STRING_AGG(DISTINCT ao.object_name, ', ' ORDER BY ao.object_name) as object_list
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
JOIN roles r ON rao.role_id = r.id
WHERE r.name = 'Engineer'
GROUP BY ao.module
ORDER BY assigned_objects DESC;

-- 3. All modules in system
SELECT 
    module,
    COUNT(*) as total_objects,
    COUNT(CASE WHEN id IN (
        SELECT auth_object_id 
        FROM role_authorization_objects rao
        JOIN roles r ON rao.role_id = r.id
        WHERE r.name = 'Engineer'
    ) THEN 1 END) as engineer_has_access
FROM authorization_objects
WHERE module IS NOT NULL
GROUP BY module
ORDER BY module;

-- 4. Expected UI display
SELECT 
    'Engineer Role UI Display' as info,
    COUNT(DISTINCT ao.module) || '/' || 
    (SELECT COUNT(DISTINCT module) FROM authorization_objects WHERE module IS NOT NULL) || ' modules' as module_display,
    COUNT(DISTINCT rao.auth_object_id) || ' assignments' as assignment_display
FROM roles r
JOIN role_authorization_objects rao ON r.id = rao.role_id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE r.name = 'Engineer';
