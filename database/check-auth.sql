-- Check if auth is properly configured
SELECT 
    COUNT(*) as user_count,
    COUNT(CASE WHEN email_confirmed_at IS NOT NULL THEN 1 END) as confirmed_users
FROM auth.users;

-- Check if anon key has proper permissions
SELECT 
    rolname,
    rolsuper,
    rolinherit,
    rolcreaterole,
    rolcreatedb,
    rolcanlogin
FROM pg_roles
WHERE rolname IN ('anon', 'authenticated', 'service_role');
