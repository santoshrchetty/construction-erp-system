-- Update Display Document tile route to Find Document
UPDATE tiles 
SET route = '/document-governance/records/list'
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND title = 'Display Document';

-- Verify
SELECT title, route FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND title = 'Display Document';
