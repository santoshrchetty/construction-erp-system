-- Step 4: Enhanced Tile System with Construction Authorization
-- ==========================================================

-- Update tiles table to integrate with construction framework
ALTER TABLE tiles ADD COLUMN IF NOT EXISTS auth_object VARCHAR(20);
ALTER TABLE tiles ADD COLUMN IF NOT EXISTS construction_action VARCHAR(20);
ALTER TABLE tiles ADD COLUMN IF NOT EXISTS module_code VARCHAR(2);
ALTER TABLE tiles ADD COLUMN IF NOT EXISTS tile_category VARCHAR(50);

-- Clear existing tiles and create construction-native ones
DELETE FROM tiles;

-- Insert Construction Module Tiles
INSERT INTO tiles (title, subtitle, icon, color, route, roles, sequence_order, auth_object, construction_action, module_code, tile_category) VALUES

-- PS - Project System Tiles
('Projects Dashboard', 'View all projects', 'building-2', 'bg-blue-500', '/projects', '{admin,manager}', 10, 'PS_PRJ_REVIEW', 'REVIEW', 'PS', 'Project Management'),
('Create Project', 'Start new project', 'plus-circle', 'bg-green-500', '/projects/create', '{admin,manager}', 11, 'PS_PRJ_INITIATE', 'INITIATE', 'PS', 'Project Management'),
('Modify Projects', 'Edit project details', 'edit-3', 'bg-blue-600', '/projects/edit', '{admin,manager}', 12, 'PS_PRJ_MODIFY', 'MODIFY', 'PS', 'Project Management'),
('WBS Management', 'Work breakdown structure', 'git-branch', 'bg-purple-500', '/wbs', '{admin,manager}', 13, 'PS_WBS_CREATE', 'INITIATE', 'PS', 'Project Management'),

-- MM - Materials Management Tiles  
('Purchase Orders', 'Manage purchase orders', 'shopping-cart', 'bg-orange-500', '/purchase-orders', '{admin,procurement}', 20, 'MM_PO_CREATE', 'INITIATE', 'MM', 'Procurement'),
('PO Approvals', 'Approve purchase orders', 'check-circle', 'bg-green-600', '/purchase-orders/approve', '{admin,manager,finance}', 21, 'MM_PO_APPROVE', 'APPROVE', 'MM', 'Procurement'),
('Goods Receipt', 'Process material receipts', 'package-check', 'bg-teal-500', '/inventory/grn', '{admin,storekeeper}', 22, 'MM_GRN_EXECUTE', 'EXECUTE', 'MM', 'Materials'),
('Material Master', 'Maintain materials', 'box', 'bg-indigo-500', '/materials', '{admin,procurement}', 23, 'MM_MAT_MASTER', 'MODIFY', 'MM', 'Materials'),
('Vendor Management', 'Manage suppliers', 'users', 'bg-cyan-500', '/vendors', '{admin,procurement}', 24, 'MM_VEN_MANAGE', 'MODIFY', 'MM', 'Procurement'),

-- PP - Production Planning Tiles
('Activity Scheduler', 'Schedule work activities', 'calendar', 'bg-violet-500', '/activities/schedule', '{admin,manager}', 30, 'PP_ACT_SCHEDULE', 'INITIATE', 'PP', 'Planning'),
('Activity Execution', 'Execute work activities', 'play-circle', 'bg-emerald-500', '/activities/execute', '{admin,engineer}', 31, 'PP_ACT_EXECUTE', 'EXECUTE', 'PP', 'Execution'),
('Task Assignment', 'Assign tasks to workers', 'user-check', 'bg-amber-500', '/tasks/assign', '{admin,manager}', 32, 'PP_TSK_ASSIGN', 'INITIATE', 'PP', 'Planning'),
('Progress Update', 'Update task progress', 'trending-up', 'bg-lime-500', '/tasks/progress', '{admin,engineer,employee}', 33, 'PP_TSK_UPDATE', 'EXECUTE', 'PP', 'Execution'),

-- QM - Quality Management Tiles
('BOQ Review', 'Review quantities', 'file-text', 'bg-slate-500', '/boq', '{admin,engineer}', 40, 'QM_BOQ_REVIEW', 'REVIEW', 'QM', 'Quality'),
('BOQ Modification', 'Modify quantities', 'edit', 'bg-gray-600', '/boq/edit', '{admin}', 41, 'QM_BOQ_MODIFY', 'MODIFY', 'QM', 'Quality'),
('Quality Control', 'Quality inspections', 'shield-check', 'bg-red-500', '/quality', '{admin}', 42, 'QM_QC_EXECUTE', 'EXECUTE', 'QM', 'Quality'),

-- FI/CO - Financial Tiles
('Cost Review', 'Review project costs', 'dollar-sign', 'bg-green-700', '/finance/costs', '{admin,finance}', 50, 'FI_CST_REVIEW', 'REVIEW', 'FI', 'Finance'),
('Budget Management', 'Manage project budgets', 'pie-chart', 'bg-blue-700', '/finance/budget', '{admin,finance}', 51, 'CO_BDG_MODIFY', 'MODIFY', 'CO', 'Finance'),
('Cost Analysis', 'Cost-to-complete analysis', 'bar-chart-3', 'bg-purple-700', '/finance/ctc', '{admin,manager,finance}', 52, 'CO_CTC_ANALYZE', 'ANALYZE', 'CO', 'Finance'),

-- HR - Human Resources Tiles
('Timesheet Entry', 'Log work hours', 'clock', 'bg-indigo-600', '/timesheets', '{admin,engineer,employee}', 60, 'HR_TMS_EXECUTE', 'EXECUTE', 'HR', 'Time Management'),
('Timesheet Approval', 'Approve work hours', 'check-square', 'bg-green-800', '/timesheets/approve', '{admin,manager,hr}', 61, 'HR_TMS_APPROVE', 'APPROVE', 'HR', 'Time Management'),
('Employee Management', 'Manage workforce', 'user-cog', 'bg-gray-700', '/employees', '{admin,hr}', 62, 'HR_EMP_MANAGE', 'MODIFY', 'HR', 'Human Resources'),

-- WM - Warehouse Management Tiles
('Stock Review', 'View inventory levels', 'package', 'bg-teal-600', '/inventory', '{admin,storekeeper}', 70, 'WM_STK_REVIEW', 'REVIEW', 'WM', 'Warehouse'),
('Stock Transfer', 'Transfer materials', 'truck', 'bg-orange-600', '/inventory/transfer', '{admin,storekeeper}', 71, 'WM_STK_TRANSFER', 'EXECUTE', 'WM', 'Warehouse'),
('Store Management', 'Manage warehouses', 'warehouse', 'bg-stone-600', '/stores', '{admin,storekeeper}', 72, 'WM_STR_MANAGE', 'MODIFY', 'WM', 'Warehouse');

-- Create function to get authorized tiles for user
CREATE OR REPLACE FUNCTION get_user_authorized_tiles(p_user_id UUID)
RETURNS TABLE (
    tile_id UUID,
    title VARCHAR(100),
    subtitle VARCHAR(200),
    icon VARCHAR(50),
    color VARCHAR(20),
    route VARCHAR(200),
    module_code VARCHAR(2),
    tile_category VARCHAR(50),
    construction_action VARCHAR(20),
    has_authorization BOOLEAN
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
        t.module_code,
        t.tile_category,
        t.construction_action,
        CASE 
            WHEN t.auth_object IS NOT NULL THEN
                check_construction_authorization(
                    p_user_id,
                    t.auth_object,
                    t.construction_action,
                    '{}'::jsonb
                )
            ELSE true
        END as has_authorization
    FROM tiles t
    WHERE t.is_active = true
    ORDER BY t.module_code, t.sequence_order;
END;
$$ LANGUAGE plpgsql;

-- Create tile categories summary
CREATE TABLE IF NOT EXISTS tile_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_name VARCHAR(50) UNIQUE NOT NULL,
    module_code VARCHAR(2) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(20),
    sequence_order INTEGER DEFAULT 0
);

-- Insert tile categories
INSERT INTO tile_categories (category_name, module_code, description, icon, color, sequence_order) VALUES
('Project Management', 'PS', 'Project planning and execution', 'building-2', 'bg-blue-500', 1),
('Procurement', 'MM', 'Purchase orders and sourcing', 'shopping-cart', 'bg-orange-500', 2),
('Materials', 'MM', 'Material master and inventory', 'box', 'bg-indigo-500', 3),
('Planning', 'PP', 'Activity and task planning', 'calendar', 'bg-violet-500', 4),
('Execution', 'PP', 'Work execution and progress', 'play-circle', 'bg-emerald-500', 5),
('Quality', 'QM', 'Quality control and BOQ', 'shield-check', 'bg-red-500', 6),
('Finance', 'FI', 'Financial management', 'dollar-sign', 'bg-green-700', 7),
('Time Management', 'HR', 'Timesheet and attendance', 'clock', 'bg-indigo-600', 8),
('Human Resources', 'HR', 'Employee management', 'user-cog', 'bg-gray-700', 9),
('Warehouse', 'WM', 'Inventory and stores', 'warehouse', 'bg-stone-600', 10)
ON CONFLICT (category_name) DO NOTHING;