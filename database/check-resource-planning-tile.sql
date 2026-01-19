-- Check Resource Planning tile configuration
SELECT 
  id,
  title,
  subtitle,
  module_code,
  tile_category,
  construction_action,
  route,
  auth_object,
  is_active,
  sequence_order
FROM tiles
WHERE title = 'Resource Planning';

-- Check if module_code is authorized for admin
SELECT DISTINCT ao.module
FROM users u
JOIN roles r ON u.role_id = r.id
JOIN role_authorization_objects rao ON r.id = rao.role_id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE u.email = 'admin@demo.com'
  AND rao.is_active = true
ORDER BY ao.module;

-- Check what module_code 'PS' maps to
SELECT * FROM get_user_modules('7febcd41-4b34-4155-b306-8ea89d9f715e'::uuid);
