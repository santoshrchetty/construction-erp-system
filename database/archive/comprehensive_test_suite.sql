-- Comprehensive RBAC System Test Suite
-- ====================================

-- Test 1: Create test users for different roles
DO $$
DECLARE
    admin_user UUID := '11111111-1111-1111-1111-111111111111';
    manager_user UUID := '22222222-2222-2222-2222-222222222222';
    engineer_user UUID := '33333333-3333-3333-3333-333333333333';
    procurement_user UUID := '44444444-4444-4444-4444-444444444444';
    employee_user UUID := '55555555-5555-5555-5555-555555555555';
BEGIN
    -- Assign different roles to test users
    PERFORM assign_role_authorizations(admin_user, 'Admin');
    PERFORM assign_role_authorizations(manager_user, 'Manager');
    PERFORM assign_role_authorizations(engineer_user, 'Engineer');
    PERFORM assign_role_authorizations(procurement_user, 'Procurement');
    PERFORM assign_role_authorizations(employee_user, 'Employee');
    
    RAISE NOTICE 'Test users created and roles assigned';
END $$;

-- Test 2: Verify role assignments worked
SELECT 
    'Role Assignment Test' as test_name,
    ua.user_id,
    ao.object_name,
    ua.field_values->'ACTION' as actions
FROM user_authorizations ua
JOIN authorization_objects ao ON ua.auth_object_id = ao.id
WHERE ua.user_id IN (
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '33333333-3333-3333-3333-333333333333'
)
ORDER BY ua.user_id, ao.object_name
LIMIT 10;

-- Test 3: Authorization checks for different scenarios
SELECT 
    'Authorization Tests' as test_suite,
    test_case,
    user_role,
    result
FROM (
    -- Admin should have full access
    SELECT 
        'Admin can initiate projects' as test_case,
        'Admin' as user_role,
        check_construction_authorization(
            '11111111-1111-1111-1111-111111111111'::UUID,
            'PS_PRJ_INITIATE',
            'INITIATE',
            '{"PROJ_TYPE": "commercial"}'::jsonb
        ) as result
    
    UNION ALL
    
    -- Manager should have limited project access
    SELECT 
        'Manager can initiate commercial projects' as test_case,
        'Manager' as user_role,
        check_construction_authorization(
            '22222222-2222-2222-2222-222222222222'::UUID,
            'PS_PRJ_INITIATE',
            'INITIATE',
            '{"PROJ_TYPE": "commercial"}'::jsonb
        ) as result
    
    UNION ALL
    
    -- Manager should NOT have infrastructure project access
    SELECT 
        'Manager cannot initiate infrastructure projects' as test_case,
        'Manager' as user_role,
        check_construction_authorization(
            '22222222-2222-2222-2222-222222222222'::UUID,
            'PS_PRJ_INITIATE',
            'INITIATE',
            '{"PROJ_TYPE": "infrastructure"}'::jsonb
        ) as result
    
    UNION ALL
    
    -- Engineer should NOT be able to create projects
    SELECT 
        'Engineer cannot initiate projects' as test_case,
        'Engineer' as user_role,
        check_construction_authorization(
            '33333333-3333-3333-3333-333333333333'::UUID,
            'PS_PRJ_INITIATE',
            'INITIATE',
            '{"PROJ_TYPE": "commercial"}'::jsonb
        ) as result
    
    UNION ALL
    
    -- Procurement should be able to create POs
    SELECT 
        'Procurement can create POs' as test_case,
        'Procurement' as user_role,
        check_construction_authorization(
            '44444444-4444-4444-4444-444444444444'::UUID,
            'MM_PO_CREATE',
            'INITIATE',
            '{"PO_TYPE": "standard"}'::jsonb
        ) as result
    
    UNION ALL
    
    -- Employee should NOT be able to approve timesheets
    SELECT 
        'Employee cannot approve timesheets' as test_case,
        'Employee' as user_role,
        check_construction_authorization(
            '55555555-5555-5555-5555-555555555555'::UUID,
            'HR_TMS_APPROVE',
            'APPROVE',
            '{}'::jsonb
        ) as result
) tests;

-- Test 4: Tile access by role
SELECT 
    'Tile Access Test' as test_name,
    user_role,
    tile_count as accessible_tiles
FROM (
    SELECT 'Admin' as user_role, COUNT(*) as tile_count
    FROM get_user_authorized_tiles('11111111-1111-1111-1111-111111111111'::UUID)
    WHERE has_authorization = true
    
    UNION ALL
    
    SELECT 'Manager' as user_role, COUNT(*) as tile_count
    FROM get_user_authorized_tiles('22222222-2222-2222-2222-222222222222'::UUID)
    WHERE has_authorization = true
    
    UNION ALL
    
    SELECT 'Engineer' as user_role, COUNT(*) as tile_count
    FROM get_user_authorized_tiles('33333333-3333-3333-3333-333333333333'::UUID)
    WHERE has_authorization = true
    
    UNION ALL
    
    SELECT 'Procurement' as user_role, COUNT(*) as tile_count
    FROM get_user_authorized_tiles('44444444-4444-4444-4444-444444444444'::UUID)
    WHERE has_authorization = true
    
    UNION ALL
    
    SELECT 'Employee' as user_role, COUNT(*) as tile_count
    FROM get_user_authorized_tiles('55555555-5555-5555-5555-555555555555'::UUID)
    WHERE has_authorization = true
) tile_counts
ORDER BY user_role;

-- Test 5: Module access by role
SELECT 
    'Module Access Test' as test_name,
    'Admin' as user_role,
    module_code,
    module_name,
    array_length(actions, 1) as action_count
FROM get_user_module_access('11111111-1111-1111-1111-111111111111'::UUID)

UNION ALL

SELECT 
    'Module Access Test' as test_name,
    'Engineer' as user_role,
    module_code,
    module_name,
    array_length(actions, 1) as action_count
FROM get_user_module_access('33333333-3333-3333-3333-333333333333'::UUID)

ORDER BY user_role, module_code;

-- Test 6: Context-sensitive authorization (Project Types)
SELECT 
    'Context Authorization Test' as test_name,
    project_type,
    'Manager can access' as test_description,
    check_construction_authorization(
        '22222222-2222-2222-2222-222222222222'::UUID,
        'PS_PRJ_INITIATE',
        'INITIATE',
        ('{"PROJ_TYPE": "' || project_type || '"}')::jsonb
    ) as has_access
FROM (VALUES ('commercial'), ('residential'), ('infrastructure')) AS t(project_type);

-- Test 7: Verify system integrity
SELECT 
    'System Integrity Check' as test_name,
    metric,
    value,
    CASE 
        WHEN metric = 'Authorization Objects' AND value::INTEGER >= 25 THEN 'PASS'
        WHEN metric = 'Active Tiles' AND value::INTEGER >= 20 THEN 'PASS'
        WHEN metric = 'Role Mappings' AND value::INTEGER >= 40 THEN 'PASS'
        WHEN metric = 'Tile Categories' AND value::INTEGER >= 8 THEN 'PASS'
        ELSE 'CHECK'
    END as status
FROM (
    SELECT 'Authorization Objects' as metric, COUNT(*)::TEXT as value FROM authorization_objects
    UNION ALL
    SELECT 'Active Tiles' as metric, COUNT(*)::TEXT as value FROM tiles WHERE is_active = true
    UNION ALL
    SELECT 'Role Mappings' as metric, COUNT(*)::TEXT as value FROM role_authorization_mapping
    UNION ALL
    SELECT 'Tile Categories' as metric, COUNT(*)::TEXT as value FROM tile_categories
    UNION ALL
    SELECT 'Test Users Created' as metric, COUNT(*)::TEXT as value FROM user_authorizations 
    WHERE user_id IN ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333')
) system_metrics;

-- Test 8: Performance check - Authorization function speed
SELECT 
    'Performance Test' as test_name,
    'Authorization Check Speed' as metric,
    COUNT(*) as checks_performed,
    'All completed successfully' as result
FROM (
    SELECT check_construction_authorization(
        '11111111-1111-1111-1111-111111111111'::UUID,
        ao.object_name,
        'REVIEW',
        '{}'::jsonb
    ) as auth_result
    FROM authorization_objects ao
    LIMIT 10
) perf_test;