-- Step 3: Construction Management Module Framework
-- ===============================================

-- Replace existing authorization objects with construction-native ones
DELETE FROM user_authorizations;
DELETE FROM authorization_fields;
DELETE FROM authorization_objects;

-- Insert Construction Management Authorization Objects
INSERT INTO authorization_objects (object_name, description, module) VALUES

-- PS - Project System
('PS_PRJ_INITIATE', 'Project Initiation Authorization', 'projects'),
('PS_PRJ_MODIFY', 'Project Modification Authorization', 'projects'),
('PS_PRJ_REVIEW', 'Project Review Authorization', 'projects'),
('PS_WBS_CREATE', 'WBS Structure Creation', 'projects'),
('PS_WBS_MODIFY', 'WBS Structure Modification', 'projects'),

-- MM - Materials Management
('MM_PO_CREATE', 'Purchase Order Creation', 'procurement'),
('MM_PO_MODIFY', 'Purchase Order Modification', 'procurement'),
('MM_PO_APPROVE', 'Purchase Order Approval', 'procurement'),
('MM_GRN_EXECUTE', 'Goods Receipt Processing', 'inventory'),
('MM_MAT_MASTER', 'Material Master Maintenance', 'materials'),
('MM_VEN_MANAGE', 'Vendor Management', 'procurement'),

-- PP - Production Planning
('PP_ACT_SCHEDULE', 'Activity Scheduling', 'activities'),
('PP_ACT_EXECUTE', 'Activity Execution', 'activities'),
('PP_TSK_ASSIGN', 'Task Assignment', 'tasks'),
('PP_TSK_UPDATE', 'Task Progress Update', 'tasks'),

-- QM - Quality Management
('QM_BOQ_REVIEW', 'BOQ Review Authorization', 'boq'),
('QM_BOQ_MODIFY', 'BOQ Modification Authorization', 'boq'),
('QM_QC_EXECUTE', 'Quality Control Execution', 'quality'),

-- FI - Financial Accounting
('FI_CST_REVIEW', 'Cost Review Authorization', 'finance'),
('FI_INV_PROCESS', 'Invoice Processing', 'finance'),

-- CO - Controlling
('CO_BDG_MODIFY', 'Budget Modification', 'finance'),
('CO_CTC_ANALYZE', 'Cost-to-Complete Analysis', 'finance'),
('CO_CST_ALLOCATE', 'Cost Allocation', 'finance'),

-- HR - Human Resources
('HR_TMS_EXECUTE', 'Timesheet Execution', 'timesheets'),
('HR_TMS_APPROVE', 'Timesheet Approval', 'timesheets'),
('HR_EMP_MANAGE', 'Employee Management', 'employees'),

-- WM - Warehouse Management
('WM_STK_REVIEW', 'Stock Review', 'inventory'),
('WM_STK_TRANSFER', 'Stock Transfer', 'inventory'),
('WM_STR_MANAGE', 'Store Management', 'stores');

-- Insert Authorization Fields with Construction Actions
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values) VALUES

-- Construction Actions (replacing SAP activity codes)
((SELECT id FROM authorization_objects WHERE object_name = 'PS_PRJ_INITIATE'), 'ACTION', 'Construction Action', ARRAY['INITIATE']),
((SELECT id FROM authorization_objects WHERE object_name = 'PS_PRJ_MODIFY'), 'ACTION', 'Construction Action', ARRAY['MODIFY']),
((SELECT id FROM authorization_objects WHERE object_name = 'PS_PRJ_REVIEW'), 'ACTION', 'Construction Action', ARRAY['REVIEW']),
((SELECT id FROM authorization_objects WHERE object_name = 'MM_PO_APPROVE'), 'ACTION', 'Construction Action', ARRAY['APPROVE']),
((SELECT id FROM authorization_objects WHERE object_name = 'PP_ACT_EXECUTE'), 'ACTION', 'Construction Action', ARRAY['EXECUTE']),
((SELECT id FROM authorization_objects WHERE object_name = 'QM_QC_EXECUTE'), 'ACTION', 'Construction Action', ARRAY['EXECUTE']),
((SELECT id FROM authorization_objects WHERE object_name = 'HR_TMS_APPROVE'), 'ACTION', 'Construction Action', ARRAY['APPROVE']),

-- Project Type Context
((SELECT id FROM authorization_objects WHERE object_name = 'PS_PRJ_INITIATE'), 'PROJ_TYPE', 'Project Type', ARRAY['commercial', 'residential', 'infrastructure']),
((SELECT id FROM authorization_objects WHERE object_name = 'PS_PRJ_MODIFY'), 'PROJ_TYPE', 'Project Type', ARRAY['commercial', 'residential', 'infrastructure']),
((SELECT id FROM authorization_objects WHERE object_name = 'PS_PRJ_REVIEW'), 'PROJ_TYPE', 'Project Type', ARRAY['commercial', 'residential', 'infrastructure']),

-- Purchase Order Type Context
((SELECT id FROM authorization_objects WHERE object_name = 'MM_PO_CREATE'), 'PO_TYPE', 'PO Type', ARRAY['standard', 'blanket', 'contract', 'emergency']),
((SELECT id FROM authorization_objects WHERE object_name = 'MM_PO_MODIFY'), 'PO_TYPE', 'PO Type', ARRAY['standard', 'blanket', 'contract']),
((SELECT id FROM authorization_objects WHERE object_name = 'MM_PO_APPROVE'), 'PO_TYPE', 'PO Type', ARRAY['standard', 'blanket', 'contract', 'emergency']);

-- Update role mappings with new construction objects
DELETE FROM role_authorization_mapping;

INSERT INTO role_authorization_mapping (role_name, auth_object_name, field_values) VALUES

-- ADMIN - Full construction management access
('Admin', 'PS_PRJ_INITIATE', '{"ACTION": ["INITIATE"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Admin', 'PS_PRJ_MODIFY', '{"ACTION": ["MODIFY"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Admin', 'PS_PRJ_REVIEW', '{"ACTION": ["REVIEW"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Admin', 'MM_PO_CREATE', '{"ACTION": ["INITIATE"], "PO_TYPE": ["standard", "blanket", "contract", "emergency"]}'),
('Admin', 'MM_PO_APPROVE', '{"ACTION": ["APPROVE"], "PO_TYPE": ["standard", "blanket", "contract", "emergency"]}'),
('Admin', 'PP_ACT_SCHEDULE', '{"ACTION": ["INITIATE"]}'),
('Admin', 'PP_ACT_EXECUTE', '{"ACTION": ["EXECUTE"]}'),
('Admin', 'QM_BOQ_MODIFY', '{"ACTION": ["MODIFY"]}'),
('Admin', 'CO_BDG_MODIFY', '{"ACTION": ["MODIFY"]}'),
('Admin', 'HR_TMS_APPROVE', '{"ACTION": ["APPROVE"]}'),

-- MANAGER - Project and approval focus
('Manager', 'PS_PRJ_INITIATE', '{"ACTION": ["INITIATE"], "PROJ_TYPE": ["commercial", "residential"]}'),
('Manager', 'PS_PRJ_MODIFY', '{"ACTION": ["MODIFY"], "PROJ_TYPE": ["commercial", "residential"]}'),
('Manager', 'PS_PRJ_REVIEW', '{"ACTION": ["REVIEW"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Manager', 'MM_PO_APPROVE', '{"ACTION": ["APPROVE"], "PO_TYPE": ["standard", "blanket"]}'),
('Manager', 'PP_ACT_SCHEDULE', '{"ACTION": ["INITIATE"]}'),
('Manager', 'CO_CTC_ANALYZE', '{"ACTION": ["REVIEW"]}'),
('Manager', 'HR_TMS_APPROVE', '{"ACTION": ["APPROVE"]}'),

-- PROCUREMENT - Materials and purchasing
('Procurement', 'PS_PRJ_REVIEW', '{"ACTION": ["REVIEW"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Procurement', 'MM_PO_CREATE', '{"ACTION": ["INITIATE"], "PO_TYPE": ["standard", "blanket", "contract"]}'),
('Procurement', 'MM_PO_MODIFY', '{"ACTION": ["MODIFY"], "PO_TYPE": ["standard", "blanket", "contract"]}'),
('Procurement', 'MM_MAT_MASTER', '{"ACTION": ["MODIFY"]}'),
('Procurement', 'MM_VEN_MANAGE', '{"ACTION": ["MODIFY"]}'),

-- ENGINEER - Execution and progress
('Engineer', 'PS_PRJ_REVIEW', '{"ACTION": ["REVIEW"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Engineer', 'PP_ACT_EXECUTE', '{"ACTION": ["EXECUTE"]}'),
('Engineer', 'PP_TSK_UPDATE', '{"ACTION": ["EXECUTE"]}'),
('Engineer', 'QM_BOQ_REVIEW', '{"ACTION": ["REVIEW"]}'),
('Engineer', 'HR_TMS_EXECUTE', '{"ACTION": ["EXECUTE"]}'),

-- STOREKEEPER - Warehouse operations
('Storekeeper', 'MM_GRN_EXECUTE', '{"ACTION": ["EXECUTE"]}'),
('Storekeeper', 'WM_STK_REVIEW', '{"ACTION": ["REVIEW"]}'),
('Storekeeper', 'WM_STK_TRANSFER', '{"ACTION": ["EXECUTE"]}'),
('Storekeeper', 'WM_STR_MANAGE', '{"ACTION": ["MODIFY"]}'),

-- FINANCE - Financial control
('Finance', 'PS_PRJ_REVIEW', '{"ACTION": ["REVIEW"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Finance', 'MM_PO_APPROVE', '{"ACTION": ["APPROVE"], "PO_TYPE": ["standard", "blanket", "contract"]}'),
('Finance', 'FI_CST_REVIEW', '{"ACTION": ["REVIEW"]}'),
('Finance', 'CO_BDG_MODIFY', '{"ACTION": ["MODIFY"]}'),
('Finance', 'CO_CTC_ANALYZE', '{"ACTION": ["REVIEW"]}'),

-- HR - Human resources
('HR', 'PS_PRJ_REVIEW', '{"ACTION": ["REVIEW"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('HR', 'HR_TMS_APPROVE', '{"ACTION": ["APPROVE"]}'),
('HR', 'HR_EMP_MANAGE', '{"ACTION": ["MODIFY"]}'),

-- EMPLOYEE - Basic execution
('Employee', 'PS_PRJ_REVIEW', '{"ACTION": ["REVIEW"], "PROJ_TYPE": ["commercial", "residential", "infrastructure"]}'),
('Employee', 'HR_TMS_EXECUTE', '{"ACTION": ["EXECUTE"]}'),
('Employee', 'PP_TSK_UPDATE', '{"ACTION": ["EXECUTE"]}');