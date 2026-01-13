-- Update Organisation Configuration tile route
UPDATE tiles 
SET route = '/org-config'
WHERE construction_action = 'organisation-config';

-- Verify the update
SELECT title, construction_action, route, auth_object
FROM tiles 
WHERE construction_action = 'organisation-config';