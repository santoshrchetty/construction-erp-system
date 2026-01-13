-- Check Authorization Object Nomenclature Patterns
-- ================================================

-- 1. Check existing naming patterns by module
SELECT 'Naming Patterns:' as info, 
       module,
       STRING_AGG(DISTINCT SUBSTRING(object_name, 1, 3), ', ') as prefixes,
       COUNT(*) as count
FROM authorization_objects 
GROUP BY module
ORDER BY module;

-- 2. Show all objects to see actual naming convention
SELECT object_name, module, description
FROM authorization_objects 
ORDER BY module, object_name;

-- 3. Check what configuration objects actually exist
SELECT 'Current Config Objects:' as info, object_name, description, module
FROM authorization_objects 
WHERE module ILIKE '%config%' OR object_name ILIKE '%CONF%'
ORDER BY object_name;

-- 4. Check latest 10 objects added
SELECT 'Latest Added:' as info, object_name, description, module, created_at
FROM authorization_objects 
ORDER BY created_at DESC NULLS LAST
LIMIT 10;