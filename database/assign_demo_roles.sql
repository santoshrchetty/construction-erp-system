-- Assign roles to demo users
UPDATE users 
SET role_id = '00e8b52d-e653-47c2-b679-7d9623973a44'
WHERE email = 'admin@demo.com';

UPDATE users 
SET role_id = '3d61ab7d-725f-4e40-90ad-d37bf9733f51'
WHERE email = 'manager@demo.com';

UPDATE users 
SET role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'
WHERE email = 'engineer@demo.com';

UPDATE users 
SET role_id = '32a8d57a-4725-4b28-af71-7e08bbb97dc0'
WHERE email = 'employee@demo.com';

-- Verify user roles
SELECT u.email, r.name as role_name 
FROM users u 
JOIN roles r ON u.role_id = r.id 
ORDER BY u.email;