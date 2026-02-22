-- =====================================================
-- GRANT DOCUMENT GOVERNANCE AUTHORIZATIONS TO TEST USERS
-- =====================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_internal_role_id UUID;
  v_customer_role_id UUID;
  v_vendor_role_id UUID;
  v_contractor_role_id UUID;
BEGIN
  -- Get first tenant
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  
  -- Get roles for each test user type (skip if NULL)
  SELECT role_id INTO v_internal_role_id FROM users WHERE email = 'internaluser@abc.com';
  SELECT role_id INTO v_customer_role_id FROM users WHERE email = 'customeruser@acme.com';
  SELECT role_id INTO v_vendor_role_id FROM users WHERE email = 'vendoruser@steel.com';
  SELECT role_id INTO v_contractor_role_id FROM users WHERE email = 'contractoruser@elite.com';
  
  -- INTERNAL USER: Full access to all DG modules
  IF v_internal_role_id IS NOT NULL THEN
    INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id, field_values)
    SELECT v_internal_role_id, ao.id, v_tenant_id, '{"access_level": "full", "can_approve": true, "can_delete": true}'
    FROM authorization_objects ao
    WHERE ao.module = 'DG'
    AND NOT EXISTS (SELECT 1 FROM role_authorization_objects WHERE role_id = v_internal_role_id AND auth_object_id = ao.id);
    RAISE NOTICE 'Internal user: % authorizations granted', (SELECT COUNT(*) FROM authorization_objects WHERE module = 'DG');
  ELSE
    RAISE NOTICE 'Internal user has no role assigned - skipping';
  END IF;
  
  -- CUSTOMER USER: View drawings, contracts, RFIs, approve drawings
  IF v_customer_role_id IS NOT NULL THEN
    INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id, field_values)
    SELECT v_customer_role_id, ao.id, v_tenant_id, '{"access_level": "read", "can_approve": true, "disciplines": ["Civil", "Structural"]}'
    FROM authorization_objects ao
    WHERE ao.module = 'DG'
    AND ao.object_name IN ('Z_DG_DRAWING', 'Z_DG_DRW_VW', 'Z_DG_DRW_APP', 'Z_DG_CONTRACT', 'Z_DG_CNT_VW', 'Z_DG_RFI', 'Z_DG_RFI_CRT')
    AND NOT EXISTS (SELECT 1 FROM role_authorization_objects WHERE role_id = v_customer_role_id AND auth_object_id = ao.id);
    RAISE NOTICE 'Customer user: 7 authorizations granted';
  ELSE
    RAISE NOTICE 'Customer user has no role assigned - skipping';
  END IF;
  
  -- VENDOR USER: View/create submittals, view specs, create RFIs
  IF v_vendor_role_id IS NOT NULL THEN
    INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id, field_values)
    SELECT v_vendor_role_id, ao.id, v_tenant_id, '{"access_level": "write", "vendor_type": "supplier", "categories": ["Materials", "Equipment"]}'
    FROM authorization_objects ao
    WHERE ao.module = 'DG'
    AND ao.object_name IN ('Z_DG_SUBMITTAL', 'Z_DG_SUB_CRT', 'Z_DG_SPEC', 'Z_DG_SPC_VW', 'Z_DG_RFI', 'Z_DG_RFI_CRT')
    AND NOT EXISTS (SELECT 1 FROM role_authorization_objects WHERE role_id = v_vendor_role_id AND auth_object_id = ao.id);
    RAISE NOTICE 'Vendor user: 6 authorizations granted';
  ELSE
    RAISE NOTICE 'Vendor user has no role assigned - skipping';
  END IF;
  
  -- CONTRACTOR USER: View drawings, create RFIs, view contracts, create change orders
  IF v_contractor_role_id IS NOT NULL THEN
    INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id, field_values)
    SELECT v_contractor_role_id, ao.id, v_tenant_id, '{"access_level": "write", "can_create_rfi": true, "max_change_order_value": 50000}'
    FROM authorization_objects ao
    WHERE ao.module = 'DG'
    AND ao.object_name IN ('Z_DG_DRAWING', 'Z_DG_DRW_VW', 'Z_DG_RFI', 'Z_DG_RFI_CRT', 'Z_DG_CONTRACT', 'Z_DG_CNT_VW', 'Z_DG_CHANGE', 'Z_DG_CHG_CRT')
    AND NOT EXISTS (SELECT 1 FROM role_authorization_objects WHERE role_id = v_contractor_role_id AND auth_object_id = ao.id);
    RAISE NOTICE 'Contractor user: 8 authorizations granted';
  ELSE
    RAISE NOTICE 'Contractor user has no role assigned - skipping';
  END IF;
END $$;

-- Verify authorizations by user
SELECT 
  u.email,
  COALESCE(r.name, 'NO ROLE') as role_name,
  COUNT(rao.auth_object_id) as auth_count
FROM users u
LEFT JOIN roles r ON u.role_id = r.id
LEFT JOIN role_authorization_objects rao ON r.id = rao.role_id
LEFT JOIN authorization_objects ao ON rao.auth_object_id = ao.id AND ao.module = 'DG'
WHERE u.email IN ('internaluser@abc.com', 'customeruser@acme.com', 'vendoruser@steel.com', 'contractoruser@elite.com')
GROUP BY u.email, r.name
ORDER BY u.email;
