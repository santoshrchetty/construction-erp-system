-- ============================================================================
-- STEP 3: Simplify get_user_modules() RPC Function
-- ============================================================================
-- Purpose: Remove SAP code mapping layer, return friendly module names directly
-- Safe to run: YES (function replacement)
-- Reversible: YES (use database/create_get_user_modules_function.sql to restore)
-- ============================================================================

-- 3.1 Drop existing function with SAP code mapping
DROP FUNCTION IF EXISTS get_user_modules(uuid);

-- 3.2 Create simplified function (direct pass-through, no CASE mapping)
CREATE OR REPLACE FUNCTION get_user_modules(p_user_id uuid)
RETURNS TABLE(module_code text)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Return distinct module names directly from authorization_objects
  -- No more SAP code mapping needed!
  RETURN QUERY
  SELECT DISTINCT ao.module::text
  FROM user_roles ur
  JOIN roles r ON ur.role_id = r.id
  JOIN role_authorization_objects rao ON r.id = rao.role_id
  JOIN authorization_objects ao ON rao.auth_object_id = ao.id
  WHERE ur.user_id = p_user_id
    AND r.is_active = true
    AND ao.is_active = true
    AND ao.module IS NOT NULL
    AND TRIM(ao.module) != ''
  ORDER BY ao.module::text;
END;
$$;

-- 3.3 Grant execute permission
GRANT EXECUTE ON FUNCTION get_user_modules(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_modules(uuid) TO anon;

-- 3.4 Test new function with admin user
-- Replace with actual admin user_id from your system
SELECT 
    'Admin user modules' as test,
    module_code
FROM get_user_modules('9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid)
ORDER BY module_code;
-- Expected: Friendly module names (admin, configuration, finance, materials, projects, etc.)

-- 3.5 Verify function returns friendly names (not SAP codes)
SELECT 
    'Verification: No SAP codes in output' as check_name,
    COUNT(*) as sap_codes_found
FROM get_user_modules('9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid)
WHERE module_code IN ('AD', 'CF', 'DM', 'EH', 'EM', 'FI', 'HR', 'IN', 'MM', 'MT', 'PS', 'QM', 'RP', 'WM');
-- Expected: 0

-- 3.6 Show function definition for verification
SELECT 
    routine_name,
    routine_type,
    data_type as return_type
FROM information_schema.routines
WHERE routine_name = 'get_user_modules'
  AND routine_schema = 'public';
