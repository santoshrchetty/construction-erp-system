-- Check DG tiles and their navigation paths
SELECT 
  title,
  subtitle,
  route,
  auth_object,
  module_code,
  is_active
FROM tiles
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND module_code = 'DG'
ORDER BY sequence_order;
