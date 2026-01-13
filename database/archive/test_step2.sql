-- Step 2 Test Script - Verify Permission Mapping
-- ==============================================

-- Test the role assignment function
-- Replace with actual user ID from your system
DO $$
DECLARE
    test_user_id UUID := '00000000-0000-0000-0000-000000000001';
BEGIN
    -- Test Admin role assignment
    PERFORM assign_role_authorizations(test_user_id, 'Admin');
    
    RAISE NOTICE 'Admin role assigned to test user';
END $$;

-- Verify role mappings were created
SELECT 
    role_name,
    COUNT(*) as auth_objects_count
FROM role_authorization_mapping 
GROUP BY role_name
ORDER BY role_name;

-- Test authorization checks for different roles
SELECT 
    'Admin can create projects' as test_case,
    check_sap_authorization(
        '00000000-0000-0000-0000-000000000001'::UUID,
        'F_PROJ_CRE',
        '01',
        '{"PROJ_TYPE": "commercial"}'::jsonb
    ) as result
UNION ALL
SELECT 
    'Engineer cannot create projects' as test_case,
    check_sap_authorization(
        '00000000-0000-0000-0000-000000000002'::UUID,
        'F_PROJ_CRE', 
        '01',
        '{"PROJ_TYPE": "commercial"}'::jsonb
    ) as result;

-- Show sample authorization assignments
SELECT 
    ua.user_id,
    ao.object_name,
    ao.description,
    ua.field_values
FROM user_authorizations ua
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
LIMIT 10;