-- Fix Schema for Construction Object Names
-- =======================================

-- Increase object_name field length to accommodate construction naming
ALTER TABLE authorization_objects ALTER COLUMN object_name TYPE VARCHAR(20);

-- Also update the auth_object field in role_authorization_mapping if it exists
ALTER TABLE role_authorization_mapping ALTER COLUMN auth_object_name TYPE VARCHAR(20);

-- Verify the changes
SELECT 
    column_name, 
    data_type, 
    character_maximum_length 
FROM information_schema.columns 
WHERE table_name = 'authorization_objects' 
  AND column_name = 'object_name';