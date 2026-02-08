-- ============================================================================
-- TENANT-AWARE get_user_modules() RPC Function
-- ============================================================================
-- Run this entire block as ONE statement in Supabase SQL Editor
-- ============================================================================

CREATE OR REPLACE FUNCTION get_user_modules(p_user_id uuid)
RETURNS TABLE(module_code text)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tenant_id uuid;
BEGIN
  -- Get user's tenant_id first
  SELECT tenant_id INTO v_tenant_id
  FROM users
  WHERE id = p_user_id;
  
  -- If user not found or no tenant, return empty
  IF v_tenant_id IS NULL THEN
    RETURN;
  END IF;
  
  -- Return distinct module names with EXPLICIT tenant isolation
  RETURN QUERY
  SELECT DISTINCT ao.module::text
  FROM user_roles ur
  JOIN roles r ON ur.role_id = r.id
  JOIN role_authorization_objects rao ON r.id = rao.role_id
  JOIN authorization_objects ao ON rao.auth_object_id = ao.id
  WHERE ur.user_id = p_user_id
    -- EXPLICIT TENANT CHECKS on every table
    AND ur.tenant_id = v_tenant_id
    AND r.tenant_id = v_tenant_id
    AND rao.tenant_id = v_tenant_id
    AND ao.tenant_id = v_tenant_id
    -- Active checks
    AND r.is_active = true
    AND ao.is_active = true
    AND ao.module IS NOT NULL
    AND TRIM(ao.module) != ''
  ORDER BY ao.module::text;
END;
$$;

-- Grant permissions (run separately after function creation)
GRANT EXECUTE ON FUNCTION get_user_modules(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_modules(uuid) TO anon;

-- Test query (run separately after grants)
SELECT 
    'Tenant-aware test' as test,
    u.email,
    u.tenant_id,
    module_code
FROM get_user_modules('9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid) gum
CROSS JOIN users u
WHERE u.id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid
ORDER BY module_code;
