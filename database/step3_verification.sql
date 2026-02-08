-- ============================================================================
-- STEP 3 VERIFICATION: Test Simplified RPC Function
-- ============================================================================

-- Test 1: Admin user modules (should return friendly names)
SELECT 
    'Admin User Modules' as test,
    module_code
FROM get_user_modules((SELECT id FROM users WHERE email = 'admin@prom.com'))
ORDER BY module_code;

-- Test 2: HR user modules (should return friendly names)
SELECT 
    'HR User Modules' as test,
    module_code
FROM get_user_modules((SELECT id FROM users WHERE email = 'emy@prom.com'))
ORDER BY module_code;

-- Test 3: Engineer user modules
SELECT 
    'Engineer User Modules' as test,
    module_code
FROM get_user_modules((SELECT id FROM users WHERE email = 'engineer@prom.com'))
ORDER BY module_code;

-- Test 4: Verify NO SAP codes in output
SELECT 
    'SAP Codes Check' as test,
    CASE 
        WHEN COUNT(*) = 0 THEN '✓ PASS - No SAP codes found'
        ELSE '✗ FAIL - Found ' || COUNT(*)::text || ' SAP codes'
    END as result
FROM get_user_modules((SELECT id FROM users WHERE email = 'admin@prom.com'))
WHERE module_code IN ('AD', 'CF', 'DM', 'EH', 'EM', 'FI', 'HR', 'IN', 'MM', 'MT', 'PS', 'QM', 'RP', 'WM');

-- Test 5: Count distinct modules returned
SELECT 
    'Module Count' as test,
    COUNT(DISTINCT module_code) as distinct_modules
FROM get_user_modules((SELECT id FROM users WHERE email = 'admin@prom.com'));

-- Test 6: Show all unique modules across all users
SELECT DISTINCT 
    'All Modules in System' as test,
    module_code
FROM authorization_objects
WHERE module IS NOT NULL
ORDER BY module_code;
