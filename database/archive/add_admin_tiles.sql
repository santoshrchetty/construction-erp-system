-- Add Admin Functionality Tiles to ERP Modules
-- =============================================

-- Insert Admin/Master Data tiles
INSERT INTO tiles (title, subtitle, icon, color, route, roles, sequence_order, auth_object, construction_action, module_code, tile_category) VALUES

-- Materials Management - Master Data
('Material Master', 'Manage materials & specifications', 'box', 'bg-indigo-500', '#', '{admin,procurement}', 23, 'MM_MAT_MASTER', 'MODIFY', 'MM', 'Materials'),
('Vendor Master', 'Manage suppliers & contractors', 'users', 'bg-cyan-500', '#', '{admin,procurement}', 24, 'MM_VEN_MANAGE', 'MODIFY', 'MM', 'Procurement'),

-- Warehouse Management
('Inventory Management', 'Stock management & tracking', 'package', 'bg-teal-600', '#', '{admin,storekeeper}', 70, 'WM_STK_REVIEW', 'REVIEW', 'WM', 'Warehouse'),

-- Configuration & Setup
('SAP Configuration', 'Organizational structure setup', 'settings', 'bg-gray-600', '#', '{admin}', 80, 'PS_PRJ_INITIATE', 'INITIATE', 'CF', 'Configuration'),
('ERP Configuration', 'Material Types, Account Determination', 'settings', 'bg-blue-600', '#', '{admin}', 81, 'PS_PRJ_INITIATE', 'INITIATE', 'CF', 'Configuration');

-- Verify new admin tiles
SELECT 'NEW ADMIN TILES' as status, title, tile_category, module_code FROM tiles 
WHERE title IN ('Material Master', 'Vendor Master', 'Inventory Management', 'SAP Configuration', 'ERP Configuration')
ORDER BY tile_category, sequence_order;