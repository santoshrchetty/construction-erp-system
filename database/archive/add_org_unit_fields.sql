-- Add Organizational Unit Fields to Authorization Objects
-- ======================================================

-- Add Company Code field to relevant authorization objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'COMP_CODE', 'Company Code', ARRAY['1000', '2000', '3000', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('PS_PRJ_INITIATE', 'PS_PRJ_MODIFY', 'MM_PO_CREATE', 'MM_PO_APPROVE', 'FI_CST_REVIEW', 'CO_BDG_MODIFY')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'COMP_CODE'
);

-- Add Site field to materials and warehouse objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'CONST_SITE', 'Construction Site', ARRAY['SITE01', 'SITE02', 'SITE03', 'SITE04', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('MM_MAT_MASTER', 'MM_GRN_EXECUTE', 'WM_STK_REVIEW', 'WM_STK_TRANSFER', 'WM_STR_MANAGE')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'CONST_SITE'
);

-- Add Location field to warehouse objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'STOR_LOC', 'Storage Location', ARRAY['YARD01', 'YARD02', 'OFFICE', 'MAIN', 'TEMP', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('WM_STK_REVIEW', 'WM_STK_TRANSFER', 'WM_STR_MANAGE', 'MM_GRN_EXECUTE')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'STOR_LOC'
);

-- Add Project Category field to project objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'PROJ_CAT', 'Project Category', ARRAY['residential', 'commercial', 'infrastructure', 'industrial', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('PS_PRJ_INITIATE', 'PS_PRJ_MODIFY', 'PS_PRJ_REVIEW', 'PS_WBS_CREATE')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'PROJ_CAT'
);

-- Add Cost Center field to financial objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'COST_CTR', 'Cost Center', ARRAY['CC001', 'CC002', 'CC003', 'CC004', 'CC005', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('FI_CST_REVIEW', 'CO_BDG_MODIFY', 'CO_CTC_ANALYZE', 'HR_TMS_APPROVE')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'COST_CTR'
);

-- Add Procurement Unit field to procurement objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'PROC_UNIT', 'Procurement Unit', ARRAY['PU01', 'PU02', 'PU03', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('MM_PO_CREATE', 'MM_PO_APPROVE', 'MM_PO_MODIFY', 'MM_VEN_MANAGE')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'PROC_UNIT'
);

-- Add Department field to HR objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'DEPT', 'Department', ARRAY['ADMIN', 'FIELD', 'OFFICE', '*']
FROM authorization_objects ao
WHERE ao.object_name IN ('HR_TMS_EXECUTE', 'HR_TMS_APPROVE', 'HR_EMP_MANAGE')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'DEPT'
);

-- Update ALL existing user authorizations to include org unit fields with full access
UPDATE user_authorizations 
SET field_values = field_values || '{"COMP_CODE": ["*"], "CONST_SITE": ["*"], "STOR_LOC": ["*"], "PROJ_CAT": ["*"], "COST_CTR": ["*"], "PROC_UNIT": ["*"], "DEPT": ["*"]}'::jsonb;

-- Update ALL existing role authorization mappings to include org unit fields with full access
UPDATE role_authorization_mapping 
SET field_values = field_values || '{"COMP_CODE": ["*"], "CONST_SITE": ["*"], "STOR_LOC": ["*"], "PROJ_CAT": ["*"], "COST_CTR": ["*"], "PROC_UNIT": ["*"], "DEPT": ["*"]}'::jsonb;

-- Verify the new fields
SELECT 'NEW ORG UNIT FIELDS' as status, 
       ao.object_name, 
       af.field_name, 
       af.field_description,
       array_length(af.field_values, 1) as value_count
FROM authorization_objects ao
JOIN authorization_fields af ON ao.id = af.auth_object_id
WHERE af.field_name IN ('COMP_CODE', 'CONST_SITE', 'STOR_LOC', 'PROJ_CAT', 'COST_CTR', 'PROC_UNIT', 'DEPT')
ORDER BY ao.object_name, af.field_name;