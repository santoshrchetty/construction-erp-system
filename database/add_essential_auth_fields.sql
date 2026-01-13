-- Add Essential Authorization Fields to Objects with No Fields
-- ===========================================================

-- Add ACTVT (Activity) field to all objects that have no fields
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values, is_required)
SELECT 
    ao.id,
    'ACTVT',
    'Activity',
    ARRAY['01', '02', '03', '05', '06'],
    true
FROM authorization_objects ao
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id
);

-- Add BUKRS (Company Code) to all objects that have no organizational fields
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values, is_required)
SELECT 
    ao.id,
    'BUKRS',
    'Company Code',
    ARRAY['C001', 'C002', 'C003', 'C004', '*'],
    true
FROM authorization_objects ao
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id 
    AND af.field_name = 'BUKRS'
);

-- Add KOSTL (Cost Center) to all objects for department-level control
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values, is_required)
SELECT 
    ao.id,
    'KOSTL',
    'Cost Center',
    ARRAY['CC-ADMIN', 'CC-MAINT', 'CC-PROJ01', 'CC-PROJ02', 'CC-SALES', 'CC-PROJ03', '*'],
    false
FROM authorization_objects ao
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id 
    AND af.field_name = 'KOSTL'
);

-- Add WERKS (Plant) to materials, inventory, and procurement objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values, is_required)
SELECT 
    ao.id,
    'WERKS',
    'Plant',
    ARRAY['P001', 'P002', 'P003', 'P004', '*'],
    false
FROM authorization_objects ao
WHERE ao.module IN ('materials', 'inventory', 'procurement', 'planning', 'stores')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id 
    AND af.field_name = 'WERKS'
);

-- Verify the additions
SELECT 'Fields Added Summary:' as status,
       COUNT(CASE WHEN af.field_name = 'ACTVT' THEN 1 END) as actvt_fields,
       COUNT(CASE WHEN af.field_name = 'BUKRS' THEN 1 END) as bukrs_fields,
       COUNT(CASE WHEN af.field_name = 'KOSTL' THEN 1 END) as kostl_fields,
       COUNT(CASE WHEN af.field_name = 'WERKS' THEN 1 END) as werks_fields
FROM authorization_fields af;