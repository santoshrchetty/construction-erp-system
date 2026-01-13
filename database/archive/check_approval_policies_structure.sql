-- CHECK APPROVAL_POLICIES TABLE STRUCTURE
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'approval_policies' 
ORDER BY ordinal_position;

-- Also check if table exists
SELECT 'APPROVAL_POLICIES TABLE EXISTS:' as info;
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'approval_policies')
        THEN '✅ approval_policies table EXISTS'
        ELSE '❌ approval_policies table MISSING'
    END as table_status;