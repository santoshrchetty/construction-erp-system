-- Add Missing Organizational Fields Using Existing Naming Conventions
-- ===================================================================

-- Based on existing patterns:
-- COMP_CODE (not BUKRS) - Company codes: 1000, 2000, 3000
-- COST_CTR (not KOSTL) - Cost centers: CC001-CC005  
-- CONST_SITE - Construction sites: SITE01-SITE04
-- STOR_LOC - Storage locations: YARD01, YARD02, OFFICE, MAIN, TEMP
-- PROC_UNIT - Procurement units: PU01-PU03
-- DEPT - Departments: ADMIN, FIELD, OFFICE

-- Add COMP_CODE to objects missing it (34+ objects have no fields)
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
)
AND ao.object_name IN (
    'QM_BOQ_MODIFY', 'QM_BOQ_REVIEW', 'CO_ALLOCAT', 'CO_CST_ELE', 'CO_PRJ_BUD', 'CO_PRJ_DIS', 
    'CO_PROFITA', 'CO_SETTLEM', 'CO_VARIANC', 'DM_DRAW', 'DM_RFI', 'FI_CASHFLO', 'FI_DOC_DIS', 
    'FI_DOC_REV', 'FI_GL_DISP', 'FI_GL_POST', 'FI_PER_CLO', 'FI_REPORTS', 'FI_INV_PROCESS',
    'HR_EMP', 'HR_PAY', 'MM_MAT_BULK_UPLOAD', 'MM_MAT_CREATE', 'MM_MAT_DISPLAY', 'MM_MAT_RESERVE',
    'MM_STK_CHECK', 'MM_STK_OVERVIEW', 'PP_MRP_MONITOR', 'PP_PPR_DISPLAY', 'QM_INSPECT', 'QM_NCR',
    'SF_INC', 'SF_PERMIT'
);

-- Add ACTION field to objects missing it (using existing pattern)
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
    AND af.field_name = 'ACTION'
)
AND ao.object_name IN (
    'QM_BOQ_MODIFY', 'QM_BOQ_REVIEW', 'CO_ALLOCAT', 'CO_CST_ELE', 'CO_PRJ_BUD', 'CO_PRJ_DIS', 
    'CO_PROFITA', 'CO_SETTLEM', 'CO_VARIANC', 'DM_DRAW', 'DM_RFI', 'FI_CASHFLO', 'FI_DOC_DIS', 
    'FI_DOC_REV', 'FI_GL_DISP', 'FI_GL_POST', 'FI_PER_CLO', 'FI_REPORTS', 'FI_INV_PROCESS',
    'HR_EMP', 'HR_PAY', 'MM_MAT_BULK_UPLOAD', 'MM_MAT_CREATE', 'MM_MAT_DISPLAY', 'MM_MAT_RESERVE',
    'MM_STK_CHECK', 'MM_STK_OVERVIEW', 'PP_MRP_MONITOR', 'PP_PPR_DISPLAY', 'QM_INSPECT', 'QM_NCR',
    'SF_INC', 'SF_PERMIT'
);

-- Add CONST_SITE to construction-related objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values, is_required)
SELECT 
    ao.id,
    'CONST_SITE',
    'Construction Site',
    ARRAY['SITE01', 'SITE02', 'SITE03', 'SITE04', '*'],
    false
FROM authorization_objects ao
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id 
    AND af.field_name = 'CONST_SITE'
)
AND ao.module IN ('materials', 'inventory', 'quality', 'safety', 'projects');

-- Verify additions
SELECT 'Fields Added:' as status,
       COUNT(CASE WHEN af.field_name = 'COMP_CODE' THEN 1 END) as comp_code_fields,
       COUNT(CASE WHEN af.field_name = 'ACTION' THEN 1 END) as action_fields,
       COUNT(CASE WHEN af.field_name = 'CONST_SITE' THEN 1 END) as const_site_fields
FROM authorization_fields af;