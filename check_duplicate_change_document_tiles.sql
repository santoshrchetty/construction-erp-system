-- Check for duplicate Change Document tiles
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
AND title = 'Change Document'
ORDER BY created_at;