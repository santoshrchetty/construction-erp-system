-- =====================================================
-- RENAME: Add external_ prefix to all organization tables
-- =====================================================
-- Purpose: Avoid confusion with internal org_hierarchy table
-- Safe to run: Checks before renaming
-- =====================================================

DO $$
BEGIN
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'RENAMING ORGANIZATION TABLES';
  RAISE NOTICE '==============================================';
  
  -- =====================================================
  -- 1. RENAME: organizations → external_organizations
  -- =====================================================
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organizations')
     AND NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'external_organizations') THEN
    
    RAISE NOTICE '1. Renaming organizations → external_organizations...';
    ALTER TABLE organizations RENAME TO external_organizations;
    ALTER TABLE external_organizations RENAME COLUMN organization_id TO external_org_id;
    ALTER INDEX IF EXISTS idx_organizations_tenant RENAME TO idx_external_orgs_tenant;
    ALTER INDEX IF EXISTS idx_organizations_internal RENAME TO idx_external_orgs_internal;
    RAISE NOTICE '   ✓ Done';
  ELSE
    RAISE NOTICE '1. external_organizations already exists - skipping';
  END IF;
  
  -- =====================================================
  -- 2. RENAME: organization_users → external_org_users
  -- =====================================================
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organization_users')
     AND NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'external_org_users') THEN
    
    RAISE NOTICE '2. Renaming organization_users → external_org_users...';
    ALTER TABLE organization_users RENAME TO external_org_users;
    ALTER TABLE external_org_users RENAME COLUMN org_user_id TO external_org_user_id;
    ALTER TABLE external_org_users RENAME COLUMN organization_id TO external_org_id;
    ALTER INDEX IF EXISTS idx_org_users_org RENAME TO idx_external_org_users_org;
    ALTER INDEX IF EXISTS idx_org_users_user RENAME TO idx_external_org_users_user;
    ALTER INDEX IF EXISTS idx_org_users_tenant RENAME TO idx_external_org_users_tenant;
    RAISE NOTICE '   ✓ Done';
  ELSE
    RAISE NOTICE '2. external_org_users already exists - skipping';
  END IF;
  
  -- =====================================================
  -- 3. RENAME: organization_relationships → external_org_relationships
  -- =====================================================
  
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organization_relationships')
     AND NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'external_org_relationships') THEN
    
    RAISE NOTICE '3. Renaming organization_relationships → external_org_relationships...';
    ALTER TABLE organization_relationships RENAME TO external_org_relationships;
    ALTER TABLE external_org_relationships RENAME COLUMN source_org_id TO source_external_org_id;
    ALTER TABLE external_org_relationships RENAME COLUMN target_org_id TO target_external_org_id;
    ALTER INDEX IF EXISTS idx_org_relationships_source RENAME TO idx_external_org_rels_source;
    ALTER INDEX IF EXISTS idx_org_relationships_target RENAME TO idx_external_org_rels_target;
    RAISE NOTICE '   ✓ Done';
  ELSE
    RAISE NOTICE '3. external_org_relationships already exists - skipping';
  END IF;
  
  -- =====================================================
  -- 4. UPDATE FOREIGN KEY COLUMNS IN OTHER TABLES
  -- =====================================================
  
  RAISE NOTICE '4. Updating foreign key columns in dependent tables...';
  
  -- resource_access
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'resource_access' AND column_name = 'organization_id') THEN
    ALTER TABLE resource_access RENAME COLUMN organization_id TO external_org_id;
    RAISE NOTICE '   ✓ resource_access';
  END IF;
  
  -- drawing_raci
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'drawing_raci' AND column_name = 'organization_id') THEN
    ALTER TABLE drawing_raci RENAME COLUMN organization_id TO external_org_id;
    RAISE NOTICE '   ✓ drawing_raci';
  END IF;
  
  -- drawing_customer_approvals
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'drawing_customer_approvals' AND column_name = 'organization_id') THEN
    ALTER TABLE drawing_customer_approvals RENAME COLUMN organization_id TO external_org_id;
    RAISE NOTICE '   ✓ drawing_customer_approvals';
  END IF;
  
  -- vendor_progress_updates
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'vendor_progress_updates' AND column_name = 'organization_id') THEN
    ALTER TABLE vendor_progress_updates RENAME COLUMN organization_id TO external_org_id;
    RAISE NOTICE '   ✓ vendor_progress_updates';
  END IF;
  
  -- field_service_tickets
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'field_service_tickets' AND column_name = 'assigned_organization_id') THEN
    ALTER TABLE field_service_tickets RENAME COLUMN assigned_organization_id TO assigned_external_org_id;
    RAISE NOTICE '   ✓ field_service_tickets';
  END IF;
  
  -- external_access_audit_log
  IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'external_access_audit_log' AND column_name = 'organization_id') THEN
    ALTER TABLE external_access_audit_log RENAME COLUMN organization_id TO external_org_id;
    RAISE NOTICE '   ✓ external_access_audit_log';
  END IF;
  
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'RENAME COMPLETE!';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  RAISE NOTICE 'OLD NAMES → NEW NAMES:';
  RAISE NOTICE '  organizations → external_organizations';
  RAISE NOTICE '  organization_users → external_org_users';
  RAISE NOTICE '  organization_relationships → external_org_relationships';
  RAISE NOTICE '';
  RAISE NOTICE 'These tables represent EXTERNAL companies:';
  RAISE NOTICE '  (customers, vendors, contractors)';
  RAISE NOTICE '';
  RAISE NOTICE 'Your INTERNAL org structure remains in:';
  RAISE NOTICE '  org_hierarchy (or organizational_hierarchy)';
  RAISE NOTICE '==============================================';
  
END $$;

-- Verify the renames
SELECT 'external_organizations' as table_name, COUNT(*) as count FROM external_organizations
UNION ALL
SELECT 'external_org_users', COUNT(*) FROM external_org_users
UNION ALL
SELECT 'external_org_relationships', COUNT(*) FROM external_org_relationships;
