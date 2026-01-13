-- Authorization Objects for Flexible Approval System Tiles
-- Create authorization objects for all new tiles

INSERT INTO authorization_objects (object_name, description, module) VALUES
-- Administration authorization objects
('AD_APPR_CFG', 'Configure approval workflows and templates', 'configuration'),
('AD_APPR_TPL', 'Manage approval workflow templates', 'configuration'),
('AD_CUST_APPR', 'Set up customer-specific approval workflows', 'configuration'),
('AD_APPR_RPT', 'View approval performance analytics', 'reporting'),

-- Materials authorization objects
('MM_REQ_UNIFIED', 'Create and manage unified material requests (MR/PR/PO)', 'materials'),
('MM_REQ_APPROVE', 'Approve material requests with flexible workflows', 'materials'),
('MM_REQ_STATUS', 'Track material request status', 'materials'),
('MM_APPR_DELEG', 'Delegate material approval authority', 'materials'),

-- Procurement authorization objects
('MM_PR_FLEXIBLE', 'Create and manage purchase requisitions with flexible approvals', 'procurement'),
('MM_PO_FLEXIBLE', 'Create and manage purchase orders with approval workflows', 'procurement'),
('MM_PROC_APPR', 'Access procurement approvals dashboard', 'procurement'),
('MM_VEND_APPR', 'Approve vendor selections and contracts', 'procurement'),

-- Configuration authorization objects
('CF_DOC_TYPES', 'Configure document types (MR/PR/PO) enablement', 'configuration'),
('CF_APPR_ROLES', 'Manage approval roles and hierarchies', 'configuration'),
('CF_THRESHOLDS', 'Configure approval amount thresholds', 'configuration'),
('CF_NOTIFICATIONS', 'Configure approval notification settings', 'configuration'),

-- Reporting authorization objects
('RP_APPR_PERF', 'View approval performance reports', 'reporting'),
('RP_PEND_APPR', 'View pending approvals reports', 'reporting'),
('RP_APPR_AUDIT', 'View approval audit trail reports', 'reporting'),
('RP_DELEGATIONS', 'View delegation reports', 'reporting'),

-- User task authorization objects
('UT_PEND_APPR', 'View personal pending approvals', 'user_tasks'),
('UT_APPR_HIST', 'View personal approval history', 'user_tasks'),
('UT_DELEGATIONS', 'Manage personal approval delegations', 'user_tasks'),
('UT_REQ_STATUS', 'View personal request status', 'user_tasks'),

-- Emergency authorization objects
('EM_APPROVALS', 'Process emergency approvals', 'emergency'),
('EM_OVERRIDE', 'Override approval workflows in emergencies', 'emergency'),
('EM_BULK_APPR', 'Process bulk approvals', 'emergency'),

-- Integration authorization objects
('IN_ERP_SYNC', 'Synchronize approvals with ERP systems', 'integration'),
('IN_MOBILE_APPR', 'Configure mobile approval access', 'integration')

ON CONFLICT (object_name) DO UPDATE SET
  description = EXCLUDED.description,
  module = EXCLUDED.module;

-- Verify authorization objects were created
SELECT 'AUTHORIZATION OBJECTS CREATED:' as info;
SELECT module, COUNT(*) as auth_object_count
FROM authorization_objects 
WHERE object_name IN (
  'AD_APPR_CFG', 'AD_APPR_TPL', 'AD_CUST_APPR', 'AD_APPR_RPT',
  'MM_REQ_UNIFIED', 'MM_REQ_APPROVE', 'MM_REQ_STATUS', 'MM_APPR_DELEG',
  'MM_PR_FLEXIBLE', 'MM_PO_FLEXIBLE', 'MM_PROC_APPR', 'MM_VEND_APPR',
  'CF_DOC_TYPES', 'CF_APPR_ROLES', 'CF_THRESHOLDS', 'CF_NOTIFICATIONS',
  'RP_APPR_PERF', 'RP_PEND_APPR', 'RP_APPR_AUDIT', 'RP_DELEGATIONS',
  'UT_PEND_APPR', 'UT_APPR_HIST', 'UT_DELEGATIONS', 'UT_REQ_STATUS',
  'EM_APPROVALS', 'EM_OVERRIDE', 'EM_BULK_APPR',
  'IN_ERP_SYNC', 'IN_MOBILE_APPR'
)
GROUP BY module
ORDER BY module;