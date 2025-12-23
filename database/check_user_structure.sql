-- Check users and roles structure
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'users';

-- Check what's in roles table
SELECT * FROM roles;

-- Check current users
SELECT * FROM users WHERE email LIKE '%admin%';