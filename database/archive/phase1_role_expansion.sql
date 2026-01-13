-- Phase 1: Construction Industry Role Expansion
-- ===============================================

-- Create additional construction industry roles
INSERT INTO roles (name, description, is_active) VALUES
('Site Engineer', 'Site-level engineering and quality oversight', true),
('Project Manager', 'Overall project management and coordination', true),
('Procurement Manager', 'Materials procurement and vendor management', true),
('Store Keeper', 'Warehouse and inventory management', true),
('Finance Manager', 'Financial control and budget management', true),
('Quality Manager', 'Quality assurance and compliance', true),
('Safety Officer', 'Health, safety, and environmental compliance', true),
('Planning Engineer', 'Project planning and scheduling', true)
ON CONFLICT (name) DO NOTHING;

-- Create Quality Management (QM) authorization objects
INSERT INTO authorization_objects (object_name, description, module, is_active) VALUES
('QM_INSPECT_CREATE', 'Create Quality Inspections', 'quality_management', true),
('QM_INSPECT_APPROVE', 'Approve Quality Inspections', 'quality_management', true),
('QM_NCR_CREATE', 'Create Non-Conformance Reports', 'quality_management', true),
('QM_NCR_RESOLVE', 'Resolve Non-Conformance Reports', 'quality_management', true),
('QM_TEST_CERT', 'Manage Test Certificates', 'quality_management', true),
('QM_MATERIAL_TEST', 'Material Testing Authorization', 'quality_management', true),
('QM_COMPLIANCE_VIEW', 'View Compliance Reports', 'quality_management', true)
ON CONFLICT (object_name) DO NOTHING;

-- Create Human Resources (HR) authorization objects
INSERT INTO authorization_objects (object_name, description, module, is_active) VALUES
('HR_EMP_MANAGE', 'Employee Management', 'human_resources', true),
('HR_ATTENDANCE', 'Attendance Management', 'human_resources', true),
('HR_PAYROLL_VIEW', 'View Payroll Information', 'human_resources', true),
('HR_PAYROLL_PROCESS', 'Process Payroll', 'human_resources', true),
('HR_TRAINING', 'Training and Certification Management', 'human_resources', true),
('HR_PERFORMANCE', 'Performance Management', 'human_resources', true)
ON CONFLICT (object_name) DO NOTHING;

-- Create Safety (SF) authorization objects
INSERT INTO authorization_objects (object_name, description, module, is_active) VALUES
('SF_INCIDENT_CREATE', 'Create Safety Incidents', 'safety', true),
('SF_INCIDENT_INVESTIGATE', 'Investigate Safety Incidents', 'safety', true),
('SF_PERMIT_ISSUE', 'Issue Work Permits', 'safety', true),
('SF_AUDIT_CONDUCT', 'Conduct Safety Audits', 'safety', true),
('SF_TRAINING_MANAGE', 'Manage Safety Training', 'safety', true),
('SF_COMPLIANCE_VIEW', 'View Safety Compliance', 'safety', true)
ON CONFLICT (object_name) DO NOTHING;

-- Create Document Management (DM) authorization objects
INSERT INTO authorization_objects (object_name, description, module, is_active) VALUES
('DM_DRAWING_VIEW', 'View Engineering Drawings', 'document_management', true),
('DM_DRAWING_APPROVE', 'Approve Engineering Drawings', 'document_management', true),
('DM_SPEC_MANAGE', 'Manage Specifications', 'document_management', true),
('DM_RFI_CREATE', 'Create Request for Information', 'document_management', true),
('DM_RFI_RESPOND', 'Respond to RFI', 'document_management', true),
('DM_SUBMITTAL_REVIEW', 'Review Submittals', 'document_management', true)
ON CONFLICT (object_name) DO NOTHING;

-- Assign authorization objects to roles
-- Site Engineer: PS + QM + limited MM + DM
INSERT INTO role_authorization_mapping (role_name, auth_object_name) VALUES
('Site Engineer', 'PS_PRJ_REVIEW'),
('Site Engineer', 'PS_WBS_MODIFY'),
('Site Engineer', 'PS_ACT_SCHEDULE'),
('Site Engineer', 'PS_ACT_EXECUTE'),
('Site Engineer', 'PS_TSK_MANAGE'),
('Site Engineer', 'QM_INSPECT_CREATE'),
('Site Engineer', 'QM_NCR_CREATE'),
('Site Engineer', 'QM_MATERIAL_TEST'),
('Site Engineer', 'MM_MAT_VIEW'),
('Site Engineer', 'DM_DRAWING_VIEW'),
('Site Engineer', 'DM_RFI_CREATE')
ON CONFLICT (role_name, auth_object_name) DO NOTHING;

-- Project Manager: PS + CO + MM + HR + limited FI
INSERT INTO role_authorization_mapping (role_name, auth_object_name) VALUES
('Project Manager', 'PS_PRJ_INITIATE'),
('Project Manager', 'PS_PRJ_MODIFY'),
('Project Manager', 'PS_PRJ_REVIEW'),
('Project Manager', 'PS_WBS_CREATE'),
('Project Manager', 'PS_WBS_MODIFY'),
('Project Manager', 'PS_ACT_SCHEDULE'),
('Project Manager', 'PS_TSK_ASSIGN'),
('Project Manager', 'PS_TSK_MANAGE'),
('Project Manager', 'CO_BDG_VIEW'),
('Project Manager', 'CO_BDG_MODIFY'),
('Project Manager', 'MM_PO_CREATE'),
('Project Manager', 'MM_PO_APPROVE'),
('Project Manager', 'HR_EMP_MANAGE'),
('Project Manager', 'HR_PERFORMANCE'),
('Project Manager', 'FI_COST_VIEW'),
('Project Manager', 'DM_DRAWING_APPROVE'),
('Project Manager', 'DM_RFI_RESPOND')
ON CONFLICT (role_name, auth_object_name) DO NOTHING;

-- Procurement Manager: MM + FI + limited PS
INSERT INTO role_authorization_mapping (role_name, auth_object_name) VALUES
('Procurement Manager', 'MM_PO_CREATE'),
('Procurement Manager', 'MM_PO_APPROVE'),
('Procurement Manager', 'MM_PO_MODIFY'),
('Procurement Manager', 'MM_VEN_CREATE'),
('Procurement Manager', 'MM_VEN_MODIFY'),
('Procurement Manager', 'MM_MAT_CREATE'),
('Procurement Manager', 'MM_MAT_MODIFY'),
('Procurement Manager', 'FI_INV_PROCESS'),
('Procurement Manager', 'FI_PAY_APPROVE'),
('Procurement Manager', 'PS_PRJ_REVIEW'),
('Procurement Manager', 'CO_BDG_VIEW')
ON CONFLICT (role_name, auth_object_name) DO NOTHING;

-- Store Keeper: WM + MM + limited PS
INSERT INTO role_authorization_mapping (role_name, auth_object_name) VALUES
('Store Keeper', 'WM_STK_VIEW'),
('Store Keeper', 'WM_STK_TRANSFER'),
('Store Keeper', 'WM_STK_ADJUST'),
('Store Keeper', 'MM_GR_CREATE'),
('Store Keeper', 'MM_GR_PROCESS'),
('Store Keeper', 'MM_MAT_VIEW'),
('Store Keeper', 'PS_PRJ_REVIEW')
ON CONFLICT (role_name, auth_object_name) DO NOTHING;

-- Finance Manager: FI + CO + limited PS/MM
INSERT INTO role_authorization_mapping (role_name, auth_object_name) VALUES
('Finance Manager', 'FI_INV_CREATE'),
('Finance Manager', 'FI_INV_PROCESS'),
('Finance Manager', 'FI_PAY_CREATE'),
('Finance Manager', 'FI_PAY_APPROVE'),
('Finance Manager', 'FI_COST_VIEW'),
('Finance Manager', 'CO_BDG_CREATE'),
('Finance Manager', 'CO_BDG_MODIFY'),
('Finance Manager', 'CO_BDG_APPROVE'),
('Finance Manager', 'PS_PRJ_REVIEW'),
('Finance Manager', 'MM_PO_APPROVE'),
('Finance Manager', 'HR_PAYROLL_VIEW'),
('Finance Manager', 'HR_PAYROLL_PROCESS')
ON CONFLICT (role_name, auth_object_name) DO NOTHING;

-- Quality Manager: QM + limited PS + MM
INSERT INTO role_authorization_mapping (role_name, auth_object_name) VALUES
('Quality Manager', 'QM_INSPECT_CREATE'),
('Quality Manager', 'QM_INSPECT_APPROVE'),
('Quality Manager', 'QM_NCR_CREATE'),
('Quality Manager', 'QM_NCR_RESOLVE'),
('Quality Manager', 'QM_TEST_CERT'),
('Quality Manager', 'QM_MATERIAL_TEST'),
('Quality Manager', 'QM_COMPLIANCE_VIEW'),
('Quality Manager', 'PS_PRJ_REVIEW'),
('Quality Manager', 'MM_MAT_VIEW'),
('Quality Manager', 'DM_SPEC_MANAGE')
ON CONFLICT (role_name, auth_object_name) DO NOTHING;

-- Safety Officer: SF + limited PS + HR
INSERT INTO role_authorization_mapping (role_name, auth_object_name) VALUES
('Safety Officer', 'SF_INCIDENT_CREATE'),
('Safety Officer', 'SF_INCIDENT_INVESTIGATE'),
('Safety Officer', 'SF_PERMIT_ISSUE'),
('Safety Officer', 'SF_AUDIT_CONDUCT'),
('Safety Officer', 'SF_TRAINING_MANAGE'),
('Safety Officer', 'SF_COMPLIANCE_VIEW'),
('Safety Officer', 'PS_PRJ_REVIEW'),
('Safety Officer', 'HR_TRAINING')
ON CONFLICT (role_name, auth_object_name) DO NOTHING;

-- Planning Engineer: PS + limited CO + DM
INSERT INTO role_authorization_mapping (role_name, auth_object_name) VALUES
('Planning Engineer', 'PS_PRJ_REVIEW'),
('Planning Engineer', 'PS_WBS_CREATE'),
('Planning Engineer', 'PS_WBS_MODIFY'),
('Planning Engineer', 'PS_ACT_SCHEDULE'),
('Planning Engineer', 'PS_ACT_EXECUTE'),
('Planning Engineer', 'PS_TSK_ASSIGN'),
('Planning Engineer', 'PS_TSK_MANAGE'),
('Planning Engineer', 'CO_BDG_VIEW'),
('Planning Engineer', 'DM_DRAWING_VIEW')
ON CONFLICT (role_name, auth_object_name) DO NOTHING;

-- Verify role assignments
SELECT 'ROLE ASSIGNMENTS' as status, r.name as role_name, COUNT(ram.auth_object_name) as auth_count
FROM roles r
LEFT JOIN role_authorization_mapping ram ON r.name = ram.role_name
WHERE r.name IN ('Site Engineer', 'Project Manager', 'Procurement Manager', 'Store Keeper', 'Finance Manager', 'Quality Manager', 'Safety Officer', 'Planning Engineer')
GROUP BY r.name
ORDER BY r.name;