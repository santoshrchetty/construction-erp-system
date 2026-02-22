-- =====================================================
-- RLS TEST WITH ACTUAL RESULTS
-- =====================================================

-- Test Customer User
WITH customer_test AS (
  SELECT 
    'Customer User' AS user_type,
    (SELECT id FROM auth.users WHERE email = 'customeruser@acme.com') AS user_id,
    (SELECT email FROM auth.users WHERE email = 'customeruser@acme.com') AS email
)
SELECT 
  user_type,
  email,
  user_id,
  'Run next query with this user_id set' AS instruction
FROM customer_test;

-- Now manually set and test
-- Copy the user_id from above and run:
-- SELECT set_config('app.current_user_id', 'PASTE_USER_ID_HERE', false);
-- SELECT COUNT(*) FROM external_organizations;

-- Get all user IDs for testing
SELECT 
  'Test Users' AS info,
  email,
  id AS user_id,
  'Use: SELECT set_config(''app.current_user_id'', ''' || id || ''', false); SELECT COUNT(*) FROM external_organizations;' AS test_command
FROM auth.users 
WHERE email IN ('customeruser@acme.com', 'vendoruser@steel.com', 'contractoruser@elite.com', 'internaluser@abc.com')
ORDER BY email;
