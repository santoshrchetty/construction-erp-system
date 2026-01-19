-- Rename "Create Project" tile to "Manage Projects" with CRUD functionality

UPDATE tiles 
SET 
  title = 'Manage Projects',
  subtitle = 'Create, view, edit, and manage construction projects',
  icon = 'folder-open',
  route = '/projects/manage'
WHERE title = 'Create Project' 
   OR construction_action = 'create-project';

-- Verify the update
SELECT 
  id, 
  title, 
  subtitle, 
  icon,
  construction_action, 
  route,
  tile_category
FROM tiles 
WHERE construction_action = 'create-project' OR title = 'Manage Projects';
