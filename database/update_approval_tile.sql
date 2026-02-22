-- Update the Approval Configuration tile to route to workflow admin
UPDATE tiles
SET 
  route = '/admin/workflows',
  subtitle = 'Configure workflow definitions and approval steps'
WHERE title = 'Approval Configuration';

-- Verify
SELECT id, title, subtitle, route, tile_category 
FROM tiles 
WHERE title = 'Approval Configuration';

-- Delete the duplicate workflow tile we created
DELETE FROM tiles WHERE title = 'Workflow Configuration';
