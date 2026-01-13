-- Add Organizational Unit Fields to WBS, Activities, and Tasks Authorization Objects
-- =================================================================================

-- Add Company Code and Project Category to WBS objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'COMP_CODE', 'Company Code', ARRAY['1000', '2000', '3000', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('PS_WBS_CREATE', 'PS_WBS_MODIFY')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'COMP_CODE'
);

INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'PROJ_CAT', 'Project Category', ARRAY['residential', 'commercial', 'infrastructure', 'industrial', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('PS_WBS_CREATE', 'PS_WBS_MODIFY')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'PROJ_CAT'
);

-- Add Company Code and Project Category to Task objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'COMP_CODE', 'Company Code', ARRAY['1000', '2000', '3000', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('PS_TSK_MANAGE', 'PP_TSK_ASSIGN', 'PP_TSK_UPDATE', 'PP_TSK_APPROVE')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'COMP_CODE'
);

INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'PROJ_CAT', 'Project Category', ARRAY['residential', 'commercial', 'infrastructure', 'industrial', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('PS_TSK_MANAGE', 'PP_TSK_ASSIGN', 'PP_TSK_UPDATE', 'PP_TSK_APPROVE')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'PROJ_CAT'
);

-- Add Company Code, Project Category, and Construction Site to Activity objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'COMP_CODE', 'Company Code', ARRAY['1000', '2000', '3000', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('PP_ACT_SCHEDULE', 'PP_ACT_EXECUTE', 'PP_ACT_APPROVE')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'COMP_CODE'
);

INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'PROJ_CAT', 'Project Category', ARRAY['residential', 'commercial', 'infrastructure', 'industrial', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('PP_ACT_SCHEDULE', 'PP_ACT_EXECUTE', 'PP_ACT_APPROVE')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'PROJ_CAT'
);

INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'CONST_SITE', 'Construction Site', ARRAY['SITE01', 'SITE02', 'SITE03', 'SITE04', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('PP_ACT_SCHEDULE', 'PP_ACT_EXECUTE', 'PP_ACT_APPROVE')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'CONST_SITE'
);

-- Add Department field to Activity and Task objects (for resource assignment)
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'DEPT', 'Department', ARRAY['ADMIN', 'FIELD', 'OFFICE', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('PP_ACT_SCHEDULE', 'PP_ACT_EXECUTE', 'PS_TSK_MANAGE', 'PP_TSK_ASSIGN')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'DEPT'
);

-- Update existing authorizations to include new fields with full access
UPDATE user_authorizations 
SET field_values = field_values || '{"COMP_CODE": ["*"], "PROJ_CAT": ["*"], "CONST_SITE": ["*"], "DEPT": ["*"]}'::jsonb
WHERE auth_object_id IN (
    SELECT id FROM authorization_objects 
    WHERE object_name IN ('PS_WBS_CREATE', 'PS_WBS_MODIFY', 'PS_TSK_MANAGE', 'PP_TSK_ASSIGN', 'PP_TSK_UPDATE', 'PP_TSK_APPROVE', 'PP_ACT_SCHEDULE', 'PP_ACT_EXECUTE', 'PP_ACT_APPROVE')
);

UPDATE role_authorization_mapping 
SET field_values = field_values || '{"COMP_CODE": ["*"], "PROJ_CAT": ["*"], "CONST_SITE": ["*"], "DEPT": ["*"]}'::jsonb
WHERE auth_object_name IN ('PS_WBS_CREATE', 'PS_WBS_MODIFY', 'PS_TSK_MANAGE', 'PP_TSK_ASSIGN', 'PP_TSK_UPDATE', 'PP_TSK_APPROVE', 'PP_ACT_SCHEDULE', 'PP_ACT_EXECUTE', 'PP_ACT_APPROVE');

-- Verify the new fields for WBS, Activities, and Tasks
SELECT 'WBS/ACTIVITIES/TASKS ORG FIELDS' as status, 
       ao.object_name, 
       af.field_name, 
       af.field_description,
       array_length(af.field_values, 1) as value_count
FROM authorization_objects ao
JOIN authorization_fields af ON ao.id = af.auth_object_id
WHERE ao.object_name IN ('PS_WBS_CREATE', 'PS_WBS_MODIFY', 'PS_TSK_MANAGE', 'PP_TSK_ASSIGN', 'PP_TSK_UPDATE', 'PP_TSK_APPROVE', 'PP_ACT_SCHEDULE', 'PP_ACT_EXECUTE', 'PP_ACT_APPROVE')
AND af.field_name IN ('COMP_CODE', 'PROJ_CAT', 'CONST_SITE', 'DEPT')
ORDER BY ao.object_name, af.field_name;