-- Phase 1: New Tiles for Additional Modules
-- ==========================================

-- Quality Management Tiles
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('Quality Inspections', 'Create and manage quality inspections', 'shield-check', 'bg-green-600', '/quality-inspections', 'QM', 'Quality Management', 'INSPECT', 'QM_INSPECT_CREATE', 101, true),
('NCR Management', 'Non-conformance report management', 'alert-triangle', 'bg-red-600', '/ncr-management', 'QM', 'Quality Management', 'RESOLVE', 'QM_NCR_CREATE', 102, true),
('Test Certificates', 'Manage material test certificates', 'file-check', 'bg-blue-600', '/test-certificates', 'QM', 'Quality Management', 'CERTIFY', 'QM_TEST_CERT', 103, true),
('Material Testing', 'Material testing and approval', 'beaker', 'bg-purple-600', '/material-testing', 'QM', 'Quality Management', 'TEST', 'QM_MATERIAL_TEST', 104, true),
('Compliance Reports', 'Quality compliance reporting', 'clipboard-check', 'bg-indigo-600', '/compliance-reports', 'QM', 'Quality Management', 'REPORT', 'QM_COMPLIANCE_VIEW', 105, true);

-- Human Resources Tiles
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('Employee Management', 'Manage employee records and profiles', 'users', 'bg-blue-700', '/employee-management', 'HR', 'Human Resources', 'MANAGE', 'HR_EMP_MANAGE', 201, true),
('Attendance Tracking', 'Track employee attendance and hours', 'clock', 'bg-green-700', '/attendance-tracking', 'HR', 'Human Resources', 'TRACK', 'HR_ATTENDANCE', 202, true),
('Payroll Management', 'Process payroll and compensation', 'dollar-sign', 'bg-emerald-700', '/payroll-management', 'HR', 'Human Resources', 'PROCESS', 'HR_PAYROLL_PROCESS', 203, true),
('Training Records', 'Manage training and certifications', 'graduation-cap', 'bg-purple-700', '/training-records', 'HR', 'Human Resources', 'TRAIN', 'HR_TRAINING', 204, true),
('Performance Reviews', 'Employee performance management', 'trending-up', 'bg-orange-700', '/performance-reviews', 'HR', 'Human Resources', 'EVALUATE', 'HR_PERFORMANCE', 205, true);

-- Safety Management Tiles
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('Safety Incidents', 'Report and track safety incidents', 'alert-circle', 'bg-red-700', '/safety-incidents', 'SF', 'Safety Management', 'REPORT', 'SF_INCIDENT_CREATE', 301, true),
('Work Permits', 'Issue and manage work permits', 'file-text', 'bg-yellow-600', '/work-permits', 'SF', 'Safety Management', 'PERMIT', 'SF_PERMIT_ISSUE', 302, true),
('Safety Audits', 'Conduct safety audits and inspections', 'search', 'bg-orange-600', '/safety-audits', 'SF', 'Safety Management', 'AUDIT', 'SF_AUDIT_CONDUCT', 303, true),
('Safety Training', 'Manage safety training programs', 'shield', 'bg-green-800', '/safety-training', 'SF', 'Safety Management', 'TRAIN', 'SF_TRAINING_MANAGE', 304, true),
('Safety Compliance', 'Monitor safety compliance status', 'check-circle', 'bg-blue-800', '/safety-compliance', 'SF', 'Safety Management', 'MONITOR', 'SF_COMPLIANCE_VIEW', 305, true);

-- Document Management Tiles
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('Engineering Drawings', 'View and manage engineering drawings', 'file-image', 'bg-indigo-700', '/engineering-drawings', 'DM', 'Document Management', 'VIEW', 'DM_DRAWING_VIEW', 401, true),
('Specifications', 'Manage project specifications', 'file-text', 'bg-gray-700', '/specifications', 'DM', 'Document Management', 'MANAGE', 'DM_SPEC_MANAGE', 402, true),
('RFI Management', 'Request for Information management', 'help-circle', 'bg-cyan-700', '/rfi-management', 'DM', 'Document Management', 'REQUEST', 'DM_RFI_CREATE', 403, true),
('Submittal Reviews', 'Review and approve submittals', 'file-check', 'bg-teal-700', '/submittal-reviews', 'DM', 'Document Management', 'REVIEW', 'DM_SUBMITTAL_REVIEW', 404, true);

-- Enhanced Project Management Tiles (workflow-aware)
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('Project Planning', 'Comprehensive project planning', 'calendar', 'bg-blue-500', '/project-planning', 'PS', 'Project Management', 'PLAN', 'PS_PRJ_INITIATE', 15, true),
('Resource Allocation', 'Allocate resources to projects', 'users', 'bg-green-500', '/resource-allocation', 'PS', 'Project Management', 'ALLOCATE', 'PS_TSK_ASSIGN', 16, true),
('Progress Tracking', 'Track project progress and milestones', 'trending-up', 'bg-orange-500', '/progress-tracking', 'PS', 'Project Management', 'TRACK', 'PS_ACT_EXECUTE', 17, true);

-- Enhanced Procurement Tiles (workflow-aware)
INSERT INTO tiles (title, subtitle, icon, color, route, module_code, tile_category, construction_action, auth_object, sequence_order, is_active) VALUES
('Purchase Requisitions', 'Create purchase requisitions', 'file-plus', 'bg-blue-600', '/purchase-requisitions', 'MM', 'Procurement', 'REQUEST', 'MM_PO_CREATE', 51, true),
('Vendor Evaluation', 'Evaluate and qualify vendors', 'star', 'bg-yellow-600', '/vendor-evaluation', 'MM', 'Procurement', 'EVALUATE', 'MM_VEN_MODIFY', 52, true),
('Contract Management', 'Manage procurement contracts', 'file-text', 'bg-purple-600', '/contract-management', 'MM', 'Procurement', 'CONTRACT', 'MM_PO_APPROVE', 53, true);

-- Verify new tiles
SELECT 'NEW TILES SUMMARY' as status, tile_category, COUNT(*) as tile_count
FROM tiles 
WHERE sequence_order >= 100
GROUP BY tile_category
ORDER BY tile_category;