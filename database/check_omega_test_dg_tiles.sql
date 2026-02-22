-- Check DG tiles from OMEGA-TEST
SELECT 
  title,
  subtitle,
  route,
  auth_object,
  module_code,
  icon,
  color,
  tile_category,
  sequence_order,
  is_active
FROM tiles
WHERE tenant_id = '8b27aa43-fbb2-41b6-8457-642a51eabe9d'
AND module_code = 'DG'
ORDER BY sequence_order;
