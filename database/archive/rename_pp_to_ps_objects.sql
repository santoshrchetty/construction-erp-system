-- Rename PP_ objects to PS_ objects for Project System consistency
-- ================================================================

-- Update authorization objects from PP_ to PS_
UPDATE authorization_objects 
SET object_name = 'PS_TSK_ASSIGN', 
    description = 'Project Task Assignment Authorization',
    module = 'project_system'
WHERE object_name = 'PP_TSK_ASSIGN';

UPDATE authorization_objects 
SET object_name = 'PS_TSK_UPDATE', 
    description = 'Project Task Update Authorization',
    module = 'project_system'
WHERE object_name = 'PP_TSK_UPDATE';

UPDATE authorization_objects 
SET object_name = 'PS_ACT_SCHEDULE', 
    description = 'Project Activity Scheduling Authorization',
    module = 'project_system'
WHERE object_name = 'PP_ACT_SCHEDULE';

UPDATE authorization_objects 
SET object_name = 'PS_ACT_EXECUTE', 
    description = 'Project Activity Execution Authorization',
    module = 'project_system'
WHERE object_name = 'PP_ACT_EXECUTE';

-- Update role authorization mappings
UPDATE role_authorization_mapping 
SET auth_object_name = 'PS_TSK_ASSIGN'
WHERE auth_object_name = 'PP_TSK_ASSIGN';

UPDATE role_authorization_mapping 
SET auth_object_name = 'PS_TSK_UPDATE'
WHERE auth_object_name = 'PP_TSK_UPDATE';

UPDATE role_authorization_mapping 
SET auth_object_name = 'PS_ACT_SCHEDULE'
WHERE auth_object_name = 'PP_ACT_SCHEDULE';

UPDATE role_authorization_mapping 
SET auth_object_name = 'PS_ACT_EXECUTE'
WHERE auth_object_name = 'PP_ACT_EXECUTE';

-- Update tiles to use PS_ objects
UPDATE tiles 
SET auth_object = 'PS_ACT_SCHEDULE'
WHERE auth_object = 'PP_ACT_SCHEDULE';

UPDATE tiles 
SET auth_object = 'PS_ACT_EXECUTE'
WHERE auth_object = 'PP_ACT_EXECUTE';

UPDATE tiles 
SET auth_object = 'PS_TSK_ASSIGN'
WHERE auth_object = 'PP_TSK_ASSIGN';

UPDATE tiles 
SET auth_object = 'PS_TSK_UPDATE'
WHERE auth_object = 'PP_TSK_UPDATE';

-- Verify the changes
SELECT 'UPDATED PS OBJECTS' as status, object_name, description, module
FROM authorization_objects
WHERE object_name LIKE 'PS_%'
AND object_name IN ('PS_TSK_ASSIGN', 'PS_TSK_UPDATE', 'PS_ACT_SCHEDULE', 'PS_ACT_EXECUTE')
ORDER BY object_name;

-- Verify tiles are using PS_ objects
SELECT 'TILES WITH PS OBJECTS' as status, title, tile_category, auth_object
FROM tiles
WHERE auth_object IN ('PS_TSK_ASSIGN', 'PS_TSK_UPDATE', 'PS_ACT_SCHEDULE', 'PS_ACT_EXECUTE')
ORDER BY tile_category, title;