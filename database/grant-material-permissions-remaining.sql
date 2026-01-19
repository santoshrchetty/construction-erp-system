-- Grant MATERIAL_MASTER_READ to remaining roles

UPDATE roles
SET permissions = jsonb_set(
  permissions,
  '{MATERIAL_MASTER_READ}',
  '["read"]'::jsonb,
  true
)
WHERE name IN ('Engineer', 'Employee', 'PlanEng', 'ProcMgr', 'ProjMgr', 'SiteEng', 'StoreKeep');

-- Verify all roles now have the permission
SELECT 
  name,
  permissions->'MATERIAL_MASTER_READ' as material_permission
FROM roles
WHERE is_active = true
ORDER BY name;
