-- Find Material Request Approvals tile
SELECT id, title, subtitle, route, tile_category
FROM tiles 
WHERE title LIKE '%Material Request Approvals%';

-- Delete the redundant tile
DELETE FROM tiles 
WHERE title LIKE '%Material Request Approvals%';

-- Verify it's deleted
SELECT COUNT(*) as remaining_count
FROM tiles 
WHERE title LIKE '%Material Request Approvals%';
