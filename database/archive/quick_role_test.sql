-- Individual Role Testing - Quick Tests
-- =====================================

-- Test Admin Role
SELECT 'ADMIN ROLE TEST' as test_type;
PERFORM assign_role_authorizations('test-admin-001'::UUID, 'Admin');
SELECT 
    'Admin' as role,
    title as accessible_tile,
    module_code,
    construction_action
FROM get_user_authorized_tiles('test-admin-001'::UUID) 
WHERE has_authorization = true 
ORDER BY module_code
LIMIT 10;

-- Test Manager Role  
SELECT 'MANAGER ROLE TEST' as test_type;
PERFORM assign_role_authorizations('test-manager-001'::UUID, 'Manager');
SELECT 
    'Manager' as role,
    title as accessible_tile,
    module_code,
    construction_action
FROM get_user_authorized_tiles('test-manager-001'::UUID) 
WHERE has_authorization = true 
ORDER BY module_code
LIMIT 10;

-- Test Engineer Role
SELECT 'ENGINEER ROLE TEST' as test_type;
PERFORM assign_role_authorizations('test-engineer-001'::UUID, 'Engineer');
SELECT 
    'Engineer' as role,
    title as accessible_tile,
    module_code,
    construction_action
FROM get_user_authorized_tiles('test-engineer-001'::UUID) 
WHERE has_authorization = true 
ORDER BY module_code
LIMIT 10;

-- Test Employee Role
SELECT 'EMPLOYEE ROLE TEST' as test_type;
PERFORM assign_role_authorizations('test-employee-001'::UUID, 'Employee');
SELECT 
    'Employee' as role,
    title as accessible_tile,
    module_code,
    construction_action
FROM get_user_authorized_tiles('test-employee-001'::UUID) 
WHERE has_authorization = true 
ORDER BY module_code
LIMIT 10;

-- Quick Permission Check
SELECT 
    'QUICK PERMISSION CHECK' as test_type,
    role_name,
    can_create_projects,
    can_approve_pos,
    can_execute_activities,
    can_approve_timesheets
FROM (
    SELECT 
        'Admin' as role_name,
        check_construction_authorization('test-admin-001'::UUID, 'PS_PRJ_INITIATE', 'INITIATE', '{}') as can_create_projects,
        check_construction_authorization('test-admin-001'::UUID, 'MM_PO_APPROVE', 'APPROVE', '{}') as can_approve_pos,
        check_construction_authorization('test-admin-001'::UUID, 'PP_ACT_EXECUTE', 'EXECUTE', '{}') as can_execute_activities,
        check_construction_authorization('test-admin-001'::UUID, 'HR_TMS_APPROVE', 'APPROVE', '{}') as can_approve_timesheets
    UNION ALL
    SELECT 
        'Manager' as role_name,
        check_construction_authorization('test-manager-001'::UUID, 'PS_PRJ_INITIATE', 'INITIATE', '{}') as can_create_projects,
        check_construction_authorization('test-manager-001'::UUID, 'MM_PO_APPROVE', 'APPROVE', '{}') as can_approve_pos,
        check_construction_authorization('test-manager-001'::UUID, 'PP_ACT_EXECUTE', 'EXECUTE', '{}') as can_execute_activities,
        check_construction_authorization('test-manager-001'::UUID, 'HR_TMS_APPROVE', 'APPROVE', '{}') as can_approve_timesheets
    UNION ALL
    SELECT 
        'Engineer' as role_name,
        check_construction_authorization('test-engineer-001'::UUID, 'PS_PRJ_INITIATE', 'INITIATE', '{}') as can_create_projects,
        check_construction_authorization('test-engineer-001'::UUID, 'MM_PO_APPROVE', 'APPROVE', '{}') as can_approve_pos,
        check_construction_authorization('test-engineer-001'::UUID, 'PP_ACT_EXECUTE', 'EXECUTE', '{}') as can_execute_activities,
        check_construction_authorization('test-engineer-001'::UUID, 'HR_TMS_APPROVE', 'APPROVE', '{}') as can_approve_timesheets
    UNION ALL
    SELECT 
        'Employee' as role_name,
        check_construction_authorization('test-employee-001'::UUID, 'PS_PRJ_INITIATE', 'INITIATE', '{}') as can_create_projects,
        check_construction_authorization('test-employee-001'::UUID, 'MM_PO_APPROVE', 'APPROVE', '{}') as can_approve_pos,
        check_construction_authorization('test-employee-001'::UUID, 'PP_ACT_EXECUTE', 'EXECUTE', '{}') as can_execute_activities,
        check_construction_authorization('test-employee-001'::UUID, 'HR_TMS_APPROVE', 'APPROVE', '{}') as can_approve_timesheets
) role_permissions;