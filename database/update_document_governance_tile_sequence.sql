-- Update sequence order for Document Governance tiles
UPDATE tiles 
SET sequence_order = 1
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND title = 'Find Document';

UPDATE tiles 
SET sequence_order = 2
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND title = 'Display Document';

UPDATE tiles 
SET sequence_order = 3
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND title = 'Create Document';

UPDATE tiles 
SET sequence_order = 4
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND title = 'Change Document';

-- Verify updated sequence
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
