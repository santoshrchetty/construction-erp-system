-- Check current tile status
SELECT title, construction_action, auth_object 
FROM tiles 
WHERE construction_action = 'sap-config';