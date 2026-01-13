-- Add Missing Admin Authorizations
-- =================================

-- Add admin authorizations for new tiles
INSERT INTO role_authorization_mapping (role_name, auth_object_name, field_values) VALUES

-- Admin access to Materials Management
('Admin', 'MM_MAT_MASTER', '{"ACTION": ["MODIFY"]}'),
('Admin', 'MM_VEN_MANAGE', '{"ACTION": ["MODIFY"]}'),

-- Admin access to Warehouse Management  
('Admin', 'WM_STK_REVIEW', '{"ACTION": ["REVIEW"]}'),
('Admin', 'WM_STK_TRANSFER', '{"ACTION": ["EXECUTE"]}'),
('Admin', 'WM_STR_MANAGE', '{"ACTION": ["MODIFY"]}');

-- Assign these new authorizations to admin user
DO $$
DECLARE
    admin_user_id UUID := '70f8baa8-27b8-4061-84c4-6dd027d6b89f';
BEGIN
    -- Re-assign Admin role to get new authorizations
    PERFORM assign_role_authorizations(admin_user_id, 'Admin');
    
    RAISE NOTICE 'Updated admin authorizations for user: %', admin_user_id;
END $$;

-- Verify admin has access to new tiles
SELECT 
    'ADMIN TILE ACCESS' as test_type,
    t.title,
    t.tile_category,
    t.has_authorization
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f') t
WHERE t.title IN ('Material Master', 'Vendor Master', 'Inventory Management', 'SAP Configuration', 'ERP Configuration')
ORDER BY t.tile_category;