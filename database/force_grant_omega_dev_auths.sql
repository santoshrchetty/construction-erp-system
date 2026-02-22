-- Force grant DG authorizations to OMEGA-DEV DataGov Admin role
DO $$
DECLARE
  v_omega_dev_tenant UUID := '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';
  v_role_id UUID;
  v_inserted_count INT;
BEGIN
  -- Get DataGov Admin role
  SELECT id INTO v_role_id 
  FROM roles 
  WHERE tenant_id = v_omega_dev_tenant 
  AND name = 'DataGov Admin';
  
  IF v_role_id IS NULL THEN
    RAISE EXCEPTION 'DataGov Admin role not found for OMEGA-DEV';
  END IF;
  
  -- Delete existing authorizations for this role
  DELETE FROM role_authorization_objects 
  WHERE role_id = v_role_id;
  
  -- Grant all DG authorizations
  INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id, field_values)
  SELECT 
    v_role_id, 
    ao.id, 
    v_omega_dev_tenant, 
    '{"access_level": "full", "can_approve": true, "can_delete": true}'
  FROM authorization_objects ao
  WHERE ao.module = 'DG'
  AND ao.tenant_id = v_omega_dev_tenant;
  
  GET DIAGNOSTICS v_inserted_count = ROW_COUNT;
  
  RAISE NOTICE 'Granted % DG authorizations to DataGov Admin role', v_inserted_count;
END $$;

-- Verify
SELECT 
  r.name as role_name,
  COUNT(rao.auth_object_id) as dg_auth_count,
  STRING_AGG(ao.object_name, ', ' ORDER BY ao.object_name) FILTER (WHERE ao.object_name LIKE 'Z_DG_%') as sample_auths
FROM roles r
LEFT JOIN role_authorization_objects rao ON r.id = rao.role_id
LEFT JOIN authorization_objects ao ON rao.auth_object_id = ao.id AND ao.module = 'DG'
WHERE r.tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
AND r.name = 'DataGov Admin'
GROUP BY r.name;
