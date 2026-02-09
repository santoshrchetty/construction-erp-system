-- Check what authorization objects have NULL or empty modules (causing "unknown Module")
SELECT ao.id, ao.object_name, ao.module, ao.description, ao.is_active
FROM role_authorization_objects rao
JOIN authorization_objects ao ON ao.id = rao.auth_object_id
WHERE rao.role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid
  AND rao.is_active = true
  AND (ao.module IS NULL OR ao.module = '' OR TRIM(ao.module) = '')
ORDER BY ao.object_name;

-- Count objects by module for Engineer role
SELECT 
  CASE 
    WHEN ao.module IS NULL OR ao.module = '' OR TRIM(ao.module) = '' THEN 'NULL/EMPTY'
    ELSE ao.module 
  END as module_name,
  COUNT(*) as object_count
FROM role_authorization_objects rao
JOIN authorization_objects ao ON ao.id = rao.auth_object_id
WHERE rao.role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid
  AND rao.is_active = true
GROUP BY 
  CASE 
    WHEN ao.module IS NULL OR ao.module = '' OR TRIM(ao.module) = '' THEN 'NULL/EMPTY'
    ELSE ao.module 
  END
ORDER BY object_count DESC;