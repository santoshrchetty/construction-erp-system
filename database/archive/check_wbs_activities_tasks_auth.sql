-- Check existing authorization objects for WBS, Activities, and Tasks
-- ==================================================================

-- Check all authorization objects
SELECT 'ALL AUTH OBJECTS' as status, object_name, description, module
FROM authorization_objects
ORDER BY module, object_name;

-- Check specifically for WBS, Activities, Tasks related objects
SELECT 'WBS/ACTIVITIES/TASKS OBJECTS' as status, object_name, description, module
FROM authorization_objects
WHERE object_name LIKE '%WBS%' 
   OR object_name LIKE '%ACT%' 
   OR object_name LIKE '%TSK%'
   OR description ILIKE '%wbs%'
   OR description ILIKE '%activity%'
   OR description ILIKE '%task%'
ORDER BY object_name;

-- Check tiles that might need these authorization objects
SELECT 'TILES NEEDING AUTH' as status, title, tile_category, auth_object
FROM tiles
WHERE title ILIKE '%wbs%' 
   OR title ILIKE '%activity%' 
   OR title ILIKE '%task%'
   OR title ILIKE '%activities%'
ORDER BY tile_category, title;