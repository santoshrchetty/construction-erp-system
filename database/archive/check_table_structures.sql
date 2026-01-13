-- Simple diagnostic: Check what tables and columns exist

-- 1. Check tiles table structure
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'tiles' 
ORDER BY ordinal_position;

-- 2. Check authorization_objects table structure  
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'authorization_objects' 
ORDER BY ordinal_position;

-- 3. Check user_authorizations table structure
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'user_authorizations' 
ORDER BY ordinal_position;

-- 4. Check if admin user exists
SELECT email FROM auth.users WHERE email LIKE '%admin%' LIMIT 3;