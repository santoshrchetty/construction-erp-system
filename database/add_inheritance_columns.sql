-- Add missing columns to role_authorization_objects table
-- Run this script to enable inheritance functionality

ALTER TABLE role_authorization_objects 
ADD COLUMN IF NOT EXISTS module_full_access BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS object_full_access BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS inherited_from TEXT CHECK (inherited_from IN ('module', 'object'));

-- Verify columns were added
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'role_authorization_objects' 
AND column_name IN ('module_full_access', 'object_full_access', 'inherited_from')
ORDER BY column_name;