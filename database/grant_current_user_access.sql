-- =====================================================
-- GRANT CURRENT USER ACCESS TO DOCUMENT GOVERNANCE
-- =====================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_user_id UUID;
  v_role_id UUID;
  v_user_email TEXT;
BEGIN
  -- Get first tenant
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  
  -- Get your current user (replace with your actual email)
  -- Check what email you're logged in with and update this line
  SELECT id, email, role_id INTO v_user_id, v_user_email, v_role_id 
  FROM users 
  WHERE tenant_id = v_tenant_id 
  ORDER BY created_at DESC 
  LIMIT 1;
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'No user found in tenant. Please provide your email.';
  END IF;
  
  -- If user has no role, assign Internal Admin role
  IF v_role_id IS NULL THEN
    -- Get or create Internal Admin role
    SELECT id INTO v_role_id FROM roles WHERE tenant_id = v_tenant_id AND name = 'Internal Admin';
    
    IF v_role_id IS NULL THEN
      INSERT INTO roles (id, tenant_id, name, description, is_active)
      VALUES (gen_random_uuid(), v_tenant_id, 'Internal Admin', 'Full system access', true)
      RETURNING id INTO v_role_id;
    END IF;
    
    -- Assign role to user
    UPDATE users SET role_id = v_role_id WHERE id = v_user_id;
    RAISE NOTICE 'Assigned Internal Admin role to user: %', v_user_email;
  END IF;
  
  -- Grant all DG authorizations to the role
  INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id, field_values)
  SELECT v_role_id, ao.id, v_tenant_id, '{"access_level": "full", "can_approve": true, "can_delete": true}'
  FROM authorization_objects ao
  WHERE ao.module = 'DG'
  AND ao.tenant_id = v_tenant_id
  AND NOT EXISTS (
    SELECT 1 FROM role_authorization_objects 
    WHERE role_id = v_role_id AND auth_object_id = ao.id
  );
  
  RAISE NOTICE 'Document Governance access granted!';
  RAISE NOTICE 'User: %', v_user_email;
  RAISE NOTICE 'Tenant: %', v_tenant_id;
  RAISE NOTICE 'Role: %', v_role_id;
END $$;

-- Verify current user access
SELECT 
  u.email,
  u.tenant_id,
  r.name as role_name,
  COUNT(rao.auth_object_id) as dg_auth_count
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
LEFT JOIN role_authorization_objects rao ON r.id = rao.role_id
LEFT JOIN authorization_objects ao ON rao.auth_object_id = ao.id AND ao.module = 'DG'
WHERE u.tenant_id = (SELECT id FROM tenants LIMIT 1)
GROUP BY u.email, u.tenant_id, r.name
LIMIT 5;
