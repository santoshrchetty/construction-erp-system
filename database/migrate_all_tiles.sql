-- Complete tiles migration script - All 88 original tiles
-- Clear dependent tables first
DELETE FROM tile_workflow_status;
-- Clear existing tiles
DELETE FROM tiles;

-- Insert all 88 tiles
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
-- Finance tiles (15 tiles)
('GL Account Posting', 'Post journal entries to general ledger', 'dollar-sign', 'FI', 'gl_posting', '/finance/gl-posting', 'Finance', 'FI_GL_POST'),
('Trial Balance', 'Generate trial balance report', 'bar-chart-3', 'FI', 'trial_balance', '/finance/trial-balance', 'Finance', 'FI_GL_DISP'),
('Chart of Accounts', 'Manage chart of accounts', 'file-text', 'FI', 'chart_of_accounts', '/finance/chart-accounts', 'Finance', 'FI_COA_DISP'),
('Profit & Loss Statement', 'Generate P&L reports', 'trending-up', 'FI', 'profit_loss', '/finance/profit-loss', 'Finance', 'FI_PL_DISP'),
('Financial Reports', 'Generate financial reports', 'pie-chart', 'FI', 'reports', '/finance/reports', 'Finance', 'FI_REP_DISP'),
('Cost Center Accounting', 'Manage cost centers', 'target', 'CO', 'cost-center', '/controlling/cost-centers', 'Finance', 'CO_CC_DISP'),
('Budget Planning', 'Plan and monitor budgets', 'calculator', 'CO', 'budget', '/controlling/budget', 'Finance', 'CO_BUD_PLAN'),
('Asset Accounting', 'Manage fixed assets', 'home', 'FI', 'assets', '/finance/assets', 'Finance', 'FI_AA_DISP'),
('Accounts Payable', 'Manage vendor invoices', 'credit-card', 'FI', 'accounts-payable', '/finance/ap', 'Finance', 'FI_AP_DISP'),
('Accounts Receivable', 'Manage customer invoices', 'receipt', 'FI', 'accounts-receivable', '/finance/ar', 'Finance', 'FI_AR_DISP'),
('Bank Reconciliation', 'Reconcile bank statements', 'landmark', 'FI', 'bank-reconciliation', '/finance/bank', 'Finance', 'FI_BANK_RECON'),
('Tax Management', 'Manage tax calculations', 'percent', 'FI', 'tax-management', '/finance/tax', 'Finance', 'FI_TAX_CALC'),
('Cash Flow Analysis', 'Analyze cash flow', 'trending-down', 'FI', 'cash-flow', '/finance/cashflow', 'Finance', 'FI_CF_ANAL'),
('Financial Closing', 'Period end closing', 'lock', 'FI', 'period-closing', '/finance/closing', 'Finance', 'FI_CLOSE'),
('Audit Trail', 'Financial audit reports', 'search', 'FI', 'audit-trail', '/finance/audit', 'Finance', 'FI_AUDIT'),

-- Materials tiles (12 tiles)
('Inventory Stock Levels', 'View current material stock levels and status', 'package', 'MM', 'stock-overview', '/materials/stock', 'Materials', 'MM_STK_OVERVIEW'),
('Create Material Master', 'Create new material master records', 'plus-circle', 'MM', 'create-material', '/materials/create', 'Materials', 'MM_MAT_CREATE'),
('Maintain Material Master', 'Update material master records', 'edit', 'MM', 'maintain-material', '/materials/maintain', 'Materials', 'MM_MAT_CHANGE'),
('Display Material Master', 'View material master data', 'eye', 'MM', 'material-master', '/materials/display', 'Materials', 'MM_MAT_DISPLAY'),
('Bulk Upload Materials', 'Upload materials via Excel/CSV', 'upload', 'MM', 'bulk-upload', '/materials/bulk-upload', 'Materials', 'MM_BULK_UP'),
('Material Search', 'Search materials by criteria', 'search', 'MM', 'material-search', '/materials/search', 'Materials', 'MM_MAT_SEARCH'),
('Material Reservations', 'Reserve materials for projects', 'bookmark', 'MM', 'material-reservations', '/materials/reservations', 'Materials', 'MM_RES_CREATE'),
('Material Valuation', 'Material price management', 'tag', 'MM', 'material-valuation', '/materials/valuation', 'Materials', 'MM_VAL_DISP'),
('Material Classification', 'Classify materials by type', 'grid', 'MM', 'material-classification', '/materials/classification', 'Materials', 'MM_CLASS'),
('Material BOM', 'Bill of materials management', 'list', 'PP', 'material-bom', '/materials/bom', 'Materials', 'PP_BOM_DISP'),
('Material Forecast', 'Material demand forecasting', 'activity', 'MM', 'material-forecast', '/materials/forecast', 'Materials', 'MM_FORECAST'),
('Material Reports', 'Material analysis reports', 'bar-chart', 'MM', 'material-reports', '/materials/reports', 'Materials', 'MM_REP_DISP'),

-- Procurement tiles (10 tiles)
('Purchase Orders', 'Create and manage purchase orders', 'shopping-cart', 'MM', 'create_po', '/procurement/create-po', 'Procurement', 'MM_PO_CREATE'),
('PO Approvals', 'Approve purchase orders', 'check-circle', 'MM', 'approve_po', '/procurement/approvals', 'Procurement', 'MM_PO_APPROVE'),
('Purchase Requisitions', 'Create purchase requisitions', 'file-plus', 'MM', 'purchase-requisitions', '/procurement/pr', 'Procurement', 'MM_PR_CREATE'),
('Vendor Master', 'Manage vendor information', 'users', 'MM', 'vendor-master', '/procurement/vendors', 'Procurement', 'MM_VEN_DISP'),
('RFQ Management', 'Request for quotations', 'mail', 'MM', 'rfq-management', '/procurement/rfq', 'Procurement', 'MM_RFQ_CREATE'),
('Contract Management', 'Manage procurement contracts', 'file-text', 'MM', 'contract-management', '/procurement/contracts', 'Procurement', 'MM_CONT_DISP'),
('Vendor Evaluation', 'Evaluate vendor performance', 'star', 'MM', 'vendor-evaluation', '/procurement/evaluation', 'Procurement', 'MM_VEN_EVAL'),
('Purchase Analytics', 'Procurement analytics', 'pie-chart', 'MM', 'purchase-analytics', '/procurement/analytics', 'Procurement', 'MM_PUR_ANAL'),
('Source List', 'Manage approved sources', 'check-square', 'MM', 'source-list', '/procurement/sources', 'Procurement', 'MM_SRC_LIST'),
('PO Overview', 'Purchase order overview', 'clipboard', 'MM', 'po_overview', '/procurement/overview', 'Procurement', 'MM_PO_DISP'),

-- Inventory/Warehouse tiles (12 tiles)
('Goods Receipt', 'Record goods receipts', 'truck', 'WM', 'goods-receipt', '/inventory/goods-receipt', 'Inventory', 'WM_GR_POST'),
('Goods Issue', 'Issue materials to projects', 'box', 'WM', 'goods-issue', '/inventory/goods-issue', 'Inventory', 'WM_GI_POST'),
('Goods Transfer', 'Transfer materials between locations', 'arrow-right', 'WM', 'goods-transfer', '/inventory/goods-transfer', 'Inventory', 'WM_GT_POST'),
('Physical Inventory', 'Conduct physical inventory counts', 'clipboard-check', 'WM', 'physical-inventory', '/inventory/physical', 'Inventory', 'WM_PI_POST'),
('Inventory Adjustments', 'Adjust inventory quantities', 'edit-3', 'WM', 'inventory-adjustments', '/inventory/adjustments', 'Inventory', 'WM_ADJ_POST'),
('Inventory Management', 'Overall inventory management', 'package', 'WM', 'inventory-management', '/inventory/management', 'Inventory', 'WM_INV_DISP'),
('Warehouse Overview', 'Warehouse operations overview', 'warehouse', 'WM', 'overview', '/warehouse/overview', 'Warehouse', 'WM_WH_DISP'),
('Stock Movement', 'Track stock movements', 'move', 'WM', 'stock-movement', '/warehouse/movements', 'Warehouse', 'WM_MOV_DISP'),
('Movement History', 'View movement history', 'history', 'WM', 'movement-history', '/warehouse/history', 'Warehouse', 'WM_HIST_DISP'),
('Bin Management', 'Manage storage bins', 'grid-3x3', 'WM', 'bin-management', '/warehouse/bins', 'Warehouse', 'WM_BIN_MAINT'),
('Cycle Counting', 'Perform cycle counts', 'rotate-cw', 'WM', 'cycle-counting', '/warehouse/cycle-count', 'Warehouse', 'WM_CC_POST'),
('Warehouse Reports', 'Warehouse analysis reports', 'bar-chart-2', 'WM', 'warehouse-reports', '/warehouse/reports', 'Warehouse', 'WM_REP_DISP'),

-- Project Management tiles (10 tiles)
('Projects Dashboard', 'Manage construction projects', 'building', 'PS', 'project-overview', '/projects/dashboard', 'Project Management', 'PS_PRJ_REVIEW'),
('Create Project', 'Create new projects', 'plus-square', 'PS', 'create-project', '/projects/create', 'Project Management', 'PS_PROJ_CREATE'),
('WBS Management', 'Manage work breakdown structure', 'git-branch', 'PS', 'wbs-management', '/projects/wbs', 'Project Management', 'PS_WBS_CHANGE'),
('Activities', 'Manage project activities', 'list', 'PS', 'activities', '/projects/activities', 'Project Management', 'PS_ACT_EXECUTE'),
('Tasks', 'Manage project tasks', 'check-square', 'PS', 'tasks', '/projects/tasks', 'Project Management', 'PS_TSK_MANAGE'),
('Schedule', 'Project scheduling', 'calendar', 'PS', 'schedule', '/projects/schedule', 'Project Management', 'PS_SCHED_DISP'),
('Cost Management', 'Project cost management', 'dollar-sign', 'PS', 'cost-management', '/projects/costs', 'Project Management', 'PS_COST_DISP'),
('Project Cost Analysis', 'Analyze project costs', 'trending-up', 'CO', 'project-cost-analysis', '/controlling/project-costs', 'Project Management', 'CO_PROJ_ANAL'),
('Resource Planning', 'Plan project resources', 'users', 'PS', 'resource-planning', '/projects/resources', 'Project Management', 'PS_RES_PLAN'),
('Reports', 'Project reports and analytics', 'file-text', 'PS', 'reports', '/projects/reports', 'Project Management', 'PS_REP_DISP'),

-- Human Resources tiles (8 tiles)
('Employee Overview', 'Manage employee information', 'user', 'HR', 'employee-overview', '/hr/employees', 'Human Resources', 'HR_EMP_DISP'),
('Create Employee', 'Add new employees', 'user-plus', 'HR', 'create-employee', '/hr/create-employee', 'Human Resources', 'HR_EMP_CREATE'),
('Timesheet Overview', 'View employee timesheets', 'clock', 'HR', 'timesheet-overview', '/hr/timesheets', 'Human Resources', 'HR_TIME_DISP'),
('Timesheet Approval', 'Approve employee timesheets', 'check-circle', 'HR', 'timesheet-approval', '/hr/timesheet-approval', 'Human Resources', 'HR_TIME_APPR'),
('Attendance Tracking', 'Track employee attendance', 'calendar-check', 'HR', 'attendance-tracking', '/hr/attendance', 'Human Resources', 'HR_ATT_TRACK'),
('Leave Management', 'Manage employee leave', 'calendar-x', 'HR', 'leave-management', '/hr/leave', 'Human Resources', 'HR_LEAVE_MGMT'),
('Payroll Processing', 'Process employee payroll', 'credit-card', 'HR', 'payroll-processing', '/hr/payroll', 'Human Resources', 'HR_PAY_PROC'),
('HR Reports', 'Human resources reports', 'users', 'HR', 'hr-reports', '/hr/reports', 'Human Resources', 'HR_REP_DISP'),

-- Quality tiles (6 tiles)
('Quality Inspections', 'Manage quality inspections', 'search', 'QM', 'inspections', '/quality/inspections', 'Quality', 'QM_INSP_DISP'),
('Create Inspection', 'Create quality inspections', 'plus-circle', 'QM', 'create-inspection', '/quality/create-inspection', 'Quality', 'QM_INSP_CREATE'),
('Quality Reports', 'Quality analysis reports', 'bar-chart', 'QM', 'quality-reports', '/quality/reports', 'Quality', 'QM_REP_DISP'),
('Compliance Check', 'Quality compliance monitoring', 'shield-check', 'QM', 'compliance-check', '/quality/compliance', 'Quality', 'QM_COMP_CHECK'),
('Quality Control', 'Quality control processes', 'check-circle-2', 'QM', 'quality-control', '/quality/control', 'Quality', 'QM_QC_PROC'),
('Quality Certificates', 'Manage quality certificates', 'award', 'QM', 'quality-certificates', '/quality/certificates', 'Quality', 'QM_CERT_MGMT'),

-- Safety tiles (6 tiles)
('Safety Incidents', 'Manage safety incidents', 'alert-triangle', 'EH', 'incidents', '/safety/incidents', 'Safety', 'EHS_INC_DISP'),
('Create Incident', 'Report safety incidents', 'alert-circle', 'EH', 'create-incident', '/safety/create-incident', 'Safety', 'EHS_INC_CREATE'),
('Safety Compliance', 'Safety compliance monitoring', 'shield', 'EH', 'compliance', '/safety/compliance', 'Safety', 'EHS_COMP_MON'),
('Safety Training', 'Safety training management', 'graduation-cap', 'EH', 'safety-training', '/safety/training', 'Safety', 'EHS_TRAIN_MGMT'),
('Safety Audits', 'Conduct safety audits', 'clipboard-list', 'EH', 'safety-audits', '/safety/audits', 'Safety', 'EHS_AUDIT_COND'),
('Safety Reports', 'Safety analysis reports', 'file-bar-chart', 'EH', 'safety-reports', '/safety/reports', 'Safety', 'EHS_REP_DISP'),

-- Administration tiles (6 tiles)
('User Management', 'Manage system users', 'users', 'AD', 'user-management', '/admin/users', 'Administration', 'ADMIN_USER_MGMT'),
('Role Management', 'Manage user roles', 'shield', 'AD', 'role-management', '/admin/roles', 'Administration', 'ADMIN_ROLE_MGMT'),
('User Role Assignment', 'Assign roles to users', 'user-check', 'AD', 'assign-role', '/admin/assign-roles', 'Administration', 'ADMIN_ROLE_ASSIGN'),
('Authorization Objects', 'Manage SAP-style authorization objects', 'shield-check', 'AD', 'auth-objects', '/admin/auth-objects', 'Administration', 'ADMIN_AUTH_MGMT'),
('System Configuration', 'Configure system settings', 'settings', 'AD', 'system-config', '/admin/config', 'Administration', 'ADMIN_SYS_CONFIG'),
('Audit Logs', 'View system audit logs', 'file-text', 'AD', 'audit-logs', '/admin/audit', 'Administration', 'ADMIN_AUDIT_VIEW'),

-- Configuration tiles (3 tiles)
('SAP Configuration', 'Configure SAP integration settings', 'settings', 'CF', 'sap-config', '/config/sap', 'Configuration', 'CONFIG_SAP'),
('ERP Configuration', 'Configure ERP system settings', 'database', 'CF', 'erp-config', '/config/erp', 'Configuration', 'CONFIG_ERP'),
('System Parameters', 'Manage system parameters', 'sliders', 'CF', 'system-params', '/config/params', 'Configuration', 'CONFIG_PARAMS');

-- Verify the migration
SELECT tile_category, COUNT(*) as count 
FROM tiles 
GROUP BY tile_category 
ORDER BY tile_category;