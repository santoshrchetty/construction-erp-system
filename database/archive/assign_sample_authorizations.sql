-- Sample User Authorization Assignments
-- ====================================

-- Assign authorizations to existing users (replace UUIDs with actual user IDs)

-- Admin user - full access
INSERT INTO user_authorizations (user_id, auth_object_id, field_values) VALUES
-- Replace with actual admin user ID
('admin-user-uuid-here', 
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CRE'),
 '{"ACTVT": ["01"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'::jsonb),

('admin-user-uuid-here',
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_CHG'), 
 '{"ACTVT": ["02"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'::jsonb),

('admin-user-uuid-here',
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PO_APP'),
 '{"ACTVT": ["05"], "PO_TYPE": ["standard", "blanket", "contract"]}'::jsonb);

-- Manager user - limited access
INSERT INTO user_authorizations (user_id, auth_object_id, field_values) VALUES
-- Replace with actual manager user ID  
('manager-user-uuid-here',
 (SELECT id FROM authorization_objects WHERE object_name = 'F_PROJ_DIS'),
 '{"ACTVT": ["03"], "PROJ_TYPE": ["commercial", "residential"]}'::jsonb),

('manager-user-uuid-here',
 (SELECT id FROM authorization_objects WHERE object_name = 'F_TIME_APP'),
 '{"ACTVT": ["05"]}'::jsonb);

-- Check current user IDs in your system
SELECT id, email, name FROM auth.users LIMIT 5;