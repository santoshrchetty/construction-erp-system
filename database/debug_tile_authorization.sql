-- Check if the RPC function returns the new tiles
SELECT * FROM get_user_authorized_tiles(
  (SELECT id FROM users WHERE email = 'john.engineer@example.com')
);

-- Check if tiles exist and have correct auth_object
SELECT id, title, auth_object, tile_category 
FROM tiles 
WHERE title IN ('Role Assignments', 'Org Hierarchy');

-- Check the link between tiles and authorization objects
SELECT 
  t.title,
  t.auth_object,
  ao.object_name,
  ao.id as auth_object_id
FROM tiles t
LEFT JOIN authorization_objects ao ON t.auth_object = ao.object_name
WHERE t.title IN ('Role Assignments', 'Org Hierarchy');
