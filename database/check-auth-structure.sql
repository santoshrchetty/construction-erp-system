-- CHECK AUTHORIZATION OBJECTS TABLE STRUCTURE
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'authorization_objects' 
ORDER BY ordinal_position;