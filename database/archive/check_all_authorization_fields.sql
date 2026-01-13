-- Check All Existing Authorization Fields and Naming
-- ==================================================

-- 1. List ALL authorization fields with their naming patterns
SELECT 'All Authorization Fields:' as info,
       af.field_name,
       af.field_description,
       COUNT(DISTINCT ao.id) as used_in_objects,
       STRING_AGG(DISTINCT ao.object_name, ', ' ORDER BY ao.object_name) as object_names
FROM authorization_fields af
JOIN authorization_objects ao ON af.auth_object_id = ao.id
GROUP BY af.field_name, af.field_description
ORDER BY used_in_objects DESC, af.field_name;

-- 2. Check field naming patterns
SELECT 'Field Naming Patterns:' as info,
       SUBSTRING(af.field_name, 1, 3) as prefix,
       COUNT(*) as field_count,
       STRING_AGG(DISTINCT af.field_name, ', ' ORDER BY af.field_name) as field_names
FROM authorization_fields af
GROUP BY SUBSTRING(af.field_name, 1, 3)
ORDER BY field_count DESC;

-- 3. Sample field values for organizational fields
SELECT 'Sample Field Values:' as info,
       af.field_name,
       af.field_description,
       af.field_values,
       af.is_required
FROM authorization_fields af
WHERE af.field_name IN ('BUKRS', 'COMP_CODE', 'KOSTL', 'COST_CTR', 'WERKS', 'EKORG', 'LGORT', 'ACTVT')
LIMIT 20;

-- 4. Objects with no fields at all
SELECT 'Objects with No Fields:' as info,
       ao.object_name,
       ao.module,
       ao.description
FROM authorization_objects ao
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id
)
ORDER BY ao.module, ao.object_name;