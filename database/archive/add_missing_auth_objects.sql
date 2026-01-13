-- Check Missing Authorization Objects
-- ===================================

-- Check which auth objects exist
SELECT 'EXISTING AUTH OBJECTS' as status, object_name FROM authorization_objects 
WHERE object_name IN ('MM_MAT_MASTER', 'MM_VEN_MANAGE', 'WM_STK_REVIEW', 'WM_STK_TRANSFER', 'WM_STR_MANAGE')
ORDER BY object_name;

-- Add missing authorization objects if they don't exist
INSERT INTO authorization_objects (object_name, description, module) 
SELECT * FROM (VALUES
    ('MM_MAT_MASTER', 'Material Master Maintenance', 'materials'),
    ('MM_VEN_MANAGE', 'Vendor Management', 'procurement'),
    ('WM_STK_REVIEW', 'Stock Review', 'inventory'),
    ('WM_STK_TRANSFER', 'Stock Transfer', 'inventory'),
    ('WM_STR_MANAGE', 'Store Management', 'stores')
) AS new_objects(object_name, description, module)
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_objects ao 
    WHERE ao.object_name = new_objects.object_name
);

-- Add authorization fields for new objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'ACTION', 'Construction Action', ARRAY['MODIFY', 'REVIEW', 'EXECUTE']
FROM authorization_objects ao
WHERE ao.object_name IN ('MM_MAT_MASTER', 'MM_VEN_MANAGE', 'WM_STK_REVIEW', 'WM_STK_TRANSFER', 'WM_STR_MANAGE')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'ACTION'
);

-- Now add role mappings
INSERT INTO role_authorization_mapping (role_name, auth_object_name, field_values) 
SELECT * FROM (VALUES
    ('Admin', 'MM_MAT_MASTER', '{"ACTION": ["MODIFY"]}'::jsonb),
    ('Admin', 'MM_VEN_MANAGE', '{"ACTION": ["MODIFY"]}'::jsonb),
    ('Admin', 'WM_STK_REVIEW', '{"ACTION": ["REVIEW"]}'::jsonb),
    ('Admin', 'WM_STK_TRANSFER', '{"ACTION": ["EXECUTE"]}'::jsonb),
    ('Admin', 'WM_STR_MANAGE', '{"ACTION": ["MODIFY"]}'::jsonb)
) AS new_mappings(role_name, auth_object_name, field_values)
WHERE NOT EXISTS (
    SELECT 1 FROM role_authorization_mapping ram 
    WHERE ram.role_name = new_mappings.role_name 
    AND ram.auth_object_name = new_mappings.auth_object_name
);

-- Re-assign Admin role
DO $$
BEGIN
    PERFORM assign_role_authorizations('70f8baa8-27b8-4061-84c4-6dd027d6b89f', 'Admin');
END $$;