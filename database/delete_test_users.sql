-- Delete improperly created test users
-- These were created via SQL and won't work with Supabase Auth

-- Get the user IDs first
DO $$
DECLARE
  v_user1_id TEXT;
  v_user2_id TEXT;
  v_user3_id TEXT;
BEGIN
  SELECT id::text INTO v_user1_id FROM auth.users WHERE email = 'john.engineer@example.com';
  SELECT id::text INTO v_user2_id FROM auth.users WHERE email = 'jane.manager@example.com';
  SELECT id::text INTO v_user3_id FROM auth.users WHERE email = 'bob.director@example.com';
  
  -- Delete from role_assignments (employee_id is VARCHAR)
  DELETE FROM role_assignments WHERE employee_id IN (v_user1_id, v_user2_id, v_user3_id);
  
  -- Delete from org_hierarchy (employee_id is VARCHAR)
  DELETE FROM org_hierarchy WHERE employee_id::text IN (v_user1_id, v_user2_id, v_user3_id);
  
  -- Delete from auth.users
  DELETE FROM auth.users WHERE email IN ('john.engineer@example.com', 'jane.manager@example.com', 'bob.director@example.com');
  
  RAISE NOTICE 'Test users deleted successfully';
END $$;

-- Verify deletion
SELECT COUNT(*) as remaining_test_users
FROM auth.users 
WHERE email IN ('john.engineer@example.com', 'jane.manager@example.com', 'bob.director@example.com');
