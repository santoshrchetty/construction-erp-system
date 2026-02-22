-- Create DG Authorization Objects for OMEGA-DEV tenant
INSERT INTO authorization_objects (object_name, description, module, tenant_id) 
SELECT object_name, description, module, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' as tenant_id
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
) AS t(object_name, description, module)
WHERE NOT EXISTS (
  SELECT 1 FROM authorization_objects 
  WHERE object_name = t.object_name 
  AND tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
);

-- Verify
SELECT 
  'Auth Objects Created' as check_type,
  COUNT(*) as count
FROM authorization_objects
WHERE module = 'DG' 
AND tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';
