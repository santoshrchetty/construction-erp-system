-- Step 3: Enhanced Tile System with SAP Transaction Codes
-- ======================================================

-- Add transaction codes to existing tiles table
ALTER TABLE tiles ADD COLUMN IF NOT EXISTS tcode VARCHAR(10);
ALTER TABLE tiles ADD COLUMN IF NOT EXISTS auth_object VARCHAR(10);
ALTER TABLE tiles ADD COLUMN IF NOT EXISTS semantic_action VARCHAR(20);
ALTER TABLE tiles ADD COLUMN IF NOT EXISTS tile_group VARCHAR(50);

-- Update existing tiles with SAP transaction codes
UPDATE tiles SET 
    tcode = 'ZPR01',
    auth_object = 'F_PROJ_DIS',
    semantic_action = 'manage',
    tile_group = 'Project Management'
WHERE title = 'Projects';

UPDATE tiles SET 
    tcode = 'ZAC01', 
    auth_object = 'F_PROJ_DIS',
    semantic_action = 'manage',
    tile_group = 'Project Management'
WHERE title = 'Activities';

UPDATE tiles SET 
    tcode = 'ZPO01',
    auth_object = 'F_PO_DIS', 
    semantic_action = 'manage',
    tile_group = 'Procurement'
WHERE title = 'Purchase Orders';

UPDATE tiles SET 
    tcode = 'ZTS01',
    auth_object = 'F_TIME_CRE',
    semantic_action = 'create',
    tile_group = 'Time Management'
WHERE title = 'Timesheets';

UPDATE tiles SET 
    tcode = 'ZIN01',
    auth_object = 'F_INV_DIS',
    semantic_action = 'display', 
    tile_group = 'Materials Management'
WHERE title = 'Inventory';

UPDATE tiles SET 
    tcode = 'ZRP01',
    auth_object = 'F_COST_DIS',
    semantic_action = 'display',
    tile_group = 'Reporting'
WHERE title = 'Reports';

-- Insert additional semantic tiles
INSERT INTO tiles (title, subtitle, icon, color, route, roles, sequence_order, tcode, auth_object, semantic_action, tile_group) VALUES

-- Project Management Tiles
('Create Project', 'Start new project', 'plus', 'bg-green-500', '/projects/create', '{admin,project_manager}', 10, 'ZPR02', 'F_PROJ_CRE', 'create', 'Project Management'),
('Change Project', 'Modify project details', 'edit', 'bg-blue-500', '/projects/edit', '{admin,project_manager}', 11, 'ZPR03', 'F_PROJ_CHG', 'change', 'Project Management'),
('Display Project', 'View project information', 'eye', 'bg-gray-500', '/projects/display', '{admin,project_manager,site_engineer}', 12, 'ZPR04', 'F_PROJ_DIS', 'display', 'Project Management'),

-- Purchase Order Tiles  
('Create PO', 'Create purchase order', 'plus', 'bg-green-500', '/purchase-orders/create', '{admin,procurement}', 20, 'ZPO02', 'F_PO_CRE', 'create', 'Procurement'),
('Change PO', 'Modify purchase order', 'edit', 'bg-blue-500', '/purchase-orders/edit', '{admin,procurement}', 21, 'ZPO03', 'F_PO_CHG', 'change', 'Procurement'),
('Approve PO', 'Approve purchase orders', 'check', 'bg-orange-500', '/purchase-orders/approve', '{admin,project_manager,finance}', 22, 'ZPO04', 'F_PO_APP', 'approve', 'Procurement'),

-- Timesheet Tiles
('Create Timesheet', 'Log work hours', 'plus', 'bg-green-500', '/timesheets/create', '{admin,project_manager,site_engineer,foreman,worker}', 30, 'ZTS02', 'F_TIME_CRE', 'create', 'Time Management'),
('Approve Timesheet', 'Approve work hours', 'check', 'bg-orange-500', '/timesheets/approve', '{admin,project_manager,finance,hr}', 31, 'ZTS03', 'F_TIME_APP', 'approve', 'Time Management'),

-- Materials Management
('Create Material', 'Add new material', 'plus', 'bg-green-500', '/materials/create', '{admin,procurement}', 40, 'ZMM01', 'F_MAT_CRE', 'create', 'Materials Management'),
('Goods Receipt', 'Receive materials', 'package', 'bg-blue-500', '/inventory/grn', '{admin,storekeeper}', 41, 'ZMM02', 'F_GRN_CRE', 'create', 'Materials Management');

-- Create tile groups table for better organization
CREATE TABLE IF NOT EXISTS tile_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(20) DEFAULT 'bg-gray-500',
    sequence_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true
);

-- Insert tile groups
INSERT INTO tile_groups (group_name, description, icon, color, sequence_order) VALUES
('Project Management', 'Project planning and execution', 'building', 'bg-blue-500', 1),
('Procurement', 'Purchase orders and vendor management', 'shopping-cart', 'bg-orange-500', 2),
('Time Management', 'Timesheet and attendance tracking', 'clock', 'bg-purple-500', 3),
('Materials Management', 'Inventory and materials handling', 'package', 'bg-green-500', 4),
('Reporting', 'Analytics and business intelligence', 'chart-bar', 'bg-red-500', 5);

-- Create function to get user tiles with authorization check
CREATE OR REPLACE FUNCTION get_user_tiles_with_auth(p_user_id UUID)
RETURNS TABLE (
    tile_id UUID,
    title VARCHAR(100),
    subtitle VARCHAR(200),
    icon VARCHAR(50),
    color VARCHAR(20),
    route VARCHAR(200),
    tcode VARCHAR(10),
    semantic_action VARCHAR(20),
    tile_group VARCHAR(50),
    has_access BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.title,
        t.subtitle,
        t.icon,
        t.color,
        t.route,
        t.tcode,
        t.semantic_action,
        t.tile_group,
        CASE 
            WHEN t.auth_object IS NOT NULL THEN
                check_sap_authorization(
                    p_user_id,
                    t.auth_object,
                    CASE t.semantic_action
                        WHEN 'create' THEN '01'
                        WHEN 'change' THEN '02'
                        WHEN 'display' THEN '03'
                        WHEN 'approve' THEN '05'
                        ELSE '03'
                    END,
                    '{}'::jsonb
                )
            ELSE true
        END as has_access
    FROM tiles t
    WHERE t.is_active = true
    ORDER BY t.tile_group, t.sequence_order;
END;
$$ LANGUAGE plpgsql;