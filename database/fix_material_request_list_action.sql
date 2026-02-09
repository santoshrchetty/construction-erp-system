-- Update Material Request List tile with construction_action
UPDATE tiles
SET construction_action = 'material-request-list'
WHERE title = 'Material Request List';

-- Verify
SELECT 
  title,
  route,
  construction_action,
  module_code
FROM tiles
WHERE title = 'Material Request List';
