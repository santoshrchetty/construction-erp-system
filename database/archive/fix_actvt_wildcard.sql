-- Fix ACTVT field to include '*' for full access
-- ===============================================

-- Update existing ACTVT fields to include '*' value
UPDATE authorization_fields 
SET field_values = array_append(field_values, '*')
WHERE field_name = 'ACTVT' 
AND NOT ('*' = ANY(field_values));

-- Add ACTVT field with '*' to objects that don't have it
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values, is_required)
SELECT 
    ao.id,
    'ACTVT',
    'Activity',
    ARRAY['01', '02', '03', '05', '06', '*'],
    true
FROM authorization_objects ao
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id 
    AND af.field_name = 'ACTVT'
);

-- Verify ACTVT fields now have '*' value
SELECT 'ACTVT Fields with * value:' as status,
       COUNT(*) as total_actvt_fields,
       COUNT(CASE WHEN '*' = ANY(field_values) THEN 1 END) as fields_with_wildcard
FROM authorization_fields 
WHERE field_name = 'ACTVT';