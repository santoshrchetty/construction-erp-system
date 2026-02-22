-- Find tables with 'tile' in the name
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name LIKE '%tile%';

-- Also check for module or menu tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND (table_name LIKE '%module%' OR table_name LIKE '%menu%');
