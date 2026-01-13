-- Fix Tasks tile to use correct PS_ authorization object
-- ====================================================

-- Update the Tasks tile to use PS_TSK_MANAGE instead of PP_TSK_ASSIGN
UPDATE tiles 
SET auth_object = 'PS_TSK_MANAGE',
    construction_action = 'MANAGE'
WHERE title = 'Tasks' 
AND tile_category = 'Project Management'
AND auth_object = 'PP_TSK_ASSIGN';

-- Create PS_TSK_MANAGE authorization object if it doesn't exist
INSERT INTO authorization_objects (object_name, description, module) VALUES
('PS_TSK_MANAGE', 'Project Task Management Authorization', 'project_system')
ON CONFLICT (object_name) DO NOTHING;

-- Add authorization fields for PS_TSK_MANAGE
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'ACTION', 'Task Management Actions', ARRAY['MANAGE', 'INITIATE', 'MODIFY', 'ASSIGN', 'UPDATE', 'REVIEW']
FROM authorization_objects ao
WHERE ao.object_name = 'PS_TSK_MANAGE'
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'ACTION'
);

-- Add PS_TSK_MANAGE authorization to admin user
INSERT INTO user_authorizations (user_id, auth_object_id, field_values, valid_from)
SELECT 
    '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
    ao.id,
    '{"ACTION": ["MANAGE", "INITIATE", "MODIFY", "ASSIGN", "UPDATE", "REVIEW"]}'::jsonb,
    CURRENT_DATE
FROM authorization_objects ao
WHERE ao.object_name = 'PS_TSK_MANAGE'
ON CONFLICT (user_id, auth_object_id) DO NOTHING;

-- Verify the fix
SELECT 
    'TASKS TILE FIXED' as status,
    t.title,
    t.auth_object,
    t.construction_action,
    check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) as has_access
FROM tiles t
WHERE t.title = 'Tasks' AND t.tile_category = 'Project Management';