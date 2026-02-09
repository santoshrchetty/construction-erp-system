-- Assign MAT_REQ_READ permission to Engineer role
INSERT INTO role_authorization_objects (role_id, auth_object_id, field_values, valid_from, is_active, module_full_access, object_full_access, tenant_id)
VALUES (
  '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid,
  'd565c3ad-9ec1-4085-b269-08672349b269'::uuid,
  '{"ACTVT": ["*"]}',
  CURRENT_DATE,
  true,
  false,
  false,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid
) ON CONFLICT DO NOTHING;

-- Assign MAT_REQ_WRITE permission to Engineer role
INSERT INTO role_authorization_objects (role_id, auth_object_id, field_values, valid_from, is_active, module_full_access, object_full_access, tenant_id)
VALUES (
  '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid,
  'b7a0e406-0fe3-4456-a26a-16643c82a732'::uuid,
  '{"ACTVT": ["*"]}',
  CURRENT_DATE,
  true,
  false,
  false,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid
) ON CONFLICT DO NOTHING;

-- Verify the assignments
SELECT ao.object_name, ao.module, ao.description, rao.is_active
FROM role_authorization_objects rao
JOIN authorization_objects ao ON ao.id = rao.auth_object_id
WHERE rao.role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid
  AND ao.object_name IN ('MAT_REQ_READ', 'MAT_REQ_WRITE');