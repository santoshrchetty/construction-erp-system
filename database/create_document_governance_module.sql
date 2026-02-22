-- =====================================================
-- DOCUMENT GOVERNANCE SYSTEM (DG) MODULE
-- =====================================================
-- Module for managing Master Data, Drawings, Contracts, Specifications, etc.

-- =====================================================
-- 1. CREATE AUTHORIZATION OBJECTS
-- =====================================================

INSERT INTO authorization_objects (object_name, description, module, tenant_id) 
SELECT object_name, description, module, (SELECT id FROM tenants LIMIT 1) as tenant_id
FROM (VALUES
-- Document Governance - Master Data
('Z_DG_MASTER', 'Document Governance - Master Data Management', 'DG'),
('Z_DG_MAST_CRT', 'Create Master Data Documents', 'DG'),
('Z_DG_MAST_EDT', 'Edit Master Data Documents', 'DG'),
('Z_DG_MAST_VW', 'View Master Data Documents', 'DG'),
('Z_DG_MAST_DEL', 'Delete Master Data Documents', 'DG'),
('Z_DG_MAST_APP', 'Approve Master Data Documents', 'DG'),

-- Document Governance - Drawings
('Z_DG_DRAWING', 'Document Governance - Drawing Management', 'DG'),
('Z_DG_DRW_CRT', 'Create Drawings', 'DG'),
('Z_DG_DRW_EDT', 'Edit Drawings', 'DG'),
('Z_DG_DRW_VW', 'View Drawings', 'DG'),
('Z_DG_DRW_DEL', 'Delete Drawings', 'DG'),
('Z_DG_DRW_APP', 'Approve Drawings', 'DG'),
('Z_DG_DRW_REV', 'Revise Drawings', 'DG'),
('Z_DG_DRW_XMIT', 'Transmit Drawings to External Parties', 'DG'),

-- Document Governance - Contracts
('Z_DG_CONTRACT', 'Document Governance - Contract Management', 'DG'),
('Z_DG_CNT_CRT', 'Create Contracts', 'DG'),
('Z_DG_CNT_EDT', 'Edit Contracts', 'DG'),
('Z_DG_CNT_VW', 'View Contracts', 'DG'),
('Z_DG_CNT_DEL', 'Delete Contracts', 'DG'),
('Z_DG_CNT_APP', 'Approve Contracts', 'DG'),
('Z_DG_CNT_AMD', 'Amend Contracts', 'DG'),

-- Document Governance - Specifications
('Z_DG_SPEC', 'Document Governance - Specification Management', 'DG'),
('Z_DG_SPC_CRT', 'Create Specifications', 'DG'),
('Z_DG_SPC_EDT', 'Edit Specifications', 'DG'),
('Z_DG_SPC_VW', 'View Specifications', 'DG'),
('Z_DG_SPC_APP', 'Approve Specifications', 'DG'),

-- Document Governance - Submittals
('Z_DG_SUBMITTAL', 'Document Governance - Submittal Management', 'DG'),
('Z_DG_SUB_CRT', 'Create Submittals', 'DG'),
('Z_DG_SUB_REV', 'Review Submittals', 'DG'),
('Z_DG_SUB_APP', 'Approve Submittals', 'DG'),

-- Document Governance - RFIs
('Z_DG_RFI', 'Document Governance - RFI Management', 'DG'),
('Z_DG_RFI_CRT', 'Create RFIs', 'DG'),
('Z_DG_RFI_RSP', 'Respond to RFIs', 'DG'),
('Z_DG_RFI_CLS', 'Close RFIs', 'DG'),

-- Document Governance - Change Orders
('Z_DG_CHANGE', 'Document Governance - Change Order Management', 'DG'),
('Z_DG_CHG_CRT', 'Create Change Orders', 'DG'),
('Z_DG_CHG_APP', 'Approve Change Orders', 'DG'),

-- Document Governance - Admin
('Z_DG_ADMIN', 'Document Governance - Administration', 'DG'),
('Z_DG_CONFIG', 'Document Governance - Configuration', 'DG'),
('Z_DG_AUDIT', 'Document Governance - Audit Trail', 'DG')
) AS t(object_name, description, module);

-- =====================================================
-- 2. CREATE AUTHORIZATION FIELDS (SIMPLIFIED)
-- =====================================================
-- Note: Skipping authorization_fields as schema needs verification
-- Fields can be added later if needed for field-level authorization

-- =====================================================
-- 3. LINK AUTH OBJECTS TO FIELDS (SKIPPED)
-- =====================================================
-- Skipping field linking until authorization_fields schema is confirmed

-- =====================================================
-- 4. CREATE TILES FOR DOCUMENT GOVERNANCE
-- =====================================================

INSERT INTO tiles (title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object, is_active, sequence_order) VALUES
-- Master Data Documents
('Master Data Documents', 'Manage master data documentation', 'file-text', 'DG-MASTER', 'master_data_docs', '/document-governance/master-data', 'Document Governance', 'Z_DG_MASTER', true, 10),
('Create Master Data Doc', 'Create new master data document', 'plus-circle', 'DG-MASTER', 'create_master_doc', '/document-governance/master-data/create', 'Document Governance', 'Z_DG_MAST_CRT', true, 11),

-- Drawings
('Drawing Management', 'Manage engineering drawings', 'file-text', 'DG-DRAW', 'drawings', '/document-governance/drawings', 'Document Governance', 'Z_DG_DRAWING', true, 20),
('Create Drawing', 'Create new drawing', 'plus-circle', 'DG-DRAW', 'create_drawing', '/document-governance/drawings/create', 'Document Governance', 'Z_DG_DRW_CRT', true, 21),
('Drawing Revisions', 'Manage drawing revisions', 'git-branch', 'DG-DRAW', 'drawing_revisions', '/document-governance/drawings/revisions', 'Document Governance', 'Z_DG_DRW_REV', true, 22),
('Drawing Approvals', 'Approve drawings', 'check-circle', 'DG-DRAW', 'drawing_approvals', '/document-governance/drawings/approvals', 'Document Governance', 'Z_DG_DRW_APP', true, 23),
('Drawing Transmittals', 'Transmit drawings to external parties', 'send', 'DG-DRAW', 'drawing_transmittals', '/document-governance/drawings/transmittals', 'Document Governance', 'Z_DG_DRW_XMIT', true, 24),

-- Contracts
('Contract Management', 'Manage construction contracts', 'file-text', 'DG-CONT', 'contracts', '/document-governance/contracts', 'Document Governance', 'Z_DG_CONTRACT', true, 30),
('Create Contract', 'Create new contract', 'plus-circle', 'DG-CONT', 'create_contract', '/document-governance/contracts/create', 'Document Governance', 'Z_DG_CNT_CRT', true, 31),
('Contract Amendments', 'Manage contract amendments', 'edit', 'DG-CONT', 'contract_amendments', '/document-governance/contracts/amendments', 'Document Governance', 'Z_DG_CNT_AMD', true, 32),
('Contract Approvals', 'Approve contracts', 'check-circle', 'DG-CONT', 'contract_approvals', '/document-governance/contracts/approvals', 'Document Governance', 'Z_DG_CNT_APP', true, 33),

-- Specifications
('Specifications', 'Manage technical specifications', 'file-text', 'DG-SPEC', 'specifications', '/document-governance/specifications', 'Document Governance', 'Z_DG_SPEC', true, 40),
('Create Specification', 'Create new specification', 'plus-circle', 'DG-SPEC', 'create_spec', '/document-governance/specifications/create', 'Document Governance', 'Z_DG_SPC_CRT', true, 41),
('Spec Approvals', 'Approve specifications', 'check-circle', 'DG-SPEC', 'spec_approvals', '/document-governance/specifications/approvals', 'Document Governance', 'Z_DG_SPC_APP', true, 42),

-- Submittals
('Submittal Management', 'Manage vendor submittals', 'file-text', 'DG-SUB', 'submittals', '/document-governance/submittals', 'Document Governance', 'Z_DG_SUBMITTAL', true, 50),
('Create Submittal', 'Create new submittal', 'plus-circle', 'DG-SUB', 'create_submittal', '/document-governance/submittals/create', 'Document Governance', 'Z_DG_SUB_CRT', true, 51),
('Review Submittals', 'Review vendor submittals', 'eye', 'DG-SUB', 'review_submittals', '/document-governance/submittals/review', 'Document Governance', 'Z_DG_SUB_REV', true, 52),
('Submittal Approvals', 'Approve submittals', 'check-circle', 'DG-SUB', 'submittal_approvals', '/document-governance/submittals/approvals', 'Document Governance', 'Z_DG_SUB_APP', true, 53),

-- RFIs
('RFI Management', 'Manage requests for information', 'help-circle', 'DG-RFI', 'rfis', '/document-governance/rfis', 'Document Governance', 'Z_DG_RFI', true, 60),
('Create RFI', 'Create new RFI', 'plus-circle', 'DG-RFI', 'create_rfi', '/document-governance/rfis/create', 'Document Governance', 'Z_DG_RFI_CRT', true, 61),
('Respond to RFIs', 'Respond to RFIs', 'message-circle', 'DG-RFI', 'respond_rfi', '/document-governance/rfis/respond', 'Document Governance', 'Z_DG_RFI_RSP', true, 62),

-- Change Orders
('Change Order Management', 'Manage change orders', 'file-text', 'DG-CHG', 'change_orders', '/document-governance/change-orders', 'Document Governance', 'Z_DG_CHANGE', true, 70),
('Create Change Order', 'Create new change order', 'plus-circle', 'DG-CHG', 'create_change', '/document-governance/change-orders/create', 'Document Governance', 'Z_DG_CHG_CRT', true, 71),
('Change Order Approvals', 'Approve change orders', 'check-circle', 'DG-CHG', 'change_approvals', '/document-governance/change-orders/approvals', 'Document Governance', 'Z_DG_CHG_APP', true, 72),

-- Administration
('Document Governance Config', 'Configure document governance settings', 'settings', 'DG-ADMIN', 'dg_config', '/document-governance/config', 'Document Governance', 'Z_DG_CONFIG', true, 80),
('Document Audit Trail', 'View document audit trail', 'file-text', 'DG-ADMIN', 'dg_audit', '/document-governance/audit', 'Document Governance', 'Z_DG_AUDIT', true, 81);

-- =====================================================
-- 5. VERIFICATION QUERIES
-- =====================================================

-- Count auth objects created
SELECT 'Auth Objects Created' AS metric, COUNT(*) AS count
FROM authorization_objects
WHERE module = 'DG';

-- Count tiles created
SELECT 'Tiles Created' AS metric, COUNT(*) AS count
FROM tiles
WHERE tile_category = 'Document Governance';

-- Show all DG tiles
SELECT 
  title,
  subtitle,
  module_code,
  auth_object,
  route
FROM tiles
WHERE tile_category = 'Document Governance'
ORDER BY sequence_order;
