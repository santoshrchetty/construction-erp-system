-- Find My Pending Approvals tile
SELECT id, tile_name, route, module 
FROM tiles 
WHERE tile_name LIKE '%Pending Approvals%';

-- Update the route to point to /approvals/inbox
-- UPDATE tiles 
-- SET route = '/approvals/inbox'
-- WHERE tile_name LIKE '%Pending Approvals%';
