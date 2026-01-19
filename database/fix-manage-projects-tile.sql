-- Remove duplicate project tiles and update to Manage Projects

-- First, check for duplicates
SELECT id, title, construction_action, route 
FROM tiles 
WHERE title ILIKE '%project%' AND tile_category = 'Project Management'
ORDER BY title;

-- Delete old Create Project tile if exists
DELETE FROM tiles 
WHERE construction_action = 'create-project' 
  AND title != 'Manage Projects';

-- Update tile to use component directly (no route)
UPDATE tiles 
SET 
  title = 'Manage Projects',
  subtitle = 'Create, view, edit, and manage construction projects',
  icon = 'folder-open',
  construction_action = 'manage-projects'
WHERE construction_action = 'create-project' OR title = 'Create Project';

-- Verify final state
SELECT id, title, subtitle, construction_action, route, tile_category
FROM tiles 
WHERE construction_action IN ('create-project', 'manage-projects')
   OR title = 'Manage Projects';
