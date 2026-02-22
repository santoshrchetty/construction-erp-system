-- =====================================================
-- CREATE INTERNALUSER@ABC.COM IN USERS TABLE
-- =====================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_auth_user_id UUID;
  v_role_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  
  -- Get auth user ID
  SELECT id INTO v_auth_user_id FROM auth.users WHERE email = 'internaluser@abc.com';
  
  IF v_auth_user_id IS NULL THEN
    RAISE EXCEPTION 'User internaluser@abc.com not found in auth.users';
  END IF;
  
  -- Get or create Internal Admin role
  SELECT id INTO v_role_id FROM roles WHERE tenant_id = v_tenant_id AND name = 'Internal Admin';
  
  IF v_role_id IS NULL THEN
    INSERT INTO roles (id, tenant_id, name, description, is_active)
    VALUES (gen_random_uuid(), v_tenant_id, 'Internal Admin', 'Full system access', true)
    RETURNING id INTO v_role_id;
  END IF;
  
  -- Create user in public.users
  INSERT INTO users (id, email, first_name, last_name, tenant_id, role_id, is_active)
  VALUES (v_auth_user_id, 'internaluser@abc.com', 'Internal', 'User', v_tenant_id, v_role_id, true)
  ON CONFLICT (id) DO UPDATE SET role_id = v_role_id, tenant_id = v_tenant_id;
  
  -- Grant DG authorizations
  INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id, field_values)
  SELECT v_role_id, ao.id, v_tenant_id, '{"access_level": "full", "can_approve": true, "can_delete": true}'
  FROM authorization_objects ao
  WHERE ao.module = 'DG'
  AND ao.tenant_id = v_tenant_id
  AND NOT EXISTS (SELECT 1 FROM role_authorization_objects WHERE role_id = v_role_id AND auth_object_id = ao.id);
  
  RAISE NOTICE 'User created: internaluser@abc.com';
  RAISE NOTICE 'Tenant: %', v_tenant_id;
  RAISE NOTICE 'Role: Internal Admin';
END $$;

-- Verify
SELECT 
  u.email,
  r.name as role_name,
  COUNT(rao.auth_object_id) as dg_auth_count
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
LEFT JOIN role_authorization_objects rao ON r.id = rao.role_id
LEFT JOIN authorization_objects ao ON rao.auth_object_id = ao.id AND ao.module = 'DG'
WHERE u.email = 'internaluser@abc.com'
GROUP BY u.email, r.name;
