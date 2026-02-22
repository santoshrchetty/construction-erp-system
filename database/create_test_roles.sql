-- =====================================================
-- CREATE ROLES AND ASSIGN TO TEST USERS
-- =====================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_internal_role UUID;
  v_customer_role UUID;
  v_vendor_role UUID;
  v_contractor_role UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  
  -- Create Internal Admin role
  INSERT INTO roles (id, tenant_id, name, description, is_active)
  VALUES (gen_random_uuid(), v_tenant_id, 'Internal Admin', 'Full system access', true)
  RETURNING id INTO v_internal_role;
  
  -- Create Customer role
  INSERT INTO roles (id, tenant_id, name, description, is_active)
  VALUES (gen_random_uuid(), v_tenant_id, 'Customer', 'Customer access', true)
  RETURNING id INTO v_customer_role;
  
  -- Create Vendor role
  INSERT INTO roles (id, tenant_id, name, description, is_active)
  VALUES (gen_random_uuid(), v_tenant_id, 'Vendor', 'Vendor access', true)
  RETURNING id INTO v_vendor_role;
  
  -- Create Contractor role
  INSERT INTO roles (id, tenant_id, name, description, is_active)
  VALUES (gen_random_uuid(), v_tenant_id, 'Contractor', 'Contractor access', true)
  RETURNING id INTO v_contractor_role;
  
  -- Assign roles to users
  UPDATE users SET role_id = v_internal_role WHERE email = 'internaluser@abc.com';
  UPDATE users SET role_id = v_customer_role WHERE email = 'customeruser@acme.com';
  UPDATE users SET role_id = v_vendor_role WHERE email = 'vendoruser@steel.com';
  UPDATE users SET role_id = v_contractor_role WHERE email = 'contractoruser@elite.com';
  
  RAISE NOTICE 'Roles created and assigned!';
END $$;

-- Verify
SELECT email, r.name as role_name
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
WHERE u.email IN ('internaluser@abc.com', 'customeruser@acme.com', 'vendoruser@steel.com', 'contractoruser@elite.com')
ORDER BY u.email;
