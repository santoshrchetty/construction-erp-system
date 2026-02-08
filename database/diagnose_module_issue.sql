-- STEP 1: Check what modules actually exist in the database
SELECT 
    module,
    COUNT(*) as object_count,
    STRING_AGG(object_name, ', ' ORDER BY object_name) as sample_objects
FROM authorization_objects
GROUP BY module
ORDER BY object_count DESC;

-- STEP 2: Check Engineer role assignments with current modules
SELECT 
    ao.module,
    COUNT(*) as assigned_objects,
    STRING_AGG(ao.object_name, ', ' ORDER BY ao.object_name) as objects
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
JOIN roles r ON rao.role_id = r.id
WHERE r.name = 'Engineer'
GROUP BY ao.module
ORDER BY assigned_objects DESC;

-- STEP 3: Check PlanEng role assignments with current modules
SELECT 
    ao.module,
    COUNT(*) as assigned_objects,
    STRING_AGG(ao.object_name, ', ' ORDER BY ao.object_name) as objects
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
JOIN roles r ON rao.role_id = r.id
WHERE r.name = 'PlanEng'
GROUP BY ao.module
ORDER BY assigned_objects DESC;

-- STEP 4: Show all objects with their current modules
SELECT 
    id,
    object_name,
    module,
    description,
    is_active
FROM authorization_objects
ORDER BY module, object_name;

-- STEP 5: Check if there are NULL or empty modules
SELECT 
    COUNT(*) as total_objects,
    COUNT(CASE WHEN module IS NULL OR TRIM(module) = '' THEN 1 END) as null_empty_modules,
    COUNT(CASE WHEN module IS NOT NULL AND TRIM(module) != '' THEN 1 END) as has_module
FROM authorization_objects;
