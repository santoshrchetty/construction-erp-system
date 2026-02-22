-- Diagnostic: Check session parameters and data
SELECT 
  current_setting('app.current_user_email', true) as current_user_email,
  current_setting('app.current_tenant_id', true) as current_tenant_id;

-- Check if user exists
SELECT id, email, tenant_id, role_id 
FROM users 
WHERE email = current_setting('app.current_user_email', true)
LIMIT 5;

-- Check DG tiles for any tenant
SELECT tenant_id, COUNT(*) as tile_count
FROM tiles 
WHERE module_code = 'DG' AND is_active = true
GROUP BY tenant_id;

-- If parameters are null, use hardcoded values for testing
SELECT 
  t.id, t.title, t.route, t.tenant_id
FROM tiles t
WHERE t.module_code = 'DG' AND t.is_active = true
LIMIT 5;