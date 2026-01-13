-- Check Admin User Finance Authorization
-- =====================================

-- Check current admin users
SELECT 'Admin Users' as check_type;
SELECT id, email, created_at
FROM users 
WHERE email LIKE '%admin%' OR email LIKE '%@nttdemo.com'
ORDER BY created_at DESC;

-- Check Finance authorization for admin users
SELECT 'Admin Finance Authorization' as check_type;
SELECT u.email, ao.object_name, ua.field_values,
       check_construction_authorization(u.id, ao.object_name, 'DISPLAY') as has_access
FROM users u
CROSS JOIN authorization_objects ao
LEFT JOIN user_authorizations ua ON u.id = ua.user_id AND ao.id = ua.auth_object_id
WHERE (u.email LIKE '%admin%' OR u.email LIKE '%@nttdemo.com')
  AND ao.module IN ('FI', 'CO')
ORDER BY u.email, ao.object_name;

-- Grant Finance access to admin users specifically
INSERT INTO user_authorizations (user_id, auth_object_id, field_values, valid_from)
SELECT u.id, ao.id, '{"ACTION": ["DISPLAY", "CREATE", "CHANGE", "EXECUTE"]}'::jsonb, CURRENT_DATE
FROM users u
CROSS JOIN authorization_objects ao
WHERE (u.email LIKE '%admin%' OR u.email LIKE '%@nttdemo.com')
  AND ao.module IN ('FI', 'CO')
ON CONFLICT (user_id, auth_object_id) 
DO UPDATE SET 
    field_values = '{"ACTION": ["DISPLAY", "CREATE", "CHANGE", "EXECUTE"]}'::jsonb,
    valid_from = CURRENT_DATE;

-- Test authorization for admin user
SELECT 'Admin Authorization Test' as check_type;
SELECT u.email,
       check_construction_authorization(u.id, 'FI_GL_DISP', 'DISPLAY') as chart_of_accounts,
       check_construction_authorization(u.id, 'FI_GL_POST', 'CREATE') as journal_entry,
       check_construction_authorization(u.id, 'CO_PRJ_DIS', 'DISPLAY') as project_costs
FROM users u
WHERE u.email LIKE '%admin%' OR u.email LIKE '%@nttdemo.com'
ORDER BY u.email;