-- Fix OMEGA-DEV user role mismatch
DO $$
DECLARE
  v_omega_dev_tenant UUID := '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';
  v_omega_dev_role UUID;
  v_omega_dev_user UUID;
BEGIN
  -- Get or create DataGov Admin role for OMEGA-DEV tenant
  SELECT id INTO v_omega_dev_role 
  FROM roles 
  WHERE tenant_id = v_omega_dev_tenant 
  AND name = 'DataGov Admin';
  
  IF v_omega_dev_role IS NULL THEN
    INSERT INTO roles (id, tenant_id, name, description, is_active)
    VALUES (gen_random_uuid(), v_omega_dev_tenant, 'DataGov Admin', 'Document Governance Administrator', true)
    RETURNING id INTO v_omega_dev_role;
    
    RAISE NOTICE 'Created new DataGov Admin role for OMEGA-DEV';
  END IF;
  
  -- Update user to use OMEGA-DEV role
  UPDATE users 
  SET role_id = v_omega_dev_role
  WHERE email = 'internaluser@abc.com'
  AND tenant_id = v_omega_dev_tenant
  RETURNING id INTO v_omega_dev_user;
  
  -- Grant DG authorizations to OMEGA-DEV role
  INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id, field_values)
  SELECT v_omega_dev_role, ao.id, v_omega_dev_tenant, '{"access_level": "full", "can_approve": true, "can_delete": true}'
  FROM authorization_objects ao
  WHERE ao.module = 'DG'
  AND ao.tenant_id = v_omega_dev_tenant
  AND NOT EXISTS (
    SELECT 1 FROM role_authorization_objects 
    WHERE role_id = v_omega_dev_role 
    AND auth_object_id = ao.id 
    AND tenant_id = v_omega_dev_tenant
  );
  
  RAISE NOTICE 'Fixed OMEGA-DEV user role and authorizations';
END $$;

-- Verify fix
SELECT 
  u.email,
  u.tenant_id as user_tenant,
  t.tenant_code,
  r.tenant_id as role_tenant,
  r.name as role_name,
  CASE WHEN u.tenant_id = r.tenant_id THEN '✅ MATCH' ELSE '❌ MISMATCH' END as tenant_match
FROM users u
JOIN tenants t ON u.tenant_id = t.id
JOIN roles r ON u.role_id = r.id
WHERE u.email = 'internaluser@abc.com'
AND t.tenant_code = 'OMEGA-DEV';
