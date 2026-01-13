-- New Tiles for Flexible Approval System
-- Comprehensive set of tiles for approval configuration and management

-- 1. Administration Category - Approval Configuration Tiles
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
-- Main approval configuration
('Approval Configuration', 'Configure flexible approval workflows for MR/PR/PO', 'settings', 'AD', 'approval-configuration', '/admin/approval-config', 'Administration', 'AD_APPR_CFG'),

-- Template management
('Approval Templates', 'Manage and create approval workflow templates', 'file-template', 'AD', 'approval-templates', '/admin/approval-templates', 'Administration', 'AD_APPR_TPL'),

-- Customer-specific approval setup
('Customer Approval Setup', 'Set up approval workflows for customers', 'user-cog', 'AD', 'customer-approval-setup', '/admin/customer-approvals', 'Administration', 'AD_CUST_APPR'),

-- Approval analytics
('Approval Analytics', 'Analyze approval performance and bottlenecks', 'bar-chart-3', 'AD', 'approval-analytics', '/admin/approval-analytics', 'Administration', 'AD_APPR_RPT');

-- 2. Materials Category - Enhanced Request Tiles
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
-- Unified material request (replaces old material reservations)
('Material Requests', 'Unified system for MR/PR/PO with flexible approvals', 'file-plus', 'MM', 'unified-material-request', '/materials/unified-request', 'Materials', 'MM_REQ_UNIFIED'),

-- Approval workflow for materials
('Material Request Approvals', 'Approve material requests with flexible workflows', 'check-circle', 'MM', 'material-request-approvals', '/materials/approvals', 'Materials', 'MM_REQ_APPROVE'),

-- Request status tracking
('Request Status Tracking', 'Track status of all material requests', 'activity', 'MM', 'request-status-tracking', '/materials/request-status', 'Materials', 'MM_REQ_STATUS'),

-- Approval delegation
('Approval Delegation', 'Delegate approval authority temporarily', 'user-check', 'MM', 'approval-delegation', '/materials/delegation', 'Materials', 'MM_APPR_DELEG');

-- 3. Procurement Category - Enhanced PR/PO Tiles
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
-- Purchase requisition with flexible approval
('Purchase Requisitions', 'Create and manage PRs with configurable approvals', 'shopping-cart', 'MM', 'purchase-requisitions-flex', '/procurement/pr-flexible', 'Procurement', 'MM_PR_FLEXIBLE'),

-- Purchase order with approval workflow
('Purchase Orders', 'Manage POs with multi-level approval workflows', 'receipt', 'MM', 'purchase-orders-flex', '/procurement/po-flexible', 'Procurement', 'MM_PO_FLEXIBLE'),

-- Procurement approvals dashboard
('Procurement Approvals', 'Centralized approval dashboard for procurement', 'clipboard-check', 'MM', 'procurement-approvals', '/procurement/approvals-dashboard', 'Procurement', 'MM_PROC_APPR'),

-- Vendor approval workflow
('Vendor Approvals', 'Approve vendor selections and contracts', 'users', 'MM', 'vendor-approvals', '/procurement/vendor-approvals', 'Procurement', 'MM_VEND_APPR');

-- 4. Configuration Category - System Setup Tiles
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
-- Document type configuration
('Document Type Configuration', 'Configure which document types (MR/PR/PO) to enable', 'file-type', 'CF', 'document-type-config', '/config/document-types', 'Configuration', 'CF_DOC_TYPES'),

-- Approval role management
('Approval Role Management', 'Define and manage approval roles and hierarchies', 'shield', 'CF', 'approval-role-management', '/config/approval-roles', 'Configuration', 'CF_APPR_ROLES'),

-- Threshold configuration
('Approval Thresholds', 'Configure amount thresholds for approval levels', 'dollar-sign', 'CF', 'approval-thresholds', '/config/approval-thresholds', 'Configuration', 'CF_THRESHOLDS'),

-- Notification configuration
('Approval Notifications', 'Configure approval notification settings', 'bell', 'CF', 'approval-notifications', '/config/approval-notifications', 'Configuration', 'CF_NOTIFICATIONS');

-- 5. Reports Category - Approval Reporting Tiles
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
-- Approval performance reports
('Approval Performance', 'Reports on approval times and bottlenecks', 'trending-up', 'RP', 'approval-performance', '/reports/approval-performance', 'Reports', 'RP_APPR_PERF'),

-- Pending approvals report
('Pending Approvals', 'View all pending approvals across the system', 'clock', 'RP', 'pending-approvals', '/reports/pending-approvals', 'Reports', 'RP_PEND_APPR'),

-- Approval audit trail
('Approval Audit Trail', 'Complete audit trail of all approval decisions', 'search', 'RP', 'approval-audit-trail', '/reports/approval-audit', 'Reports', 'RP_APPR_AUDIT'),

-- Delegation reports
('Delegation Reports', 'Track approval delegations and usage', 'user-check', 'RP', 'delegation-reports', '/reports/delegation-reports', 'Reports', 'RP_DELEGATIONS');

-- 6. My Tasks Category - User-Specific Approval Tiles
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
-- My pending approvals
('My Pending Approvals', 'Requests waiting for my approval', 'inbox', 'MT', 'my-pending-approvals', '/my-tasks/pending-approvals', 'My Tasks', 'UT_PEND_APPR'),

-- My approval history
('My Approval History', 'History of my approval decisions', 'history', 'MT', 'my-approval-history', '/my-tasks/approval-history', 'My Tasks', 'UT_APPR_HIST'),

-- My delegations
('My Delegations', 'Manage my approval delegations', 'user-plus', 'MT', 'my-delegations', '/my-tasks/my-delegations', 'My Tasks', 'UT_DELEGATIONS'),

-- My requests status
('My Request Status', 'Track status of requests I submitted', 'file-search', 'MT', 'my-request-status', '/my-tasks/request-status', 'My Tasks', 'UT_REQ_STATUS');

-- 7. Emergency/Special Tiles
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
-- Emergency approvals
('Emergency Approvals', 'Fast-track approval for emergency requests', 'alert-triangle', 'EM', 'emergency-approvals', '/emergency/approvals', 'Emergency', 'EM_APPROVALS'),

-- Approval override
('Approval Override', 'Override approval workflows in exceptional cases', 'shield-alert', 'EM', 'approval-override', '/emergency/approval-override', 'Emergency', 'EM_OVERRIDE'),

-- Bulk approvals
('Bulk Approvals', 'Approve multiple requests simultaneously', 'check-square', 'BK', 'bulk-approvals', '/bulk/approvals', 'Bulk Operations', 'EM_BULK_APPR');

-- 8. Integration Tiles
INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object) VALUES
-- ERP approval sync
('ERP Approval Sync', 'Synchronize approvals with external ERP systems', 'refresh-cw', 'INT', 'erp-approval-sync', '/integration/erp-sync', 'Integration', 'IN_ERP_SYNC'),

-- Mobile approval setup
('Mobile Approval Setup', 'Configure mobile approval notifications and access', 'smartphone', 'INT', 'mobile-approval-setup', '/integration/mobile-setup', 'Integration', 'IN_MOBILE_APPR');

-- Verify all tiles were added
SELECT 'NEW TILES SUMMARY:' as info;

SELECT 
  tile_category,
  COUNT(*) as tile_count,
  STRING_AGG(title, ', ' ORDER BY title) as tiles
FROM tiles 
WHERE construction_action IN (
  'approval-configuration', 'approval-templates', 'customer-approval-setup', 'approval-analytics',
  'unified-material-request', 'material-request-approvals', 'request-status-tracking', 'approval-delegation',
  'purchase-requisitions-flex', 'purchase-orders-flex', 'procurement-approvals', 'vendor-approvals',
  'document-type-config', 'approval-role-management', 'approval-thresholds', 'approval-notifications',
  'approval-performance', 'pending-approvals', 'approval-audit-trail', 'delegation-reports',
  'my-pending-approvals', 'my-approval-history', 'my-delegations', 'my-request-status',
  'emergency-approvals', 'approval-override', 'bulk-approvals',
  'erp-approval-sync', 'mobile-approval-setup'
)
GROUP BY tile_category
ORDER BY tile_category;

-- Show total count
SELECT 'TOTAL NEW TILES ADDED:' as info, COUNT(*) as total_count
FROM tiles 
WHERE construction_action IN (
  'approval-configuration', 'approval-templates', 'customer-approval-setup', 'approval-analytics',
  'unified-material-request', 'material-request-approvals', 'request-status-tracking', 'approval-delegation',
  'purchase-requisitions-flex', 'purchase-orders-flex', 'procurement-approvals', 'vendor-approvals',
  'document-type-config', 'approval-role-management', 'approval-thresholds', 'approval-notifications',
  'approval-performance', 'pending-approvals', 'approval-audit-trail', 'delegation-reports',
  'my-pending-approvals', 'my-approval-history', 'my-delegations', 'my-request-status',
  'emergency-approvals', 'approval-override', 'bulk-approvals',
  'erp-approval-sync', 'mobile-approval-sync'
);

COMMENT ON TABLE tiles IS 'Enhanced with flexible approval system tiles for comprehensive workflow management';