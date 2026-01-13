-- Minimal Sample Data for Flexible Approval System
-- Works with existing database tables only

-- 1. Sample approval level templates (if table exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'approval_level_templates') THEN
    INSERT INTO approval_level_templates (template_name, description, customer_type, industry_type, is_public, usage_count) VALUES
    ('Standard 2-Level', 'Basic 2-level approval for small companies', 'SMALL', 'CONSTRUCTION', true, 0),
    ('Construction 3-Level', 'Standard 3-level approval for construction projects', 'MEDIUM', 'CONSTRUCTION', true, 0),
    ('Enterprise 5-Level', 'Complex 5-level approval for large enterprises', 'LARGE', 'CONSTRUCTION', true, 0)
    ON CONFLICT (template_name) DO NOTHING;
  END IF;
END $$;

-- 2. Sample flexible approval levels (if table exists)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'flexible_approval_levels') THEN
    INSERT INTO flexible_approval_levels (
      customer_id, document_type, level_number, level_name, 
      amount_threshold_min, amount_threshold_max, approver_role, 
      is_required, is_active
    ) VALUES
    -- Sample customer 1 - Material Request levels
    ('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 1, 'Supervisor Approval', 0, 10000, 'SUPERVISOR', true, true),
    ('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 2, 'Manager Approval', 10000, 999999999, 'MANAGER', true, true),
    
    -- Sample customer 2 - Purchase Requisition levels  
    ('550e8400-e29b-41d4-a716-446655440002', 'PURCHASE_REQ', 1, 'Site Supervisor', 0, 25000, 'SITE_SUPERVISOR', true, true),
    ('550e8400-e29b-41d4-a716-446655440002', 'PURCHASE_REQ', 2, 'Project Manager', 25000, 100000, 'PROJECT_MANAGER', true, true),
    ('550e8400-e29b-41d4-a716-446655440002', 'PURCHASE_REQ', 3, 'Operations Manager', 100000, 999999999, 'OPERATIONS_MANAGER', true, true)
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- 3. Verify sample data was created
SELECT 'SAMPLE DATA VERIFICATION:' as info;

-- Check if approval templates exist
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'approval_level_templates') THEN
    RAISE NOTICE 'Approval templates table exists - checking data...';
  ELSE
    RAISE NOTICE 'Approval templates table does not exist - skipping template data';
  END IF;
END $$;

-- Check if flexible approval levels exist
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'flexible_approval_levels') THEN
    RAISE NOTICE 'Flexible approval levels table exists - checking data...';
  ELSE
    RAISE NOTICE 'Flexible approval levels table does not exist - skipping level data';
  END IF;
END $$;

-- Show what tables are available for the approval system
SELECT 'AVAILABLE APPROVAL TABLES:' as info;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%approval%' OR table_name LIKE '%flexible%')
ORDER BY table_name;

-- Show authorization objects that were created
SELECT 'APPROVAL AUTHORIZATION OBJECTS:' as info;
SELECT object_name, module, description
FROM authorization_objects 
WHERE object_name IN (
  'AD_APPR_CFG', 'AD_APPR_TPL', 'AD_CUST_APPR', 'AD_APPR_RPT',
  'MM_REQ_UNIFIED', 'MM_REQ_APPROVE', 'MM_REQ_STATUS', 'MM_APPR_DELEG',
  'MM_PR_FLEXIBLE', 'MM_PO_FLEXIBLE', 'MM_PROC_APPR', 'MM_VEND_APPR',
  'CF_DOC_TYPES', 'CF_APPR_ROLES', 'CF_THRESHOLDS', 'CF_NOTIFICATIONS',
  'RP_APPR_PERF', 'RP_PEND_APPR', 'RP_APPR_AUDIT', 'RP_DELEGATIONS',
  'UT_PEND_APPR', 'UT_APPR_HIST', 'UT_DELEGATIONS', 'UT_REQ_STATUS',
  'EM_APPROVALS', 'EM_OVERRIDE', 'EM_BULK_APPR',
  'IN_ERP_SYNC', 'IN_MOBILE_APPR'
)
ORDER BY module, object_name;

-- Show role assignments for approval system
SELECT 'APPROVAL ROLE ASSIGNMENTS:' as info;
SELECT 
  r.name as role_name,
  ao.object_name,
  ao.module,
  rao.field_values
FROM role_authorization_objects rao
JOIN roles r ON rao.role_id = r.id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE ao.object_name LIKE '%APPR%' OR ao.object_name LIKE '%REQ%'
ORDER BY r.name, ao.object_name;