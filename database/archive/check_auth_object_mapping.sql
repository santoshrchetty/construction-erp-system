-- Check the relationship between tiles.auth_object and authorization_objects

-- 1. See what auth_object values are in tiles
SELECT DISTINCT auth_object 
FROM tiles 
WHERE auth_object IS NOT NULL
ORDER BY auth_object
LIMIT 10;

-- 2. See authorization_objects table structure
SELECT * FROM authorization_objects LIMIT 3;

-- 3. Try to match tiles.auth_object with authorization_objects
SELECT 
    t.auth_object as tile_auth_object,
    ao.id as auth_object_uuid,
    ao.object_name
FROM tiles t
JOIN authorization_objects ao ON t.auth_object = ao.object_name
WHERE t.auth_object IS NOT NULL
LIMIT 10;