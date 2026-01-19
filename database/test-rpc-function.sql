-- Test if the RPC function exists
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name = 'get_user_modules';

-- Test the RPC function with admin user
SELECT * FROM get_user_modules('7febcd41-4b34-4155-b306-8ea89d9f715e'::uuid);

-- Get a sample user ID to test with
SELECT id, email FROM users LIMIT 1;
