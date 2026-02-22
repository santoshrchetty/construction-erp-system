-- =====================================================
-- MIGRATE USERS TABLE FOR MULTI-TENANT SUPPORT
-- =====================================================

-- Step 1: Drop foreign key constraint to auth.users
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_id_fkey;

-- Step 2: Drop unique constraint on email
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_email_key;

-- Step 3: Add composite unique constraint on (email, tenant_id)
ALTER TABLE users ADD CONSTRAINT users_email_tenant_key UNIQUE (email, tenant_id);

-- Step 4: Create user in OMEGA-DEV tenant
DO $$
DECLARE
  v_tenant_id UUID;
  v_auth_user_id UUID;
  v_role_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM tenants WHERE tenant_code = 'OMEGA-DEV';
  SELECT id INTO v_auth_user_id FROM auth.users WHERE email = 'internaluser@abc.com';
  SELECT id INTO v_role_id FROM roles WHERE name = 'Internal Admin' LIMIT 1;
  
  -- Create new user record for OMEGA-DEV tenant (new UUID since id is PK)
  INSERT INTO users (id, email, first_name, last_name, tenant_id, role_id, is_active)
  VALUES (gen_random_uuid(), 'internaluser@abc.com', 'Internal', 'User', v_tenant_id, v_role_id, true)
  ON CONFLICT (email, tenant_id) DO NOTHING;
  
  -- Grant DG authorizations
  INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id, field_values)
  SELECT v_role_id, ao.id, v_tenant_id, '{"access_level": "full", "can_approve": true, "can_delete": true}'
  FROM authorization_objects ao
  WHERE ao.module = 'DG' AND ao.tenant_id = v_tenant_id
  AND NOT EXISTS (SELECT 1 FROM role_authorization_objects WHERE role_id = v_role_id AND auth_object_id = ao.id AND tenant_id = v_tenant_id);
  
  RAISE NOTICE 'User created in OMEGA-DEV!';
END $$;

-- Verify
SELECT email, t.tenant_code, r.name as role
FROM users u
JOIN tenants t ON u.tenant_id = t.id
LEFT JOIN roles r ON u.role_id = r.id
WHERE email = 'internaluser@abc.com'
ORDER BY t.tenant_code;
