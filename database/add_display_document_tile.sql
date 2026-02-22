-- Add Display Document tile for OMEGA-DEV tenant
INSERT INTO tiles (
  tenant_id,
  title,
  subtitle,
  icon,
  color,
  route,
  auth_object,
  module_code,
  tile_category,
  sequence_order,
  is_active
) VALUES (
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15',
  'Display Document',
  'View document details',
  'Eye',
  'blue',
  '/document-governance/records/display',
  'Z_DG_RECORDS_DISPLAY',
  'DG',
  'Document Governance',
  2,
  true
);

-- Verify all document governance tiles
SELECT 
  title,
  subtitle,
  route,
  auth_object,
  sequence_order,
  is_active
FROM tiles
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND tile_category = 'Document Governance'
ORDER BY sequence_order;
