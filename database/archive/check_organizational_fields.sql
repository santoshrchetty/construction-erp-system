-- Check Organizational Authorization Fields Status
-- ==============================================

-- 1. Check existing organizational fields across all objects
SELECT 'Existing Organizational Fields:' as info,
       ao.object_name,
       ao.module,
       af.field_name,
       af.field_description,
       af.field_values
FROM authorization_objects ao
JOIN authorization_fields af ON ao.id = af.auth_object_id
WHERE af.field_name IN ('BUKRS', 'COMP_CODE', 'KOSTL', 'COST_CTR', 'WERKS', 'EKORG', 'LGORT')
ORDER BY ao.object_name, af.field_name;

-- 2. Check which objects are missing organizational fields
SELECT 'Objects Missing Org Fields:' as info,
       ao.object_name,
       ao.module,
       ao.description,
       COUNT(af.id) as field_count
FROM authorization_objects ao
LEFT JOIN authorization_fields af ON ao.id = af.auth_object_id 
    AND af.field_name IN ('BUKRS', 'COMP_CODE', 'KOSTL', 'COST_CTR', 'WERKS', 'EKORG', 'LGORT')
GROUP BY ao.id, ao.object_name, ao.module, ao.description
HAVING COUNT(af.id) = 0
ORDER BY ao.module, ao.object_name;

-- 3. Summary by field type
SELECT 'Field Usage Summary:' as info,
       af.field_name,
       af.field_description,
       COUNT(DISTINCT ao.id) as objects_using_field
FROM authorization_fields af
JOIN authorization_objects ao ON af.auth_object_id = ao.id
WHERE af.field_name IN ('BUKRS', 'COMP_CODE', 'KOSTL', 'COST_CTR', 'WERKS', 'EKORG', 'LGORT', 'ACTVT')
GROUP BY af.field_name, af.field_description
ORDER BY objects_using_field DESC;

-- 4. Check company codes and cost centers available
SELECT 'Available Company Codes:' as info, company_code, company_name
FROM company_codes
ORDER BY company_code;

SELECT 'Available Cost Centers:' as info, cost_center_code, cost_center_name, company_code
FROM cost_centers
ORDER BY company_code, cost_center_code;