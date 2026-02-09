-- Check what authorization objects exist in materials/MM module
SELECT object_name, module, description, is_active
FROM authorization_objects 
WHERE module IN ('materials', 'MM', 'procurement')
ORDER BY module, object_name;

-- Check if there are any authorization objects without a module (the "unknown Module")
SELECT object_name, module, description, is_active
FROM authorization_objects 
WHERE module IS NULL OR module = '' OR TRIM(module) = ''
ORDER BY object_name;

-- Check what modules the admin UI is looking for
SELECT DISTINCT module FROM authorization_objects 
WHERE is_active = true AND module IS NOT NULL AND TRIM(module) != ''
ORDER BY module;