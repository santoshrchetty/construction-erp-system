-- Check if users table IDs match auth.users IDs
SELECT 
    au.id as auth_id,
    au.email as auth_email,
    u.id as users_id,
    u.email as users_email
FROM auth.users au
LEFT JOIN users u ON au.id = u.id;

-- Delete existing users and re-sync with correct IDs
DELETE FROM users;

-- Re-sync with correct auth user IDs
INSERT INTO users (id, email, role_id, created_at)
SELECT 
    au.id,
    au.email,
    (SELECT id FROM roles WHERE name = 'Employee' LIMIT 1) as role_id,
    au.created_at
FROM auth.users au;

-- Now assign correct roles
UPDATE users SET role_id = (SELECT id FROM roles WHERE name = 'Admin') WHERE email = 'admin@demo.com';
UPDATE users SET role_id = (SELECT id FROM roles WHERE name = 'Manager') WHERE email = 'manager@demo.com';
UPDATE users SET role_id = (SELECT id FROM roles WHERE name = 'Engineer') WHERE email = 'engineer@demo.com';

SELECT 'Users re-synced with correct IDs!' as status;