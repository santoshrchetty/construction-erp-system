-- QUICK CHECK: Verify Universal Approval Engine Installation Status

SELECT 'CHECKING INSTALLATION STATUS...' as status;

-- Check if core tables exist
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'approval_object_registry') 
        THEN '✅ approval_object_registry EXISTS'
        ELSE '❌ RUN: universal_approval_engine_schema.sql'
    END as schema_check_1;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'approval_policies') 
        THEN '✅ approval_policies EXISTS'
        ELSE '❌ RUN: universal_approval_engine_schema.sql'
    END as schema_check_2;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'organizational_hierarchy') 
        THEN '✅ organizational_hierarchy EXISTS'
        ELSE '❌ RUN: universal_approval_engine_schema.sql'
    END as schema_check_3;

-- Check if runtime function exists
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'generate_approval_flow') 
        THEN '✅ generate_approval_flow FUNCTION EXISTS'
        ELSE '❌ RUN: universal_approval_engine_runtime.sql'
    END as runtime_check;

-- Check if master data is loaded
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM approval_object_registry WHERE approval_object_type = 'PO') 
        THEN '✅ MASTER DATA LOADED'
        ELSE '❌ RUN: universal_approval_engine_master_data.sql'
    END as master_data_check;

SELECT 'INSTALLATION GUIDE:' as guide;
SELECT '1. Run universal_approval_engine_schema.sql FIRST' as step1;
SELECT '2. Run fix_approval_delegations.sql' as step2;
SELECT '3. Run universal_approval_engine_runtime.sql' as step3;
SELECT '4. Run universal_approval_engine_master_data.sql' as step4;
SELECT '5. Run universal_approval_engine_tests.sql' as step5;