-- ============================================================================
-- ROLLBACK: Restore SAP Codes (Emergency Use Only)
-- ============================================================================
-- Purpose: Restore tiles.module_code to original SAP codes if migration fails
-- Safe to run: YES (but only if backup table exists)
-- When to use: Only if migration causes issues and you need to revert
-- ============================================================================

-- STEP 1: Verify backup table exists
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tiles_backup_sap_codes')
        THEN '✓ Backup table exists - safe to proceed with rollback'
        ELSE '✗ ERROR: Backup table not found - cannot rollback!'
    END as status;

-- STEP 2: Restore tiles.module_code from backup
UPDATE tiles t
SET module_code = b.module_code
FROM tiles_backup_sap_codes b
WHERE t.id = b.id;

-- STEP 3: Verify restoration
SELECT 
    'Rollback verification' as check,
    COUNT(*) as tiles_with_sap_codes
FROM tiles
WHERE module_code IN ('AD', 'CF', 'DM', 'EH', 'EM', 'FI', 'HR', 'IN', 'MM', 'MT', 'PS', 'QM', 'RP', 'WM');
-- Expected: Should match original count (SAP codes restored)

-- STEP 4: Restore original get_user_modules() function with SAP mapping
-- Run the original function from: database/create_get_user_modules_function.sql
-- Or copy-paste the original function here:

DROP FUNCTION IF EXISTS get_user_modules(uuid);

CREATE OR REPLACE FUNCTION get_user_modules(p_user_id uuid)
RETURNS TABLE(module_code text)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT 
    CASE ao.module::text
      WHEN 'admin' THEN 'AD'
      WHEN 'configuration' THEN 'CF'
      WHEN 'materials' THEN 'MM'
      WHEN 'procurement' THEN 'MM'
      WHEN 'projects' THEN 'PS'
      WHEN 'finance' THEN 'FI'
      WHEN 'hr' THEN 'HR'
      WHEN 'warehouse' THEN 'WM'
      WHEN 'quality' THEN 'QM'
      WHEN 'safety' THEN 'EH'
      WHEN 'documents' THEN 'DM'
      WHEN 'reporting' THEN 'RP'
      WHEN 'user_tasks' THEN 'MT'
      WHEN 'emergency' THEN 'EM'
      WHEN 'integration' THEN 'IN'
      ELSE ao.module::text
    END as module_code
  FROM user_roles ur
  JOIN roles r ON ur.role_id = r.id
  JOIN role_authorization_objects rao ON r.id = rao.role_id
  JOIN authorization_objects ao ON rao.auth_object_id = ao.id
  WHERE ur.user_id = p_user_id
    AND r.is_active = true
    AND ao.is_active = true
    AND ao.module IS NOT NULL
    AND TRIM(ao.module) != '';
END;
$$;

GRANT EXECUTE ON FUNCTION get_user_modules(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_modules(uuid) TO anon;

-- STEP 5: Verify RPC function returns SAP codes
SELECT 
    'RPC rollback verification' as check,
    module_code
FROM get_user_modules((SELECT id FROM users WHERE email = 'admin@prom.com'))
ORDER BY module_code;
-- Expected: SAP codes (AD, CF, FI, MM, PS, etc.)

-- STEP 6: Re-add materials module to HR role (if it was removed)
-- This restores the original behavior where HR could see materials tiles
INSERT INTO role_authorization_objects (role_id, auth_object_id, tenant_id)
SELECT 
    (SELECT id FROM roles WHERE name = 'HR'),
    ao.id,
    ao.tenant_id
FROM authorization_objects ao
WHERE ao.module = 'materials'
  AND NOT EXISTS (
    SELECT 1 FROM role_authorization_objects rao
    WHERE rao.role_id = (SELECT id FROM roles WHERE name = 'HR')
      AND rao.auth_object_id = ao.id
  );

-- STEP 7: Final verification
SELECT 
    'ROLLBACK COMPLETE' as status,
    'System restored to SAP codes' as message;

-- ============================================================================
-- POST-ROLLBACK CHECKLIST
-- ============================================================================
-- [ ] Verify tiles.module_code shows SAP codes (AD, CF, MM, PS, etc.)
-- [ ] Verify get_user_modules() returns SAP codes
-- [ ] Test user login and tile visibility
-- [ ] Check that HR user sees materials tiles again (original behavior)
-- [ ] Verify no errors in application logs
-- ============================================================================

-- ============================================================================
-- NOTES
-- ============================================================================
-- After rollback, you'll be back to the original system with:
-- - SAP codes in tiles.module_code
-- - CASE mapping in get_user_modules()
-- - HR role seeing both HR and Materials tiles (the original issue)
--
-- If you need to re-attempt the migration:
-- 1. Investigate what went wrong
-- 2. Fix the issue
-- 3. Re-run the migration steps 1-6
-- ============================================================================
