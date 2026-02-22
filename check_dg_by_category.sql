-- Check tiles by category for Document Governance
SELECT 
  id, 
  title, 
  tile_category,
  module_code,
  auth_object, 
  is_active,
  tenant_id
FROM tiles 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15' 
AND (tile_category ILIKE '%Document Governance%' 
     OR tile_category ILIKE '%DG%'
     OR module_code = 'DG')
ORDER BY tile_category, title;