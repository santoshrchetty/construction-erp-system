-- Check for duplicate Find Document tiles
SELECT 
  id,
  title, 
  subtitle, 
  route, 
  auth_object, 
  is_active,
  created_at
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
AND (
  title ILIKE '%find%document%' 
  OR title ILIKE '%search%document%' 
  OR route ILIKE '%document%list%' 
  OR route ILIKE '%document%find%'
) 
ORDER BY title, created_at;