-- CHECK COMPANIES TABLE STRUCTURE
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'companies' 
ORDER BY ordinal_position;