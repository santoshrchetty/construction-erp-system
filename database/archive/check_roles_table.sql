-- Check roles table structure and data
SELECT * FROM roles;

-- Check if the role name matches what the app expects
SELECT u.email, r.name as role_name, r.id as role_id
FROM users u 
JOIN roles r ON u.role_id = r.id 
WHERE u.email LIKE '%admin%';