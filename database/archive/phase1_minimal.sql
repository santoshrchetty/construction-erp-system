-- Phase 1: Minimal Role Expansion
-- ================================

-- Create roles with very short names
INSERT INTO roles (name, description, is_active) VALUES
('SiteEng', 'Site engineering', true),
('ProjMgr', 'Project management', true),
('ProcMgr', 'Procurement', true),
('StoreKeep', 'Warehouse', true),
('FinMgr', 'Finance', true),
('QualMgr', 'Quality', true),
('SafetyOff', 'Safety', true),
('PlanEng', 'Planning', true)
ON CONFLICT (name) DO NOTHING;

-- Create minimal auth objects
INSERT INTO authorization_objects (object_name, description, module, is_active) VALUES
('QM_INSPECT', 'Quality Inspections', 'quality', true),
('QM_NCR', 'Non-Conformance Reports', 'quality', true),
('HR_EMP', 'Employee Management', 'hr', true),
('HR_PAY', 'Payroll', 'hr', true),
('SF_INC', 'Safety Incidents', 'safety', true),
('SF_PERMIT', 'Work Permits', 'safety', true),
('DM_DRAW', 'Drawings', 'docs', true),
('DM_RFI', 'RFI Management', 'docs', true)
ON CONFLICT (object_name) DO NOTHING;

-- Assign minimal permissions with field_values
INSERT INTO role_authorization_mapping (role_name, auth_object_name, field_values) VALUES
('SiteEng', 'PS_PRJ_REVIEW', '{}'),
('SiteEng', 'QM_INSPECT', '{}'),
('ProjMgr', 'PS_PRJ_INITIATE', '{}'),
('ProjMgr', 'PS_WBS_CREATE', '{}'),
('ProjMgr', 'MM_PO_APPROVE', '{}'),
('ProcMgr', 'MM_PO_CREATE', '{}'),
('ProcMgr', 'MM_VEN_CREATE', '{}'),
('StoreKeep', 'WM_STK_VIEW', '{}'),
('FinMgr', 'FI_INV_PROCESS', '{}'),
('QualMgr', 'QM_INSPECT', '{}'),
('SafetyOff', 'SF_INC', '{}'),
('PlanEng', 'PS_ACT_SCHEDULE', '{}')
ON CONFLICT (role_name, auth_object_name) DO NOTHING;

-- Verify
SELECT r.name, COUNT(ram.auth_object_name) as auth_count
FROM roles r
LEFT JOIN role_authorization_mapping ram ON r.name = ram.role_name
WHERE r.name IN ('SiteEng', 'ProjMgr', 'ProcMgr', 'StoreKeep', 'FinMgr', 'QualMgr', 'SafetyOff', 'PlanEng')
GROUP BY r.name;