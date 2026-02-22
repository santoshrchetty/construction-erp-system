-- Add Workflow Configuration tile under Administration
INSERT INTO tiles (
  title,
  subtitle,
  icon,
  module_code,
  construction_action,
  route,
  tile_category,
  auth_object,
  is_active,
  sequence_order
) VALUES (
  'Workflow Configuration',
  'Configure workflow definitions and approval steps',
  'settings',
  'ADMIN',
  'workflow_config',
  '/admin/workflows',
  'Administration',
  'ADMIN_WORKFLOW',
  true,
  100
);

-- Verify the tile was created
SELECT * FROM tiles WHERE title = 'Workflow Configuration';
