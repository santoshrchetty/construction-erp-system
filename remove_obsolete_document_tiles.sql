-- Remove obsolete document tiles
DELETE FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
AND title IN (
  'Master Data Documents',
  'Create Master Data Doc',
  'Contract Management',
  'Create Contracts',
  'Contract Amendment',
  'Contract Approvals',
  'Specifications',
  'Create Specifications',
  'Spec Approvals',
  'Submittal Management',
  'Create Submittal',
  'Review Submittal',
  'Submittal Approvals',
  'RFI Management',
  'Create RFI',
  'Respond to RFI''s',
  'Change Order Management',
  'Create Change Order',
  'Change Order Approvals',
  'Test Document Tile'
);

-- Verify tiles were removed
SELECT COUNT(*) as removed_tiles_count FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
AND title IN (
  'Master Data Documents',
  'Create Master Data Doc',
  'Contract Management',
  'Create Contracts',
  'Contract Amendment',
  'Contract Approvals',
  'Specifications',
  'Create Specifications',
  'Spec Approvals',
  'Submittal Management',
  'Create Submittal',
  'Review Submittal',
  'Submittal Approvals',
  'RFI Management',
  'Create RFI',
  'Respond to RFI''s',
  'Change Order Management',
  'Create Change Order',
  'Change Order Approvals',
  'Test Document Tile'
);