-- =====================================================
-- ENSURE DG AUTHORIZATIONS EXIST FOR OMEGA-DEV
-- =====================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_role_id UUID;
BEGIN
  -- Get OMEGA-DEV tenant
  SELECT id INTO v_tenant_id FROM tenants WHERE tenant_code = 'OMEGA-DEV';
  
  -- Get existing Internal Admin role
  SELECT id INTO v_role_id FROM roles WHERE name = 'Internal Admin' LIMIT 1;
  
  -- Grant DG authorizations to role for OMEGA-DEV tenant
  INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id, field_values)
  SELECT v_role_id, ao.id, v_tenant_id, '{"access_level": "full", "can_approve": true, "can_delete": true}'
  FROM authorization_objects ao
  WHERE ao.module = 'DG'
  AND ao.tenant_id = v_tenant_id
  AND NOT EXISTS (SELECT 1 FROM role_authorization_objects WHERE role_id = v_role_id AND auth_object_id = ao.id AND tenant_id = v_tenant_id);
  
  RAISE NOTICE 'DG authorizations granted for OMEGA-DEV!';
END $$;

-- Verify user can access both tenants
SELECT 
  'User Tenants' as check_type,
  t.tenant_code,
  ut.is_active
FROM user_tenants ut
JOIN tenants t ON ut.tenant_id = t.id
WHERE ut.user_id = (SELECT id FROM users WHERE email = 'internaluser@abc.com')
ORDER BY t.tenant_code;
