-- Update SAP Configuration tile name to Organisation Configuration
UPDATE tiles 
SET title = 'Organisation Configuration',
    subtitle = 'Configure organizational structure and settings',
    auth_object = 'CG_ORG_CONFIG'
WHERE construction_action = 'sap-config';

-- Verify the update
SELECT 'Tile name updated successfully:' as info;
SELECT title, subtitle, construction_action, tile_category, auth_object
FROM tiles 
WHERE construction_action = 'sap-config';