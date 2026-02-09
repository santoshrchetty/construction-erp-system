-- Check tiles that successfully route to pages
SELECT 
  title,
  route,
  construction_action,
  module_code
FROM tiles
WHERE route IS NOT NULL
  AND route LIKE '/materials%'
LIMIT 5;
