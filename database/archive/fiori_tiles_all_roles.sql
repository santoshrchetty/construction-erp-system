-- Fiori-Style Tiles for Construction ERP Roles
-- ============================================

-- A. SITE ENGINEER / PLANNING ENGINEER TILES
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('Create Material Reservation', 'Reserve materials for activities', 'Package2', 'bg-blue-500', '/materials/reservations/create', 'MM', 'Materials Planning', 'CREATE', 'MM_MAT_RESERVE', 101, true),
('My Reservations', 'View and modify my reservations', 'ClipboardList', 'bg-green-500', '/materials/reservations/my', 'MM', 'Materials Planning', 'DISPLAY', 'MM_MAT_RESERVE', 102, true),
('Material Availability Check', 'Check stock vs requirements', 'Search', 'bg-yellow-500', '/materials/availability', 'MM', 'Materials Planning', 'DISPLAY', 'MM_STK_CHECK', 103, true),
('Activity Material Requirements', 'BOQ-based material planning', 'Calculator', 'bg-purple-500', '/planning/material-requirements', 'PS', 'Project Planning', 'DISPLAY', 'PS_ACT_PLAN', 104, true),
('Goods Issue to Project', 'Issue materials to WBS/Activity', 'ArrowRight', 'bg-orange-500', '/inventory/goods-issue', 'MM', 'Inventory Management', 'EXECUTE', 'MM_GI_PROJECT', 105, true);

-- B. PROJECT MANAGER TILES
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('Approve Material Reservations', 'Review and approve reservations', 'CheckCircle', 'bg-green-600', '/materials/reservations/approve', 'MM', 'Approvals', 'APPROVE', 'MM_MAT_APPROVE', 201, true),
('Project Material Forecast', 'Material requirements by timeline', 'TrendingUp', 'bg-blue-600', '/planning/material-forecast', 'PS', 'Project Planning', 'DISPLAY', 'PS_PRJ_PLAN', 202, true),
('MRP Shortage Monitor', 'Material shortages and procurement', 'AlertTriangle', 'bg-red-500', '/planning/mrp-shortage', 'PP', 'Planning', 'MONITOR', 'PP_MRP_MONITOR', 203, true),
('Project Cost Consumption', 'Material costs by WBS element', 'DollarSign', 'bg-indigo-500', '/finance/project-costs', 'CO', 'Controlling', 'DISPLAY', 'CO_PRJ_COSTS', 204, true),
('Convert Planned PRs', 'Convert planned PRs to requisitions', 'RefreshCw', 'bg-teal-500', '/procurement/convert-planned-pr', 'MM', 'Procurement Planning', 'CONVERT', 'MM_PPR_CONVERT', 205, true);

-- C. PROCUREMENT OFFICER TILES
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('Create Purchase Requisition', 'Create PR from reservations', 'FileText', 'bg-blue-500', '/procurement/pr/create', 'MM', 'Procurement', 'CREATE', 'MM_PR_CREATE', 301, true),
('PR Approval Workflow', 'Approve purchase requisitions', 'CheckSquare', 'bg-green-500', '/procurement/pr/approve', 'MM', 'Procurement', 'APPROVE', 'MM_PR_APPROVE', 302, true),
('Convert PR to PO', 'Create purchase orders from PRs', 'ArrowRight', 'bg-purple-500', '/procurement/pr-to-po', 'MM', 'Procurement', 'CONVERT', 'MM_PR_TO_PO', 303, true),
('Vendor Performance Monitor', 'Track delivery and quality KPIs', 'BarChart3', 'bg-orange-500', '/procurement/vendor-performance', 'MM', 'Vendor Management', 'MONITOR', 'MM_VEN_MONITOR', 304, true),
('Planned PR Dashboard', 'MRP-generated procurement proposals', 'Calendar', 'bg-cyan-500', '/procurement/planned-pr', 'PP', 'Planning', 'DISPLAY', 'PP_PPR_DISPLAY', 305, true);

-- D. FINANCE CONTROLLER TILES
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('PO Financial Approval', 'Approve high-value purchase orders', 'DollarSign', 'bg-red-600', '/finance/po-approval', 'MM', 'Financial Control', 'APPROVE', 'FI_PO_APPROVE', 401, true),
('Project Budget vs Actual', 'Budget consumption analysis', 'PieChart', 'bg-blue-600', '/finance/budget-analysis', 'CO', 'Controlling', 'DISPLAY', 'CO_BDG_ANALYSIS', 402, true),
('Material Cost Variance', 'Planned vs actual material costs', 'TrendingDown', 'bg-yellow-600', '/finance/cost-variance', 'CO', 'Controlling', 'DISPLAY', 'CO_VAR_ANALYSIS', 403, true),
('Cost Object Settlement', 'Settle costs to profit centers', 'Target', 'bg-green-600', '/finance/cost-settlement', 'CO', 'Controlling', 'EXECUTE', 'CO_SETTLEMENT', 404, true),
('Procurement Spend Analysis', 'Vendor and category spend analysis', 'BarChart', 'bg-indigo-600', '/finance/spend-analysis', 'FI', 'Financial Analysis', 'DISPLAY', 'FI_SPEND_ANALYSIS', 405, true);

-- E. STORES / INVENTORY MANAGER TILES
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('Goods Receipt Processing', 'Receive materials against POs', 'Package', 'bg-green-500', '/inventory/goods-receipt', 'MM', 'Inventory Management', 'EXECUTE', 'MM_GR_EXECUTE', 501, true),
('Stock Overview by Location', 'Current stock levels and locations', 'Warehouse', 'bg-blue-500', '/inventory/stock-overview', 'WM', 'Warehouse Management', 'DISPLAY', 'WM_STK_DISPLAY', 502, true),
('Material Reservation Monitor', 'Reserved vs available stock', 'Eye', 'bg-purple-500', '/inventory/reservation-monitor', 'MM', 'Inventory Management', 'MONITOR', 'MM_RES_MONITOR', 503, true),
('Stock Transfer Between Sites', 'Inter-location stock movements', 'Truck', 'bg-orange-500', '/inventory/stock-transfer', 'WM', 'Warehouse Management', 'EXECUTE', 'WM_STK_TRANSFER', 504, true),
('Inventory Valuation Report', 'Stock value by material and location', 'Calculator', 'bg-teal-500', '/inventory/valuation', 'FI', 'Inventory Accounting', 'DISPLAY', 'FI_INV_VALUATION', 505, true),
('Physical Inventory Count', 'Cycle counting and adjustments', 'ClipboardCheck', 'bg-yellow-500', '/inventory/physical-count', 'WM', 'Warehouse Management', 'EXECUTE', 'WM_PHY_COUNT', 506, true);

-- F. SYSTEM ADMIN TILES
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('MRP Run Configuration', 'Configure and execute MRP runs', 'Settings', 'bg-gray-600', '/admin/mrp-config', 'PP', 'System Administration', 'CONFIGURE', 'SY_MRP_CONFIG', 601, true),
('Material Master Maintenance', 'Create and maintain material masters', 'Database', 'bg-blue-600', '/admin/material-master', 'MM', 'Master Data', 'MAINTAIN', 'MM_MAT_MAINTAIN', 602, true),
('Cost Object Hierarchy', 'Maintain WBS and cost center hierarchy', 'GitBranch', 'bg-green-600', '/admin/cost-objects', 'CO', 'Master Data', 'MAINTAIN', 'CO_COST_MAINTAIN', 603, true),
('Authorization Management', 'User roles and permissions', 'Shield', 'bg-red-600', '/admin/authorization', 'SY', 'System Administration', 'MAINTAIN', 'SY_AUTH_MAINTAIN', 604, true);

-- TILE ANALYTICS AND KPI TILES
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('Material Requirement Forecast', 'AI-powered demand forecasting', 'Brain', 'bg-purple-600', '/analytics/demand-forecast', 'PP', 'Analytics', 'FORECAST', 'PP_FORECAST', 701, true),
('Procurement Performance KPIs', 'Lead times, costs, quality metrics', 'Activity', 'bg-cyan-600', '/analytics/procurement-kpis', 'MM', 'Analytics', 'MONITOR', 'MM_KPI_MONITOR', 702, true),
('Project Material Efficiency', 'Material utilization and waste analysis', 'Target', 'bg-lime-600', '/analytics/material-efficiency', 'PS', 'Analytics', 'ANALYZE', 'PS_EFFICIENCY', 703, true);

-- Update tile categories for better organization
UPDATE tiles SET tile_category = 'Materials Planning' WHERE module_code = 'MM' AND construction_action IN ('CREATE', 'DISPLAY', 'RESERVE');
UPDATE tiles SET tile_category = 'Procurement Management' WHERE module_code = 'MM' AND construction_action IN ('APPROVE', 'CONVERT');
UPDATE tiles SET tile_category = 'Financial Control' WHERE module_code IN ('FI', 'CO');
UPDATE tiles SET tile_category = 'Inventory Operations' WHERE module_code = 'WM';
UPDATE tiles SET tile_category = 'Planning & Analytics' WHERE module_code = 'PP';

SELECT 'FIORI-STYLE TILES CREATED FOR ALL ROLES' as status,
       COUNT(*) as total_tiles,
       COUNT(DISTINCT tile_category) as categories,
       COUNT(DISTINCT module_code) as modules
FROM tiles;