-- Update engineer email to @nttdemo.com
UPDATE users 
SET email = 'engineer@nttdemo.com'
WHERE email = 'engineer@demo.com';

-- Also update in auth.users if needed
UPDATE auth.users 
SET email = 'engineer@nttdemo.com'
WHERE email = 'engineer@demo.com';

-- Verify the update
SELECT email, r.name as role_name 
FROM users u 
JOIN roles r ON u.role_id = r.id 
WHERE u.email = 'engineer@nttdemo.com';

SELECT 'Engineer email updated to @nttdemo.com!' as status;