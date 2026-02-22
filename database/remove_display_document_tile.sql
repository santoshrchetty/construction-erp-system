-- Remove Display Document tile (redundant with View button in Find Document)
DELETE FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND title = 'Display Document';

-- Verify remaining tiles
SELECT title, route, sequence_order 
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
  AND tile_category = 'Document Governance'
ORDER BY sequence_order;
