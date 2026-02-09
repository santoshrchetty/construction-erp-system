-- Check what the first 14 objects are (likely what UI is showing as "unknown Module")
SELECT ao.object_name, ao.module, ao.description, rao.created_at
FROM role_authorization_objects rao
JOIN authorization_objects ao ON ao.id = rao.auth_object_id
WHERE rao.role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid
  AND rao.is_active = true
ORDER BY rao.created_at
LIMIT 14;

-- Check if MAT_REQ permissions are in the Engineer's assignments
SELECT ao.object_name, ao.module, ao.description, rao.is_active
FROM role_authorization_objects rao
JOIN authorization_objects ao ON ao.id = rao.auth_object_id
WHERE rao.role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid
  AND ao.object_name IN ('MAT_REQ_READ', 'MAT_REQ_WRITE');