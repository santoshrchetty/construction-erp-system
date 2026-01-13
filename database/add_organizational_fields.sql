-- Add Missing Organizational Authorization Fields
-- =============================================

-- Based on available data:
-- Company Codes: C001, C002, C003, C004
-- Cost Centers: CC-ADMIN, CC-MAINT, CC-PROJ01, CC-PROJ02, CC-SALES, CC-PROJ03
-- Plants: P001, P002, P003, P004
-- Purchasing Orgs: PO01, PO02, PO03, PO04

-- Add BUKRS (Company Code) to all objects that don't have it
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

-- Add KOSTL (Cost Center) to all objects that don't have it
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

-- Add WERKS (Plant) to relevant objects (materials, inventory, procurement)
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values, is_required)
SELECT 
    ao.id,
    'WERKS',
    'Plant',
    ARRAY['P001', 'P002', 'P003', 'P004', '*'],
    false
FROM authorization_objects ao
WHERE ao.module IN ('materials', 'inventory', 'procurement', 'planning')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id 
    AND af.field_name = 'WERKS'
);

-- Add EKORG (Purchasing Organization) to procurement objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values, is_required)
SELECT 
    ao.id,
    'EKORG',
    'Purchasing Organization',
    ARRAY['PO01', 'PO02', 'PO03', 'PO04', '*'],
    false
FROM authorization_objects ao
WHERE ao.module = 'procurement'
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id 
    AND af.field_name = 'EKORG'
);

-- Update role assignments to include organizational fields
UPDATE role_authorization_objects 
SET field_values = field_values || '{"BUKRS": ["*"], "KOSTL": ["*"]}'::jsonb
WHERE role_id = (SELECT id FROM roles WHERE name = 'Admin')
AND NOT (field_values ? 'BUKRS');

-- Verify additions
SELECT 'Organizational Fields Added:' as status,
       COUNT(*) as total_fields
FROM authorization_fields 
WHERE field_name IN ('BUKRS', 'KOSTL', 'WERKS', 'EKORG');