-- CHECK EXISTING APPROVAL ENGINE STRUCTURE

-- Check approval_policies table structure
SELECT 'APPROVAL_POLICIES TABLE STRUCTURE' as section;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'approval_policies' 
ORDER BY ordinal_position;

-- Check approval_routes table structure
SELECT 'APPROVAL_ROUTES TABLE STRUCTURE' as section;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'approval_routes' 
ORDER BY ordinal_position;

-- Check approval_history table structure
SELECT 'APPROVAL_HISTORY TABLE STRUCTURE' as section;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'approval_history' 
ORDER BY ordinal_position;

-- List all approval-related tables
SELECT 'ALL APPROVAL TABLES' as section;
SELECT table_name
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
  AND table_name LIKE '%approval%'
ORDER BY table_name;

SELECT 'APPROVAL STRUCTURE CHECK COMPLETE' as status;