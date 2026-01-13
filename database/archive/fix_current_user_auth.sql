-- Fix Current User Authorization
-- ===============================

-- Check current admin user
SELECT 'CURRENT ADMIN USER' as status, id, email, first_name, last_name 
FROM users 
WHERE email = 'admin@nttdemo.com';

-- Assign Admin role to the current user
DO $$
DECLARE
    current_admin_id UUID := '70f8baa8-27b8-4061-84c4-6dd027d6b89f';
BEGIN
    -- Assign Admin role with full authorizations
    PERFORM assign_role_authorizations(current_admin_id, 'Admin');
    
    RAISE NOTICE 'Admin role assigned to user: %', current_admin_id;
END $$;

-- Verify the assignment worked
SELECT 
    'VERIFICATION' as test_type,
    COUNT(*) as authorized_tiles
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f') 
WHERE has_authorization = true;

-- Show specific tiles for admin user
SELECT 
    'ADMIN TILES' as test_type,
    title,
    module_code,
    construction_action,
    has_authorization
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f')
WHERE has_authorization = true
ORDER BY module_code, title
LIMIT 10;