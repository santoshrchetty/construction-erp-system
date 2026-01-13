-- Step 3 Test Script - Construction Module Framework
-- =================================================

-- Test role assignment with new construction objects
DO $$
DECLARE
    test_user_id UUID := '00000000-0000-0000-0000-000000000001';
BEGIN
    -- Assign Admin role with construction objects
    PERFORM assign_role_authorizations(test_user_id, 'Admin');
    RAISE NOTICE 'Admin role assigned with construction objects';
END $$;

-- Verify construction authorization objects were created
SELECT 
    LEFT(object_name, 2) as module_code,
    COUNT(*) as auth_objects_count
FROM authorization_objects 
GROUP BY LEFT(object_name, 2)
ORDER BY module_code;

-- Test construction authorization checks
SELECT 
    'Admin can initiate projects' as test_case,
    check_construction_authorization(
        '00000000-0000-0000-0000-000000000001'::UUID,
        'PS_PRJ_INITIATE',
        'INITIATE',
        '{"PROJ_TYPE": "commercial"}'::jsonb
    ) as result
UNION ALL
SELECT 
    'Admin can approve POs' as test_case,
    check_construction_authorization(
        '00000000-0000-0000-0000-000000000001'::UUID,
        'MM_PO_APPROVE',
        'APPROVE',
        '{"PO_TYPE": "standard"}'::jsonb
    ) as result
UNION ALL
SELECT 
    'Employee cannot initiate projects' as test_case,
    check_construction_authorization(
        '00000000-0000-0000-0000-000000000002'::UUID,
        'PS_PRJ_INITIATE',
        'INITIATE',
        '{"PROJ_TYPE": "commercial"}'::jsonb
    ) as result;

-- Show user's module access summary
SELECT * FROM get_user_module_access('00000000-0000-0000-0000-000000000001'::UUID);

-- Show sample construction authorization assignments
SELECT 
    ua.user_id,
    ao.object_name,
    ao.description,
    ua.field_values->'ACTION' as allowed_actions,
    CASE 
        WHEN ua.field_values ? 'PROJ_TYPE' THEN ua.field_values->'PROJ_TYPE'
        WHEN ua.field_values ? 'PO_TYPE' THEN ua.field_values->'PO_TYPE'
        ELSE NULL
    END as context_values
FROM user_authorizations ua
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ua.user_id = '00000000-0000-0000-0000-000000000001'::UUID
ORDER BY ao.object_name
LIMIT 10;

-- Verify role mappings by module
SELECT 
    role_name,
    LEFT(auth_object_name, 2) as module_code,
    COUNT(*) as objects_count
FROM role_authorization_mapping
GROUP BY role_name, LEFT(auth_object_name, 2)
ORDER BY role_name, module_code;