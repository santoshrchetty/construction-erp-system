-- Get the authorization object IDs for MAT_REQ permissions
SELECT id, object_name, module FROM authorization_objects 
WHERE object_name IN ('MAT_REQ_READ', 'MAT_REQ_WRITE');

-- Assign MAT_REQ_READ permission to Engineer role
INSERT INTO role_authorization_objects (role_id, authorization_objects_id, is_active, tenant_id)
SELECT 
  '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid,
  ao.id,
  true,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid
FROM authorization_objects ao
WHERE ao.object_name = 'MAT_REQ_READ'
  AND NOT EXISTS (
    SELECT 1 FROM role_authorization_objects rao 
    WHERE rao.role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid 
      AND rao.authorization_objects_id = ao.id
  );

-- Assign MAT_REQ_WRITE permission to Engineer role
INSERT INTO role_authorization_objects (role_id, authorization_objects_id, is_active, tenant_id)
SELECT 
  '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid,
  ao.id,
  true,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid
FROM authorization_objects ao
WHERE ao.object_name = 'MAT_REQ_WRITE'
  AND NOT EXISTS (
    SELECT 1 FROM role_authorization_objects rao 
    WHERE rao.role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid 
      AND rao.authorization_objects_id = ao.id
  );