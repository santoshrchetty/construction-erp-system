-- Create RPC function to get user's authorized tile module codes
-- This maps authorization object modules to tile module_codes
CREATE OR REPLACE FUNCTION get_user_modules(user_id UUID)
RETURNS TABLE (
  module_code VARCHAR
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT 
    CASE 
      -- Map authorization object modules to tile module_codes
      WHEN ao.module = 'Finance' THEN 'FI'
      WHEN ao.module = 'ADMIN' THEN 'AD'
      WHEN ao.module = 'CG' THEN 'CF'
      WHEN ao.module = 'configuration' THEN 'CF'
      WHEN ao.module = 'materials' THEN 'MM'
      WHEN ao.module = 'procurement' THEN 'MM'
      WHEN ao.module = 'reporting' THEN 'RP'
      WHEN ao.module = 'user_tasks' THEN 'MT'
      WHEN ao.module = 'emergency' THEN 'EM'
      WHEN ao.module = 'integration' THEN 'IN'
      WHEN ao.module = 'DOCS' THEN 'DM'
      -- Direct mappings (already match)
      ELSE ao.module
    END as module_code
  FROM users u
  JOIN roles r ON u.role_id = r.id
  JOIN role_authorization_objects rao ON r.id = rao.role_id
  JOIN authorization_objects ao ON rao.auth_object_id = ao.id
  WHERE u.id = user_id
    AND rao.is_active = true
    AND ao.module IS NOT NULL
  ORDER BY module_code;
END;
$$;
