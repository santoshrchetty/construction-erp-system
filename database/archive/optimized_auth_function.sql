-- Optimized authorization function with performance improvements
-- ===========================================================

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_role_id_active ON users(role_id, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_roles_name_active ON roles(name, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_role_auth_mapping_lookup ON role_authorization_mapping(role_name, auth_object_name);

-- Optimized authorization function with early exits and minimal joins
CREATE OR REPLACE FUNCTION check_construction_authorization(
  p_user_id UUID,
  p_auth_object_name TEXT
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
STABLE -- Mark as STABLE for better caching
AS $$
DECLARE
  user_role_name TEXT;
BEGIN
  -- Early exit: Check if user exists and is active
  SELECT r.name INTO user_role_name
  FROM users u
  JOIN roles r ON u.role_id = r.id
  WHERE u.id = p_user_id 
  AND u.is_active = true 
  AND r.is_active = true
  LIMIT 1;
  
  -- Early exit: User not found or inactive
  IF user_role_name IS NULL THEN
    RETURN FALSE;
  END IF;
  
  -- Check authorization mapping
  RETURN EXISTS (
    SELECT 1 
    FROM role_authorization_mapping ram
    WHERE ram.role_name = user_role_name
    AND ram.auth_object_name = p_auth_object_name
    LIMIT 1
  );
END;
$$;