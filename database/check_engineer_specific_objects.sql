-- Check what specific authorization objects Engineer role has
SELECT ao.object_name, ao.module, ao.description, rao.is_active
FROM role_authorization_objects rao
JOIN authorization_objects ao ON ao.id = rao.auth_object_id
WHERE rao.role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid
  AND rao.is_active = true
ORDER BY ao.module, ao.object_name;

-- Check if MAT_REQ permissions exist and what IDs they have
SELECT id, object_name, module, description, is_active
FROM authorization_objects 
WHERE object_name IN ('MAT_REQ_READ', 'MAT_REQ_WRITE');