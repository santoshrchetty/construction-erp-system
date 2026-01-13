-- Get engineer user ID
-- ====================

SELECT id, email, role_id 
FROM users 
WHERE email = 'engineer@nttdemo.com';