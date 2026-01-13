-- Check Database Structure
-- ========================

-- Check what tables exist
SELECT 'Available Tables' as check_type;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Check authorization function
SELECT 'Authorization Function' as check_type;
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name = 'check_construction_authorization';

-- Check if roles table exists and its structure
SELECT 'Roles Table Check' as check_type;
SELECT * FROM roles LIMIT 3;