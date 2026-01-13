-- Delete one WBS tile and create a new modify tile
-- =================================================

-- Delete the problematic tile
DELETE FROM tiles 
WHERE id = 'c0b56116-8bde-4d9c-8c24-6ee324ade567';

-- Create new WBS Modify tile
INSERT INTO tiles (
  title, 
  subtitle, 
  icon, 
  color, 
  route, 
  module_code, 
  tile_category, 
  construction_action, 
  auth_object, 
  sequence_order, 
  is_active
) VALUES (
  'WBS Editor', 
  'Edit work breakdown structure', 
  'edit', 
  'blue', 
  '/wbs-editor', 
  'PS', 
  'Project Management', 
  'MODIFY', 
  'PS_WBS_MODIFY', 
  12, 
  true
);

-- Verify the tiles
SELECT id, title, tile_category, auth_object, subtitle
FROM tiles 
WHERE tile_category = 'Project Management' 
AND title LIKE '%WBS%'
ORDER BY title;