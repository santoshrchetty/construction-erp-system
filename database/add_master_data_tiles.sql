-- Add Role Assignments tile
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
  'Role Assignments',
  'Assign approval roles to employees',
  'users',
  'ADMIN',
  'role_assignments',
  '/admin/role-assignments',
  'Administration',
  'ADMIN_ROLES',
  true,
  101
);

-- Add Org Hierarchy tile
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
  'Org Hierarchy',
  'View organizational structure',
  'git-branch',
  'ADMIN',
  'org_hierarchy',
  '/admin/org-hierarchy',
  'Administration',
  'ADMIN_ORG',
  true,
  102
);

-- Verify
SELECT title, route, tile_category FROM tiles WHERE title IN ('Role Assignments', 'Org Hierarchy');
