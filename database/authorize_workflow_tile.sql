-- Get the tile ID
SELECT id FROM tiles WHERE title = 'Workflow Configuration';

-- Grant authorization to your user (replace with your user_id)
-- First, get your user_id
SELECT id, email FROM users WHERE email = 'john.engineer@example.com';

-- Then insert authorization (replace USER_ID and TILE_ID with actual values)
INSERT INTO tile_authorizations (user_id, tile_id, is_authorized)
VALUES (
  (SELECT id FROM users WHERE email = 'john.engineer@example.com'),
  (SELECT id FROM tiles WHERE title = 'Workflow Configuration'),
  true
);

-- Verify
SELECT 
  ta.*,
  u.email,
  t.title
FROM tile_authorizations ta
JOIN users u ON ta.user_id = u.id
JOIN tiles t ON ta.tile_id = t.id
WHERE t.title = 'Workflow Configuration';
