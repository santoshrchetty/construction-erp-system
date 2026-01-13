-- Create authorization function using users.role_id
-- =================================================

CREATE OR REPLACE FUNCTION check_construction_authorization(
  p_user_id UUID,
  p_auth_object_name TEXT
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Check if user has a role that grants access to the auth object
  RETURN EXISTS (
    SELECT 1
    FROM users u
    JOIN roles r ON u.role_id = r.id
    JOIN role_authorization_mapping ram ON r.name = ram.role_name
    WHERE u.id = p_user_id
    AND ram.auth_object_name = p_auth_object_name
    AND u.is_active = true
    AND r.is_active = true
  );
END;
$$;

-- Test the function with admin user
SELECT 
  'PS_PRJ_INITIATE' as auth_object,
  check_construction_authorization('70f8baa8-27b8-4061-84c4-6dd027d6b89f'::uuid, 'PS_PRJ_INITIATE') as has_access
UNION ALL
SELECT 
  'PS_WBS_MODIFY' as auth_object,
  check_construction_authorization('70f8baa8-27b8-4061-84c4-6dd027d6b89f'::uuid, 'PS_WBS_MODIFY') as has_access;