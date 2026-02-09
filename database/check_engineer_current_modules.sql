-- First check the table structure to find correct column names
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'role_authorization_objects'
ORDER BY ordinal_position;

-- Check what's in the role_authorization_objects table for Engineer
SELECT * FROM role_authorization_objects 
WHERE role_id = '7b409746-76a8-4387-9edd-43aa4f2d5977'::uuid;