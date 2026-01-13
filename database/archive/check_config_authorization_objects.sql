-- Check Configuration Category Authorization Objects
-- ================================================

-- 1. Check existing authorization objects for configuration
SELECT 'Existing Config Auth Objects:' as info, object_name, description, module 
FROM authorization_objects 
WHERE module ILIKE '%config%' OR object_name ILIKE '%CONFIG%' OR description ILIKE '%config%'
ORDER BY object_name;

-- 2. Check ERP-related authorization objects
SELECT 'Existing ERP Auth Objects:' as info, object_name, description, module 
FROM authorization_objects 
WHERE module ILIKE '%erp%' OR object_name ILIKE '%ERP%' OR description ILIKE '%erp%'
ORDER BY object_name;

-- 3. Check all authorization objects by module
SELECT 'All Auth Objects by Module:' as info, module, COUNT(*) as object_count
FROM authorization_objects 
GROUP BY module
ORDER BY module;

-- 4. List all authorization objects
SELECT 'All Authorization Objects:' as info, object_name, description, module, is_active
FROM authorization_objects 
ORDER BY module, object_name;