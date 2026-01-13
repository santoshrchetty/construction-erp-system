-- Check if Organisation Configuration tile is accessible to admin user
SELECT 'Checking Organisation Configuration tile access:' as info;

-- Check the Organisation Configuration tile
SELECT 
    title,
    construction_action,
    auth_object,
    tile_category
FROM tiles 
WHERE construction_action = 'sap-config';

-- Simple check: Admin users typically have access to Configuration category tiles
SELECT 'Admin should have access to Configuration tiles' as access_note;