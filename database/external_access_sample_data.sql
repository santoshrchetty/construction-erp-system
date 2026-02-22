-- =====================================================
-- EXTERNAL ACCESS - SAMPLE DATA
-- =====================================================
-- Purpose: Create test data to validate external access implementation
-- Run after: external_access_migration.sql
-- Works with existing data - checks before inserting
-- =====================================================

DO $$
DECLARE
  v_tenant_id UUID;
  v_project_id UUID;
  v_internal_org_id UUID;
  v_customer_org_id UUID;
  v_vendor_org_id UUID;
  v_contractor_org_id UUID;
  v_facility_id UUID;
  v_equipment_id UUID;
  v_drawing_id UUID;
  v_user_id UUID;
  v_org_count INT := 0;
  v_access_count INT := 0;
BEGIN
  -- Get first tenant
  SELECT id INTO v_tenant_id FROM tenants LIMIT 1;
  
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'No tenant found. Please create a tenant first.';
  END IF;
  
  -- Get first project (if exists)
  SELECT id INTO v_project_id FROM projects WHERE tenant_id = v_tenant_id LIMIT 1;
  
  -- Get first user (if exists)
  SELECT id INTO v_user_id FROM users WHERE tenant_id = v_tenant_id LIMIT 1;
  
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Using tenant_id: %', v_tenant_id;
  RAISE NOTICE 'Using project_id: %', COALESCE(v_project_id::text, 'NONE');
  RAISE NOTICE 'Using user_id: %', COALESCE(v_user_id::text, 'NONE');
  RAISE NOTICE '==============================================';
  
  -- =====================================================
  -- 1. CREATE ORGANIZATIONS (if not exist)
  -- =====================================================
  
  -- Internal organization
  SELECT organization_id INTO v_internal_org_id 
  FROM organizations WHERE tenant_id = v_tenant_id AND org_code = 'INTERNAL';
  
  IF v_internal_org_id IS NULL THEN
    INSERT INTO organizations (organization_id, tenant_id, org_code, org_name, is_internal, is_active)
    VALUES (gen_random_uuid(), v_tenant_id, 'INTERNAL', 'ABC Construction Company', true, true)
    RETURNING organization_id INTO v_internal_org_id;
    v_org_count := v_org_count + 1;
  END IF;
  
  -- Customer organization
  SELECT organization_id INTO v_customer_org_id 
  FROM organizations WHERE tenant_id = v_tenant_id AND org_code = 'CUST001';
  
  IF v_customer_org_id IS NULL THEN
    INSERT INTO organizations (organization_id, tenant_id, org_code, org_name, is_internal, is_active)
    VALUES (gen_random_uuid(), v_tenant_id, 'CUST001', 'Acme Manufacturing Corp', false, true)
    RETURNING organization_id INTO v_customer_org_id;
    v_org_count := v_org_count + 1;
  END IF;
  
  -- Vendor organization
  SELECT organization_id INTO v_vendor_org_id 
  FROM organizations WHERE tenant_id = v_tenant_id AND org_code = 'VEND001';
  
  IF v_vendor_org_id IS NULL THEN
    INSERT INTO organizations (organization_id, tenant_id, org_code, org_name, is_internal, is_active)
    VALUES (gen_random_uuid(), v_tenant_id, 'VEND001', 'Steel Supply Inc', false, true)
    RETURNING organization_id INTO v_vendor_org_id;
    v_org_count := v_org_count + 1;
  END IF;
  
  -- Contractor organization
  SELECT organization_id INTO v_contractor_org_id 
  FROM organizations WHERE tenant_id = v_tenant_id AND org_code = 'CONT001';
  
  IF v_contractor_org_id IS NULL THEN
    INSERT INTO organizations (organization_id, tenant_id, org_code, org_name, is_internal, is_active)
    VALUES (gen_random_uuid(), v_tenant_id, 'CONT001', 'Elite Electrical Services', false, true)
    RETURNING organization_id INTO v_contractor_org_id;
    v_org_count := v_org_count + 1;
  END IF;
  
  RAISE NOTICE 'Organizations: % new, % total', v_org_count, (SELECT COUNT(*) FROM organizations WHERE tenant_id = v_tenant_id);
  
  -- =====================================================
  -- 2. CREATE ORGANIZATION RELATIONSHIPS (if not exist)
  -- =====================================================
  
  INSERT INTO organization_relationships (tenant_id, source_org_id, target_org_id, relationship_type)
  SELECT v_tenant_id, v_internal_org_id, v_customer_org_id, 'CUSTOMER'
  WHERE NOT EXISTS (
    SELECT 1 FROM organization_relationships 
    WHERE source_org_id = v_internal_org_id AND target_org_id = v_customer_org_id
  );
  
  INSERT INTO organization_relationships (tenant_id, source_org_id, target_org_id, relationship_type)
  SELECT v_tenant_id, v_internal_org_id, v_vendor_org_id, 'VENDOR'
  WHERE NOT EXISTS (
    SELECT 1 FROM organization_relationships 
    WHERE source_org_id = v_internal_org_id AND target_org_id = v_vendor_org_id
  );
  
  INSERT INTO organization_relationships (tenant_id, source_org_id, target_org_id, relationship_type)
  SELECT v_tenant_id, v_internal_org_id, v_contractor_org_id, 'VENDOR'
  WHERE NOT EXISTS (
    SELECT 1 FROM organization_relationships 
    WHERE source_org_id = v_internal_org_id AND target_org_id = v_contractor_org_id
  );
  
  RAISE NOTICE 'Organization relationships: % total', (SELECT COUNT(*) FROM organization_relationships WHERE tenant_id = v_tenant_id);
  
  -- =====================================================
  -- 3. CREATE FACILITIES (if not exist)
  -- =====================================================
  
  SELECT facility_id INTO v_facility_id 
  FROM facilities WHERE tenant_id = v_tenant_id AND facility_code = 'FAC001';
  
  IF v_facility_id IS NULL THEN
    INSERT INTO facilities (facility_id, tenant_id, facility_code, facility_name, facility_type, 
      address, city, country, operational_status, commissioned_date)
    VALUES (gen_random_uuid(), v_tenant_id, 'FAC001', 'Main Production Plant', 'FACTORY',
      '123 Industrial Blvd', 'Houston', 'USA', 'OPERATIONAL', '2020-01-15')
    RETURNING facility_id INTO v_facility_id;
    RAISE NOTICE 'Created facility: %', v_facility_id;
  ELSE
    RAISE NOTICE 'Using existing facility: %', v_facility_id;
  END IF;
  
  -- =====================================================
  -- 4. CREATE EQUIPMENT (if not exist)
  -- =====================================================
  
  SELECT equipment_id INTO v_equipment_id 
  FROM equipment_register WHERE tenant_id = v_tenant_id AND equipment_tag = 'PUMP-001';
  
  IF v_equipment_id IS NULL THEN
    INSERT INTO equipment_register (equipment_id, tenant_id, facility_id, equipment_tag, 
      equipment_name, equipment_type, system_tag, manufacturer, model_number, serial_number)
    VALUES (gen_random_uuid(), v_tenant_id, v_facility_id, 'PUMP-001', 
      'Primary Cooling Pump', 'PUMP', 'COOLING-SYS', 'Grundfos', 'CR-150', 'SN123456')
    RETURNING equipment_id INTO v_equipment_id;
    RAISE NOTICE 'Created equipment: %', v_equipment_id;
  ELSE
    RAISE NOTICE 'Using existing equipment: %', v_equipment_id;
  END IF;
  
  -- =====================================================
  -- 5. USE EXISTING DRAWING (skip creating sample)
  -- =====================================================
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'drawings') THEN
    -- Use existing drawing only
    SELECT id INTO v_drawing_id FROM drawings WHERE tenant_id = v_tenant_id LIMIT 1;
    
    IF v_drawing_id IS NOT NULL THEN
      RAISE NOTICE 'Using existing drawing: %', v_drawing_id;
    ELSE
      RAISE NOTICE 'No drawings found - skipping drawing-related setup';
    END IF;
  END IF;
  
  -- =====================================================
  -- 6. GRANT RESOURCE ACCESS (if not exist)
  -- =====================================================
  
  -- Grant customer access to project
  IF v_project_id IS NOT NULL THEN
    INSERT INTO resource_access (tenant_id, organization_id, resource_type, resource_id, 
      project_id, access_purpose, access_level, access_start_date, granted_by)
    SELECT v_tenant_id, v_customer_org_id, 'PROJECT', v_project_id, 
      v_project_id, 'APPROVAL', 'READ', CURRENT_DATE, v_user_id
    WHERE NOT EXISTS (
      SELECT 1 FROM resource_access 
      WHERE organization_id = v_customer_org_id AND resource_type = 'PROJECT' AND resource_id = v_project_id
    );
  END IF;
  
  -- Grant customer access to drawing
  IF v_drawing_id IS NOT NULL THEN
    INSERT INTO resource_access (tenant_id, organization_id, resource_type, resource_id, 
      project_id, access_purpose, access_level, access_start_date, granted_by)
    SELECT v_tenant_id, v_customer_org_id, 'DRAWING', v_drawing_id, 
      v_project_id, 'APPROVAL', 'COMMENT', CURRENT_DATE, v_user_id
    WHERE NOT EXISTS (
      SELECT 1 FROM resource_access 
      WHERE organization_id = v_customer_org_id AND resource_type = 'DRAWING' AND resource_id = v_drawing_id
    );
  END IF;
  
  -- Grant vendor access to facility
  INSERT INTO resource_access (tenant_id, organization_id, resource_type, resource_id, 
    project_id, access_purpose, access_level, access_start_date, granted_by)
  SELECT v_tenant_id, v_vendor_org_id, 'FACILITY', v_facility_id, 
    v_project_id, 'SUPPLY', 'READ', CURRENT_DATE, v_user_id
  WHERE NOT EXISTS (
    SELECT 1 FROM resource_access 
    WHERE organization_id = v_vendor_org_id AND resource_type = 'FACILITY' AND resource_id = v_facility_id
  );
  
  -- Grant contractor access to equipment
  INSERT INTO resource_access (tenant_id, organization_id, resource_type, resource_id, 
    project_id, access_purpose, access_level, access_start_date, granted_by)
  SELECT v_tenant_id, v_contractor_org_id, 'EQUIPMENT', v_equipment_id, 
    v_project_id, 'MAINTENANCE', 'WRITE', CURRENT_DATE, v_user_id
  WHERE NOT EXISTS (
    SELECT 1 FROM resource_access 
    WHERE organization_id = v_contractor_org_id AND resource_type = 'EQUIPMENT' AND resource_id = v_equipment_id
  );
  
  RAISE NOTICE 'Resource access: % total grants', (SELECT COUNT(*) FROM resource_access WHERE tenant_id = v_tenant_id);
  
  -- =====================================================
  -- 7. CREATE DRAWING RACI (if drawing exists and not already assigned)
  -- =====================================================
  
  IF v_drawing_id IS NOT NULL AND v_user_id IS NOT NULL THEN
    INSERT INTO drawing_raci (tenant_id, drawing_id, user_id, raci_role, responsibility_area)
    SELECT v_tenant_id, v_drawing_id, v_user_id, 'ACCOUNTABLE', 'Design Approval'
    WHERE NOT EXISTS (
      SELECT 1 FROM drawing_raci WHERE drawing_id = v_drawing_id AND user_id = v_user_id AND raci_role = 'ACCOUNTABLE'
    );
    
    INSERT INTO drawing_raci (tenant_id, drawing_id, user_id, raci_role, responsibility_area)
    SELECT v_tenant_id, v_drawing_id, v_user_id, 'RESPONSIBLE', 'Design Execution'
    WHERE NOT EXISTS (
      SELECT 1 FROM drawing_raci WHERE drawing_id = v_drawing_id AND user_id = v_user_id AND raci_role = 'RESPONSIBLE'
    );
    
    -- Organization-level RACI
    INSERT INTO drawing_raci (tenant_id, drawing_id, organization_id, raci_role, responsibility_area)
    SELECT v_tenant_id, v_drawing_id, v_customer_org_id, 'CONSULTED', 'Design Review'
    WHERE NOT EXISTS (
      SELECT 1 FROM drawing_raci WHERE drawing_id = v_drawing_id AND organization_id = v_customer_org_id
    );
    
    RAISE NOTICE 'Drawing RACI: % total assignments', (SELECT COUNT(*) FROM drawing_raci WHERE drawing_id = v_drawing_id);
  END IF;
  
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Sample data creation completed successfully!';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'Organizations: 4 (1 internal, 3 external)';
  RAISE NOTICE 'Facilities: 1';
  RAISE NOTICE 'Equipment: 1';
  RAISE NOTICE 'Resource Access Grants: 4';
  RAISE NOTICE '==============================================';
  
END $$;

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- View all organizations
SELECT org_code, org_name, is_internal, is_active 
FROM organizations 
ORDER BY is_internal DESC, org_code;

-- View organization relationships
SELECT 
  o1.org_name as source_org,
  o2.org_name as target_org,
  r.relationship_type
FROM organization_relationships r
JOIN organizations o1 ON r.source_org_id = o1.organization_id
JOIN organizations o2 ON r.target_org_id = o2.organization_id;

-- View resource access grants
SELECT 
  o.org_name,
  ra.resource_type,
  ra.access_purpose,
  ra.access_level,
  ra.is_active
FROM resource_access ra
JOIN organizations o ON ra.organization_id = o.organization_id
ORDER BY o.org_name, ra.resource_type;

-- View facilities
SELECT facility_code, facility_name, facility_type, operational_status
FROM facilities;

-- View equipment
SELECT equipment_tag, equipment_name, equipment_type, operational_status
FROM equipment_register;
