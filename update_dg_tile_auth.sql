-- Update DG tiles to use new simplified authorization objects
-- Records tiles (Find, Create, Change)
UPDATE tiles 
SET auth_object = 'Z_DG_RECORDS_DISPLAY'
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND tile_category = 'Document Governance'
  AND title IN ('Find Document');

UPDATE tiles 
SET auth_object = 'Z_DG_RECORDS_CREATE'
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND tile_category = 'Document Governance'
  AND title IN ('Create Document', 'Create Drawing', 'Create Master Data Doc', 'Create Specification', 'Create Submittal', 'Create RFI', 'Create Contract', 'Create Change Order');

UPDATE tiles 
SET auth_object = 'Z_DG_RECORDS_CHANGE'
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND tile_category = 'Document Governance'
  AND title IN ('Change Document', 'Drawing Management', 'Drawing Revisions', 'Drawing Approvals', 'Drawing Transmittals', 'Contract Management', 'Contract Amendments', 'Contract Approvals', 'Specifications', 'Spec Approvals', 'Submittal Management', 'Review Submittals', 'Submittal Approvals', 'RFI Management', 'Respond to RFIs', 'Change Order Management', 'Change Order Approvals', 'Master Data Documents', 'Test Document Tile');

-- Config and Audit already have correct auth_object
-- Z_DG_CONFIG and Z_DG_AUDIT are already assigned correctly