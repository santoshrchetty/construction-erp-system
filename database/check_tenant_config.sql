-- Check for custom configuration parameters
SELECT name, setting, source, context 
FROM pg_settings 
WHERE name LIKE '%tenant%' OR name LIKE '%app%';

-- Check for database-level configuration
SELECT setconfig 
FROM pg_db_role_setting 
WHERE setdatabase = (SELECT oid FROM pg_database WHERE datname = current_database());

-- Check for hooks that might set parameters
SELECT * FROM pg_event_trigger;

-- Check for functions that use SET commands
SELECT 
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_functiondef(p.oid) as function_definition
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE pg_get_functiondef(p.oid) LIKE '%app.current_tenant_id%'
   OR pg_get_functiondef(p.oid) LIKE '%set_config%';

-- Check for RLS policies that might reference this parameter
SELECT 
  schemaname,
  tablename,
  policyname,
  pg_get_expr(qual, (schemaname||'.'||tablename)::regclass) as policy_definition
FROM pg_policies
WHERE pg_get_expr(qual, (schemaname||'.'||tablename)::regclass) LIKE '%app.current_tenant_id%';
