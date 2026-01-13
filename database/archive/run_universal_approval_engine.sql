-- UNIVERSAL ENTERPRISE APPROVAL ENGINE - MASTER INSTALLER
-- Run this script to install the complete approval engine

-- STEP 1: Create Schema
-- Run: database/universal_approval_engine_schema.sql

-- STEP 2: Install Runtime
-- Run: database/universal_approval_engine_runtime.sql

-- STEP 3: Load Master Data
-- Run: database/universal_approval_engine_master_data.sql

-- STEP 4: Run Tests
-- Run: database/universal_approval_engine_tests.sql

-- QUICK VERIFICATION
SELECT 'UNIVERSAL ENTERPRISE APPROVAL ENGINE INSTALLATION GUIDE' as title;
SELECT 'Run each script individually in your database client' as instruction;
SELECT 'Scripts are located in the database/ folder' as location;

-- Test if engine is ready
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'approval_object_registry') 
        THEN 'ENGINE SCHEMA READY ✅'
        ELSE 'RUN: universal_approval_engine_schema.sql'
    END as schema_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'generate_approval_flow') 
        THEN 'ENGINE RUNTIME READY ✅'
        ELSE 'RUN: universal_approval_engine_runtime.sql'
    END as runtime_status;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM organizational_hierarchy WHERE is_active = true) 
        THEN 'MASTER DATA LOADED ✅'
        ELSE 'RUN: universal_approval_engine_master_data.sql'
    END as master_data_status;

SELECT 'After running all scripts, execute: universal_approval_engine_tests.sql' as final_step;