-- Simple Role-Wise Test (Fixed UUIDs)
-- ===================================

-- Test Admin Role
DO $$
DECLARE
    admin_user UUID := uuid_generate_v4();
BEGIN
    PERFORM assign_role_authorizations(admin_user, 'Admin');
    
    -- Show Admin's accessible tiles
    RAISE NOTICE 'Admin User ID: %', admin_user;
    
    -- Store the UUID for later queries
    CREATE TEMP TABLE IF NOT EXISTS test_users (role_name TEXT, user_id UUID);
    INSERT INTO test_users VALUES ('Admin', admin_user);
END $$;

-- Test Manager Role
DO $$
DECLARE
    manager_user UUID := uuid_generate_v4();
BEGIN
    PERFORM assign_role_authorizations(manager_user, 'Manager');
    INSERT INTO test_users VALUES ('Manager', manager_user);
END $$;

-- Test Engineer Role
DO $$
DECLARE
    engineer_user UUID := uuid_generate_v4();
BEGIN
    PERFORM assign_role_authorizations(engineer_user, 'Engineer');
    INSERT INTO test_users VALUES ('Engineer', engineer_user);
END $$;

-- Test Employee Role
DO $$
DECLARE
    employee_user UUID := uuid_generate_v4();
BEGIN
    PERFORM assign_role_authorizations(employee_user, 'Employee');
    INSERT INTO test_users VALUES ('Employee', employee_user);
END $$;

-- Show all test users created
SELECT 'TEST USERS CREATED' as status, role_name, user_id FROM test_users;

-- Test tile access for each role
SELECT 
    'TILE ACCESS BY ROLE' as test_type,
    tu.role_name,
    COUNT(*) as accessible_tiles
FROM test_users tu
CROSS JOIN LATERAL (
    SELECT has_authorization 
    FROM get_user_authorized_tiles(tu.user_id) 
    WHERE has_authorization = true
) tiles
GROUP BY tu.role_name
ORDER BY tu.role_name;

-- Test specific permissions
SELECT 
    'PERMISSION TESTS' as test_type,
    tu.role_name,
    'Can Create Projects' as permission_test,
    check_construction_authorization(tu.user_id, 'PS_PRJ_INITIATE', 'INITIATE', '{}') as has_permission
FROM test_users tu
WHERE tu.role_name IN ('Admin', 'Manager', 'Engineer', 'Employee')

UNION ALL

SELECT 
    'PERMISSION TESTS' as test_type,
    tu.role_name,
    'Can Approve POs' as permission_test,
    check_construction_authorization(tu.user_id, 'MM_PO_APPROVE', 'APPROVE', '{}') as has_permission
FROM test_users tu
WHERE tu.role_name IN ('Admin', 'Manager', 'Engineer', 'Employee')

UNION ALL

SELECT 
    'PERMISSION TESTS' as test_type,
    tu.role_name,
    'Can Execute Activities' as permission_test,
    check_construction_authorization(tu.user_id, 'PP_ACT_EXECUTE', 'EXECUTE', '{}') as has_permission
FROM test_users tu
WHERE tu.role_name IN ('Admin', 'Manager', 'Engineer', 'Employee')

ORDER BY role_name, permission_test;

-- Show detailed tiles for Admin and Engineer (comparison)
SELECT 
    'DETAILED TILE COMPARISON' as test_type,
    tu.role_name,
    t.title,
    t.module_code,
    t.construction_action,
    t.has_authorization
FROM test_users tu
CROSS JOIN LATERAL get_user_authorized_tiles(tu.user_id) t
WHERE tu.role_name IN ('Admin', 'Engineer') 
  AND t.has_authorization = true
ORDER BY tu.role_name, t.module_code, t.title;

-- Clean up temp table
DROP TABLE IF EXISTS test_users;