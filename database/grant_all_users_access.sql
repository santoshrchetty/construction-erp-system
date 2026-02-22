-- =====================================================
-- GRANT DG ACCESS TO ALL USERS WITHOUT ROLES
-- =====================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_admin_role_id UUID;
  v_user RECORD;
BEGIN
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  
  -- Get or create Internal Admin role
  SELECT id INTO v_admin_role_id FROM roles WHERE tenant_id = v_tenant_id AND name = 'Internal Admin';
  
  IF v_admin_role_id IS NULL THEN
    INSERT INTO roles (id, tenant_id, name, description, is_active)
    VALUES (gen_random_uuid(), v_tenant_id, 'Internal Admin', 'Full system access', true)
    RETURNING id INTO v_admin_role_id;
  END IF;
  
  -- Grant DG authorizations to admin role if not already granted
  INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id, field_values)
  SELECT v_admin_role_id, ao.id, v_tenant_id, '{"access_level": "full", "can_approve": true, "can_delete": true}'
  FROM authorization_objects ao
  WHERE ao.module = 'DG'
  AND ao.tenant_id = v_tenant_id
  AND NOT EXISTS (SELECT 1 FROM role_authorization_objects WHERE role_id = v_admin_role_id AND auth_object_id = ao.id);
  
  -- Assign admin role to all users without roles
  FOR v_user IN 
    SELECT id, email FROM users WHERE tenant_id = v_tenant_id AND role_id IS NULL
  LOOP
    UPDATE users SET role_id = v_admin_role_id WHERE id = v_user.id;
    RAISE NOTICE 'Assigned Internal Admin role to: %', v_user.email;
  END LOOP;
  
  RAISE NOTICE 'All users now have DG access!';
END $$;

-- Verify all users
SELECT 
  u.email,
  COALESCE(r.name, 'NO ROLE') as role_name,
  COUNT(rao.auth_object_id) as dg_auth_count
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
LEFT JOIN role_authorization_objects rao ON r.id = rao.role_id
LEFT JOIN authorization_objects ao ON rao.auth_object_id = ao.id AND ao.module = 'DG'
WHERE u.tenant_id = (SELECT id FROM tenants LIMIT 1)
GROUP BY u.email, r.name
ORDER BY u.email;
