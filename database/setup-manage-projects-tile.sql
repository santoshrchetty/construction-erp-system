-- ============================================
-- Manage Projects Tile - Complete Setup
-- Run this script in your Supabase SQL Editor
-- ============================================

-- 1. Remove old/duplicate project tiles
DELETE FROM tiles 
WHERE construction_action = 'create-project' 
  AND title != 'Manage Projects';

-- 2. Update or create Manage Projects tile
UPDATE tiles 
SET 
  title = 'Manage Projects',
  subtitle = 'Create, view, edit, and manage construction projects',
  icon = 'folder-open',
  construction_action = 'manage-projects',
  module_code = 'PS',
  tile_category = 'Project Management'
WHERE construction_action = 'create-project' OR title = 'Create Project';

-- 3. If no tile was updated, insert new one
INSERT INTO tiles (
  title, 
  subtitle, 
  icon, 
  module_code, 
  construction_action, 
  tile_category,
  is_active
)
SELECT 
  'Manage Projects',
  'Create, view, edit, and manage construction projects',
  'folder-open',
  'PS',
  'manage-projects',
  'Project Management',
  true
WHERE NOT EXISTS (
  SELECT 1 FROM tiles 
  WHERE construction_action = 'manage-projects'
);

-- 4. Verify the tile
SELECT 
  id, 
  title, 
  subtitle, 
  icon,
  construction_action, 
  module_code,
  tile_category,
  is_active
FROM tiles 
WHERE construction_action = 'manage-projects' 
   OR title = 'Manage Projects';

-- Expected result: One row with title 'Manage Projects'
