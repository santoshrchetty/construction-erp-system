-- Simple ERP permission fix

-- Add ERP configuration permission
INSERT INTO permissions (name, description) VALUES 
('erp_configuration', 'Access ERP Configuration module')
ON CONFLICT (name) DO NOTHING;

-- Check if admin role exists and assign permission
INSERT INTO role_permissions (role_id, permission_id) VALUES 
((SELECT id FROM roles WHERE name = 'admin' LIMIT 1), 
 (SELECT id FROM permissions WHERE name = 'erp_configuration'))
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Verify the permission was added
SELECT r.name as role_name, p.name as permission_name 
FROM roles r
JOIN role_permissions rp ON r.id = rp.role_id
JOIN permissions p ON rp.permission_id = p.id
WHERE p.name = 'erp_configuration';