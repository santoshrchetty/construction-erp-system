-- Add common ERP-related permissions
INSERT INTO permissions (name, description) VALUES 
('erp_configuration', 'Access ERP Configuration module'),
('erp_config', 'Access ERP Config'),
('erp_admin', 'ERP Administration'),
('system_admin', 'System Administration'),
('admin', 'Administrator Access'),
('all_permissions', 'All System Permissions')
ON CONFLICT (name) DO NOTHING;

-- Assign all these permissions to admin role
INSERT INTO role_permissions (role_id, permission_id) 
SELECT '00e8b52d-e653-47c2-b679-7d9623973a44', id 
FROM permissions 
WHERE name IN ('erp_configuration', 'erp_config', 'erp_admin', 'system_admin', 'admin', 'all_permissions')
ON CONFLICT (role_id, permission_id) DO NOTHING;

-- Verify permissions assigned
SELECT r.name as role_name, p.name as permission_name 
FROM roles r
JOIN role_permissions rp ON r.id = rp.role_id
JOIN permissions p ON rp.permission_id = p.id
WHERE r.id = '00e8b52d-e653-47c2-b679-7d9623973a44';