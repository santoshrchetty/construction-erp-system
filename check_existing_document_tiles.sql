-- Check all existing document-related tiles
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
  title ILIKE '%document%' 
  OR title ILIKE '%contract%' 
  OR title ILIKE '%rfi%' 
  OR title ILIKE '%spec%' 
  OR title ILIKE '%submittal%' 
  OR title ILIKE '%change%order%'
  OR title ILIKE '%drawing%'
)
ORDER BY title;