-- Add missing admin authorizations
-- =================================

-- Add missing authorizations for admin user
INSERT INTO user_authorizations (user_id, auth_object_id, field_values, valid_from)
SELECT 
    '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
    ao.id,
    CASE ao.object_name
        WHEN 'QM_BOQ_REVIEW' THEN '{"ACTION": ["REVIEW"]}'::jsonb
        WHEN 'HR_EMP_MANAGE' THEN '{"ACTION": ["MODIFY", "CREATE", "DELETE"]}'::jsonb
        WHEN 'CO_CST_ALLOCATE' THEN '{"ACTION": ["MODIFY", "EXECUTE"]}'::jsonb
        WHEN 'CO_CTC_ANALYZE' THEN '{"ACTION": ["ANALYZE", "REVIEW"]}'::jsonb
        WHEN 'FI_CST_REVIEW' THEN '{"ACTION": ["REVIEW"]}'::jsonb
        WHEN 'FI_INV_PROCESS' THEN '{"ACTION": ["PROCESS", "REVIEW"]}'::jsonb
        WHEN 'MM_PO_MODIFY' THEN '{"ACTION": ["MODIFY", "REVIEW"]}'::jsonb
        WHEN 'PS_WBS_CREATE' THEN '{"ACTION": ["INITIATE", "CREATE", "MODIFY"]}'::jsonb
        WHEN 'PS_WBS_MODIFY' THEN '{"ACTION": ["MODIFY", "REVIEW"]}'::jsonb
        WHEN 'QM_QC_EXECUTE' THEN '{"ACTION": ["EXECUTE", "REVIEW"]}'::jsonb
        WHEN 'PP_TSK_ASSIGN' THEN '{"ACTION": ["ASSIGN", "MODIFY"]}'::jsonb
        WHEN 'PP_TSK_UPDATE' THEN '{"ACTION": ["UPDATE", "EXECUTE"]}'::jsonb
        WHEN 'HR_TMS_EXECUTE' THEN '{"ACTION": ["EXECUTE", "REVIEW"]}'::jsonb
        ELSE '{"ACTION": ["EXECUTE"]}'::jsonb
    END,
    CURRENT_DATE
FROM authorization_objects ao
WHERE ao.object_name IN (
    'QM_BOQ_REVIEW', 'HR_EMP_MANAGE', 'CO_CST_ALLOCATE', 'CO_CTC_ANALYZE',
    'FI_CST_REVIEW', 'FI_INV_PROCESS', 'MM_PO_MODIFY', 'PS_WBS_CREATE',
    'PS_WBS_MODIFY', 'QM_QC_EXECUTE', 'PP_TSK_ASSIGN', 'PP_TSK_UPDATE',
    'HR_TMS_EXECUTE'
)
ON CONFLICT (user_id, auth_object_id) DO NOTHING;

-- Verify all tiles are now authorized
SELECT 
    'ADMIN ACCESS VERIFICATION' as status,
    t.tile_category,
    COUNT(*) as total_tiles,
    COUNT(CASE WHEN check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) = true THEN 1 END) as authorized_tiles
FROM tiles t
GROUP BY t.tile_category
ORDER BY t.tile_category;