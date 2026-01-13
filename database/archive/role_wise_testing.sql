-- Role-Wise Testing Script
-- ========================

-- Step 1: Create test users for each role
DO $$
BEGIN
    -- Clean up existing test users first
    DELETE FROM user_authorizations WHERE user_id IN (
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', -- Admin
        'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', -- Manager  
        'cccccccc-cccc-cccc-cccc-cccccccccccc', -- Engineer
        'dddddddd-dddd-dddd-dddd-dddddddddddd', -- Procurement
        'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee', -- Storekeeper
        'ffffffff-ffff-ffff-ffff-ffffffffffff', -- Finance
        'gggggggg-gggg-gggg-gggg-gggggggggggg', -- HR
        'hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh'  -- Employee
    );

    -- Assign roles to test users
    PERFORM assign_role_authorizations('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::UUID, 'Admin');
    PERFORM assign_role_authorizations('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::UUID, 'Manager');
    PERFORM assign_role_authorizations('cccccccc-cccc-cccc-cccc-cccccccccccc'::UUID, 'Engineer');
    PERFORM assign_role_authorizations('dddddddd-dddd-dddd-dddd-dddddddddddd'::UUID, 'Procurement');
    PERFORM assign_role_authorizations('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'::UUID, 'Storekeeper');
    PERFORM assign_role_authorizations('ffffffff-ffff-ffff-ffff-ffffffffffff'::UUID, 'Finance');
    PERFORM assign_role_authorizations('gggggggg-gggg-gggg-gggg-gggggggggggg'::UUID, 'HR');
    PERFORM assign_role_authorizations('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh'::UUID, 'Employee');
    
    RAISE NOTICE 'All 8 role test users created successfully';
END $$;

-- Step 2: Test each role's tile access
SELECT 
    'ROLE-WISE TILE ACCESS' as test_category,
    role_name,
    accessible_tiles,
    CASE 
        WHEN role_name = 'Admin' AND accessible_tiles >= 15 THEN '✅ PASS'
        WHEN role_name = 'Manager' AND accessible_tiles >= 8 THEN '✅ PASS'
        WHEN role_name = 'Engineer' AND accessible_tiles >= 5 THEN '✅ PASS'
        WHEN role_name = 'Procurement' AND accessible_tiles >= 5 THEN '✅ PASS'
        WHEN role_name = 'Storekeeper' AND accessible_tiles >= 4 THEN '✅ PASS'
        WHEN role_name = 'Finance' AND accessible_tiles >= 5 THEN '✅ PASS'
        WHEN role_name = 'HR' AND accessible_tiles >= 3 THEN '✅ PASS'
        WHEN role_name = 'Employee' AND accessible_tiles >= 3 THEN '✅ PASS'
        ELSE '❌ CHECK'
    END as status
FROM (
    SELECT 'Admin' as role_name, COUNT(*) as accessible_tiles
    FROM get_user_authorized_tiles('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::UUID) WHERE has_authorization = true
    UNION ALL
    SELECT 'Manager' as role_name, COUNT(*) as accessible_tiles  
    FROM get_user_authorized_tiles('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::UUID) WHERE has_authorization = true
    UNION ALL
    SELECT 'Engineer' as role_name, COUNT(*) as accessible_tiles
    FROM get_user_authorized_tiles('cccccccc-cccc-cccc-cccc-cccccccccccc'::UUID) WHERE has_authorization = true
    UNION ALL
    SELECT 'Procurement' as role_name, COUNT(*) as accessible_tiles
    FROM get_user_authorized_tiles('dddddddd-dddd-dddd-dddd-dddddddddddd'::UUID) WHERE has_authorization = true
    UNION ALL
    SELECT 'Storekeeper' as role_name, COUNT(*) as accessible_tiles
    FROM get_user_authorized_tiles('eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee'::UUID) WHERE has_authorization = true
    UNION ALL
    SELECT 'Finance' as role_name, COUNT(*) as accessible_tiles
    FROM get_user_authorized_tiles('ffffffff-ffff-ffff-ffff-ffffffffffff'::UUID) WHERE has_authorization = true
    UNION ALL
    SELECT 'HR' as role_name, COUNT(*) as accessible_tiles
    FROM get_user_authorized_tiles('gggggggg-gggg-gggg-gggg-gggggggggggg'::UUID) WHERE has_authorization = true
    UNION ALL
    SELECT 'Employee' as role_name, COUNT(*) as accessible_tiles
    FROM get_user_authorized_tiles('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh'::UUID) WHERE has_authorization = true
) role_tiles
ORDER BY role_name;

-- Step 3: Test specific role permissions
SELECT 
    'ROLE PERMISSION TESTS' as test_category,
    test_scenario,
    expected_result,
    actual_result,
    CASE WHEN expected_result = actual_result THEN '✅ PASS' ELSE '❌ FAIL' END as status
FROM (
    -- Admin Tests
    SELECT 'Admin can create projects' as test_scenario, true as expected_result,
           check_construction_authorization('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::UUID, 'PS_PRJ_INITIATE', 'INITIATE', '{}') as actual_result
    UNION ALL
    SELECT 'Admin can approve POs' as test_scenario, true as expected_result,
           check_construction_authorization('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::UUID, 'MM_PO_APPROVE', 'APPROVE', '{}') as actual_result
    
    -- Manager Tests  
    UNION ALL
    SELECT 'Manager can create commercial projects' as test_scenario, true as expected_result,
           check_construction_authorization('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::UUID, 'PS_PRJ_INITIATE', 'INITIATE', '{"PROJ_TYPE": "commercial"}') as actual_result
    UNION ALL
    SELECT 'Manager CANNOT create infrastructure projects' as test_scenario, false as expected_result,
           check_construction_authorization('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::UUID, 'PS_PRJ_INITIATE', 'INITIATE', '{"PROJ_TYPE": "infrastructure"}') as actual_result
    
    -- Engineer Tests
    UNION ALL
    SELECT 'Engineer CANNOT create projects' as test_scenario, false as expected_result,
           check_construction_authorization('cccccccc-cccc-cccc-cccc-cccccccccccc'::UUID, 'PS_PRJ_INITIATE', 'INITIATE', '{}') as actual_result
    UNION ALL
    SELECT 'Engineer can execute activities' as test_scenario, true as expected_result,
           check_construction_authorization('cccccccc-cccc-cccc-cccc-cccccccccccc'::UUID, 'PP_ACT_EXECUTE', 'EXECUTE', '{}') as actual_result
    
    -- Procurement Tests
    UNION ALL
    SELECT 'Procurement can create POs' as test_scenario, true as expected_result,
           check_construction_authorization('dddddddd-dddd-dddd-dddd-dddddddddddd'::UUID, 'MM_PO_CREATE', 'INITIATE', '{}') as actual_result
    UNION ALL
    SELECT 'Procurement CANNOT approve timesheets' as test_scenario, false as expected_result,
           check_construction_authorization('dddddddd-dddd-dddd-dddd-dddddddddddd'::UUID, 'HR_TMS_APPROVE', 'APPROVE', '{}') as actual_result
    
    -- Employee Tests
    UNION ALL
    SELECT 'Employee can execute timesheets' as test_scenario, true as expected_result,
           check_construction_authorization('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh'::UUID, 'HR_TMS_EXECUTE', 'EXECUTE', '{}') as actual_result
    UNION ALL
    SELECT 'Employee CANNOT approve POs' as test_scenario, false as expected_result,
           check_construction_authorization('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh'::UUID, 'MM_PO_APPROVE', 'APPROVE', '{}') as actual_result
) permission_tests;

-- Step 4: Show detailed tile access by role
SELECT 
    'DETAILED TILE ACCESS' as test_category,
    role_name,
    tile_title,
    module_code,
    construction_action,
    has_authorization
FROM (
    SELECT 'Admin' as role_name, title as tile_title, module_code, construction_action, has_authorization
    FROM get_user_authorized_tiles('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::UUID)
    UNION ALL
    SELECT 'Manager' as role_name, title as tile_title, module_code, construction_action, has_authorization
    FROM get_user_authorized_tiles('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::UUID)
    UNION ALL
    SELECT 'Engineer' as role_name, title as tile_title, module_code, construction_action, has_authorization
    FROM get_user_authorized_tiles('cccccccc-cccc-cccc-cccc-cccccccccccc'::UUID)
    UNION ALL
    SELECT 'Employee' as role_name, title as tile_title, module_code, construction_action, has_authorization
    FROM get_user_authorized_tiles('hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh'::UUID)
) detailed_access
WHERE has_authorization = true
ORDER BY role_name, module_code, tile_title;

-- Step 5: Module access summary by role
SELECT 
    'MODULE ACCESS SUMMARY' as test_category,
    role_name,
    module_code,
    module_name,
    action_count
FROM (
    SELECT 'Admin' as role_name, module_code, module_name, array_length(actions, 1) as action_count
    FROM get_user_module_access('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::UUID)
    UNION ALL
    SELECT 'Manager' as role_name, module_code, module_name, array_length(actions, 1) as action_count
    FROM get_user_module_access('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb'::UUID)
    UNION ALL
    SELECT 'Engineer' as role_name, module_code, module_name, array_length(actions, 1) as action_count
    FROM get_user_module_access('cccccccc-cccc-cccc-cccc-cccccccccccc'::UUID)
    UNION ALL
    SELECT 'Procurement' as role_name, module_code, module_name, array_length(actions, 1) as action_count
    FROM get_user_module_access('dddddddd-dddd-dddd-dddd-dddddddddddd'::UUID)
) module_access
ORDER BY role_name, module_code;