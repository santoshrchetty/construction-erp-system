-- Fix authorization objects tenant_id
UPDATE authorization_objects
SET tenant_id = (SELECT id FROM tenants LIMIT 1)
WHERE module = 'DG' AND tenant_id IS NULL;

-- Verify fix
SELECT 
  COUNT(*) as dg_auth_objects,
  COUNT(DISTINCT tenant_id) as tenant_count
FROM authorization_objects
WHERE module = 'DG';
