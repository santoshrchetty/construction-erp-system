-- Fix ERP Configuration permissions for admin user

-- Check current admin user and role
SELECT u.email, r.name as role_name 
FROM users u 
JOIN user_roles ur ON u.id = ur.user_id 
JOIN roles r ON ur.role_id = r.id 
WHERE u.email = 'admin@construction.com';

-- Add ERP configuration permission if it doesn't exist
INSERT INTO permissions (name, description) VALUES 
('erp_configuration', 'Access ERP Configuration module')
ON CONFLICT (name) DO NOTHING;

-- Assign ERP permission to admin role
INSERT INTO role_permissions (role_id, permission_id) VALUES 
((SELECT id FROM roles WHERE name = 'admin'), 
 (SELECT id FROM permissions WHERE name = 'erp_configuration'))
ON CONFLICT (role_id, permission_id) DO NOTHING;