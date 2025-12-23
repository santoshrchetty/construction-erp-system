-- Check all roles
SELECT id, name, description, is_active FROM roles ORDER BY name;

-- Count roles
SELECT COUNT(*) as total_roles FROM roles;