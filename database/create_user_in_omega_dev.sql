-- =====================================================
-- CREATE USER IN OMEGA-DEV TENANT
-- =====================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_auth_user_id UUID;
  v_role_id UUID;
BEGIN
  -- Get OMEGA-DEV tenant
  SELECT id INTO v_tenant_id FROM tenants WHERE tenant_code = 'OMEGA-DEV';
  
  -- Get auth user ID
  SELECT id INTO v_auth_user_id FROM auth.users WHERE email = 'internaluser@abc.com';
  
  -- Get or create Internal Admin role for OMEGA-DEV
  SELECT id INTO v_role_id FROM roles WHERE name = 'Internal Admin' LIMIT 1;
  
  IF v_role_id IS NULL THEN
    INSERT INTO roles (id, tenant_id, name, description, is_active)
    VALUES (gen_random_uuid(), v_tenant_id, 'Internal Admin OMEGA-DEV', 'Full system access', true)
    RETURNING id INTO v_role_id;
  END IF;
  
  -- Update existing user's tenant to OMEGA-DEV or keep OMEGA-TEST
  -- Since users table has unique email, just update the tenant_id
  UPDATE users 
  SET tenant_id = v_tenant_id, role_id = v_role_id
  WHERE email = 'internaluser@abc.com';
  
  -- Grant DG authorizations to role
  INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id, field_values)
  SELECT v_role_id, ao.id, v_tenant_id, '{"access_level": "full", "can_approve": true, "can_delete": true}'
  FROM authorization_objects ao
  WHERE ao.module = 'DG'
  AND ao.tenant_id = v_tenant_id
  AND NOT EXISTS (SELECT 1 FROM role_authorization_objects WHERE role_id = v_role_id AND auth_object_id = ao.id);
  
  RAISE NOTICE 'User created in OMEGA-DEV with full DG access!';
END $$;

-- Verify
SELECT 
  u.email,
  t.tenant_name,
  t.tenant_code,
  r.name as role_name,
  COUNT(rao.auth_object_id) as dg_auth_count
FROM users u
JOIN tenants t ON u.tenant_id = t.id
LEFT JOIN roles r ON u.role_id = r.id
LEFT JOIN role_authorization_objects rao ON r.id = rao.role_id
LEFT JOIN authorization_objects ao ON rao.auth_object_id = ao.id AND ao.module = 'DG'
WHERE u.email = 'internaluser@abc.com'
GROUP BY u.email, t.tenant_name, t.tenant_code, r.name
ORDER BY t.tenant_code;
