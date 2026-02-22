-- Remove duplicate Display Document tiles, keeping only one
WITH duplicate_tiles AS (
  SELECT 
    id,
    title,
    route,
    ROW_NUMBER() OVER (PARTITION BY title, route ORDER BY created_at ASC) as rn
  FROM tiles 
  WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
  AND title = 'Display Document'
)
DELETE FROM tiles 
WHERE id IN (
  SELECT id FROM duplicate_tiles WHERE rn > 1
);

-- Verify remaining tiles
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
