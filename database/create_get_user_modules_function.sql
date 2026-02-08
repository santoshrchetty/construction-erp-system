-- Drop existing function first
DROP FUNCTION IF EXISTS public.get_user_modules(uuid);

-- Create RPC function with strict role authorization (no fallbacks)
CREATE OR REPLACE FUNCTION public.get_user_modules(user_id uuid)
RETURNS TABLE(module_code text)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Return only user's authorized modules via role (no fallbacks for security)
  RETURN QUERY
  SELECT DISTINCT 
    CASE 
      WHEN ao.module = 'Finance' THEN 'FI'
      WHEN ao.module = 'ADMIN' THEN 'AD'
      WHEN ao.module IN ('CG', 'configuration') THEN 'CF'
      WHEN ao.module IN ('materials', 'procurement') THEN 'MM'
      WHEN ao.module = 'reporting' THEN 'RP'
      WHEN ao.module = 'user_tasks' THEN 'MT'
      WHEN ao.module = 'emergency' THEN 'EM'
      WHEN ao.module = 'integration' THEN 'IN'
      WHEN ao.module = 'DOCS' THEN 'DM'
      ELSE ao.module
    END::text as module_code
  FROM users u
  JOIN role_authorization_objects rao ON rao.role_id = u.role_id
  JOIN authorization_objects ao ON ao.id = rao.authorization_object_id
  WHERE u.id = user_id
    AND rao.is_active = true
    AND ao.is_active = true
    AND u.role_id IS NOT NULL;
END;
$$;