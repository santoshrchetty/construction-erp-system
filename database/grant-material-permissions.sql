-- Grant MATERIAL_MASTER_READ permission to roles via JSONB permissions column
-- Admin already has "all": true, so only update other roles

-- Update Manager role
UPDATE roles
SET permissions = jsonb_set(
  permissions,
  '{MATERIAL_MASTER_READ}',
  '["read"]'::jsonb,
  true
)
WHERE name = 'Manager';

-- Update Procurement role
UPDATE roles
SET permissions = jsonb_set(
  permissions,
  '{MATERIAL_MASTER_READ}',
  '["read"]'::jsonb,
  true
)
WHERE name = 'Procurement';

-- Update Storekeeper role
UPDATE roles
SET permissions = jsonb_set(
  permissions,
  '{MATERIAL_MASTER_READ}',
  '["read"]'::jsonb,
  true
)
WHERE name = 'Storekeeper';

-- Update Finance role
UPDATE roles
SET permissions = jsonb_set(
  permissions,
  '{MATERIAL_MASTER_READ}',
  '["read"]'::jsonb,
  true
)
WHERE name = 'Finance';

-- Verify permissions granted
SELECT 
  name,
  permissions
FROM roles
WHERE is_active = true
ORDER BY name;
