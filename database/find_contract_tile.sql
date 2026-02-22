-- Find Contract Management tile
SELECT 
  id,
  title,
  subtitle,
  route,
  auth_object,
  module_code,
  tenant_id,
  is_active
FROM tiles
WHERE title LIKE '%Contract%'
ORDER BY created_at DESC;

-- Check all DG-related tiles
SELECT 
  id,
  title,
  route,
  auth_object,
  module_code,
  tenant_id
FROM tiles
WHERE auth_object LIKE '%DG%' OR module_code LIKE '%DG%' OR route LIKE '%document%'
ORDER BY title;
