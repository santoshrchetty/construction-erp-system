-- ============================================================================
-- Get User's Authorized Tiles (Module-Level Access)
-- ============================================================================
-- Shows all tiles from modules where user has at least one authorization object
-- ============================================================================

-- Drop ALL versions of the function
DROP FUNCTION IF EXISTS get_user_authorized_tiles(uuid) CASCADE;

-- Create new function - module-level access
CREATE OR REPLACE FUNCTION get_user_authorized_tiles(p_user_id uuid)
RETURNS TABLE (
  tile_id uuid
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT t.id
  FROM users u
  INNER JOIN roles r ON u.role_id = r.id
  INNER JOIN role_authorization_objects rao ON r.id = rao.role_id
  INNER JOIN authorization_objects ao ON rao.auth_object_id = ao.id
  INNER JOIN tiles t ON ao.module = t.module_code
  WHERE u.id = p_user_id
    AND rao.is_active = true
    AND ao.is_active = true
    AND t.is_active = true
    AND u.tenant_id = r.tenant_id
    AND u.tenant_id = rao.tenant_id
    AND u.tenant_id = ao.tenant_id;
END;
$$;

GRANT EXECUTE ON FUNCTION get_user_authorized_tiles(uuid) TO authenticated;
