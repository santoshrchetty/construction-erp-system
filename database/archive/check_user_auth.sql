-- Check User Structure and Authorization
-- ======================================

-- Check users table structure
SELECT 'Users Table Structure' as check_type;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'users' 
ORDER BY ordinal_position;

-- Check current users
SELECT 'Current Users' as check_type;
SELECT * FROM users ORDER BY created_at DESC LIMIT 3;

-- Check if check_construction_authorization function exists
SELECT 'Authorization Function' as check_type;
SELECT routine_name, routine_definition
FROM information_schema.routines 
WHERE routine_name = 'check_construction_authorization';

-- Test authorization function directly
SELECT 'Test Authorization' as check_type;
SELECT check_construction_authorization(
    (SELECT id FROM users LIMIT 1)::uuid,
    'FI_GL_DISP'
) as has_finance_access;