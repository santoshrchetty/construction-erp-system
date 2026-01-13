-- Enterprise audit logging and monitoring
-- =====================================

-- Create audit log table for compliance
CREATE TABLE IF NOT EXISTS authorization_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  auth_object_name TEXT NOT NULL,
  access_granted BOOLEAN NOT NULL,
  ip_address INET,
  user_agent TEXT,
  session_id TEXT,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create index for audit queries
CREATE INDEX IF NOT EXISTS idx_audit_log_user_timestamp ON authorization_audit_log(user_id, timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_audit_log_auth_object ON authorization_audit_log(auth_object_name, timestamp DESC);

-- Enhanced authorization function with audit logging
CREATE OR REPLACE FUNCTION check_construction_authorization_with_audit(
  p_user_id UUID,
  p_auth_object_name TEXT,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL,
  p_session_id TEXT DEFAULT NULL
) RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_role_name TEXT;
  has_access BOOLEAN := FALSE;
BEGIN
  -- Get user role
  SELECT r.name INTO user_role_name
  FROM users u
  JOIN roles r ON u.role_id = r.id
  WHERE u.id = p_user_id 
  AND u.is_active = true 
  AND r.is_active = true
  LIMIT 1;
  
  -- Check authorization if user found
  IF user_role_name IS NOT NULL THEN
    SELECT EXISTS (
      SELECT 1 
      FROM role_authorization_mapping ram
      WHERE ram.role_name = user_role_name
      AND ram.auth_object_name = p_auth_object_name
      LIMIT 1
    ) INTO has_access;
  END IF;
  
  -- Log the access attempt for audit compliance
  INSERT INTO authorization_audit_log (
    user_id, 
    auth_object_name, 
    access_granted,
    ip_address,
    user_agent,
    session_id
  ) VALUES (
    p_user_id, 
    p_auth_object_name, 
    has_access,
    p_ip_address,
    p_user_agent,
    p_session_id
  );
  
  RETURN has_access;
END;
$$;

-- Create monitoring view for security dashboard
CREATE OR REPLACE VIEW authorization_monitoring AS
SELECT 
  DATE_TRUNC('hour', timestamp) as hour,
  auth_object_name,
  COUNT(*) as total_attempts,
  COUNT(*) FILTER (WHERE access_granted = true) as successful_access,
  COUNT(*) FILTER (WHERE access_granted = false) as denied_access,
  COUNT(DISTINCT user_id) as unique_users
FROM authorization_audit_log
WHERE timestamp >= NOW() - INTERVAL '24 hours'
GROUP BY DATE_TRUNC('hour', timestamp), auth_object_name
ORDER BY hour DESC, auth_object_name;