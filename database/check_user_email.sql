-- Check the exact email format
SELECT id, email, role_id FROM users WHERE email LIKE '%nttdemo%';

-- Fix the email if it has # instead of @
UPDATE users 
SET email = 'admin@nttdemo.com' 
WHERE email = 'admin#nttdemo.com';

-- Verify the fix
SELECT id, email, role_id FROM users WHERE email LIKE '%nttdemo%';