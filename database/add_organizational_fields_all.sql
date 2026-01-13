-- Add Organizational Fields to All Authorization Objects
-- =====================================================

-- Add COMP_CODE to ALL objects that don't have it
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values, is_required)
SELECT 
    ao.id,
    'COMP_CODE',
    'Company Code',
    ARRAY['1000', '2000', '3000', '*'],
    true
FROM authorization_objects ao
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id 
    AND af.field_name = 'COMP_CODE'
);

-- Add PLANT to ALL objects that don't have it
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values, is_required)
SELECT 
    ao.id,
    'PLANT',
    'Plant/Location',
    ARRAY['P001', 'P002', 'P003', 'P004', '*'],
    false
FROM authorization_objects ao
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id 
    AND af.field_name = 'PLANT'
);

-- Add DEPT to ALL objects that don't have it
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values, is_required)
SELECT 
    ao.id,
    'DEPT',
    'Department',
    ARRAY['ADMIN', 'FIELD', 'OFFICE', '*'],
    false
FROM authorization_objects ao
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id 
    AND af.field_name = 'DEPT'
);

-- Add ACTION to objects that have no fields at all
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values, is_required)
SELECT 
    ao.id,
    'ACTION',
    'Action Type',
    ARRAY['CREATE', 'MODIFY', 'DELETE', 'REVIEW', 'EXECUTE', 'APPROVE'],
    true
FROM authorization_objects ao
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id
);

-- Verify organizational fields coverage
SELECT 'Organizational Fields Coverage:' as status,
       COUNT(DISTINCT CASE WHEN af.field_name = 'COMP_CODE' THEN ao.id END) as objects_with_comp_code,
       COUNT(DISTINCT CASE WHEN af.field_name = 'PLANT' THEN ao.id END) as objects_with_plant,
       COUNT(DISTINCT CASE WHEN af.field_name = 'DEPT' THEN ao.id END) as objects_with_dept,
       COUNT(DISTINCT ao.id) as total_objects
FROM authorization_objects ao
LEFT JOIN authorization_fields af ON ao.id = af.auth_object_id;