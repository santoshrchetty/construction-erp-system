-- Remove duplicate Find Document tiles, keeping only the most recent one
WITH duplicate_tiles AS (
  SELECT 
    id,
    title,
    route,
    ROW_NUMBER() OVER (PARTITION BY title, route ORDER BY created_at DESC) as rn
  FROM tiles 
  WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
  AND title = 'Find Document'
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
  is_active
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
AND title = 'Find Document';