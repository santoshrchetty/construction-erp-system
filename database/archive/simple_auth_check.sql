-- Direct Check of Authorization Fields and Objects
-- ===============================================

-- 1. Simple count of authorization fields
SELECT COUNT(*) as total_authorization_fields FROM authorization_fields;

-- 2. Simple count of authorization objects  
SELECT COUNT(*) as total_authorization_objects FROM authorization_objects;

-- 3. List all existing authorization fields
SELECT field_name, field_description, field_values, is_required
FROM authorization_fields
ORDER BY field_name;

-- 4. List objects that DO have fields
SELECT DISTINCT ao.object_name, ao.module, COUNT(af.id) as field_count
FROM authorization_objects ao
JOIN authorization_fields af ON ao.id = af.auth_object_id
GROUP BY ao.id, ao.object_name, ao.module
ORDER BY field_count DESC, ao.object_name;

-- 5. Show field-object relationships
SELECT ao.object_name, af.field_name, af.field_values
FROM authorization_objects ao
JOIN authorization_fields af ON ao.id = af.auth_object_id
ORDER BY ao.object_name, af.field_name;