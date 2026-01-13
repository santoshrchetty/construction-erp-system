-- PRODUCTION DEPLOYMENT: Complete Number Range System
-- Execute individual scripts in this order:
-- 1. DEPLOY_NUMBER_RANGE_SYSTEM_CLEAN.sql
-- 2. COMPLETE_CURRENT_RANGES.sql  
-- 3. FUTURE_MODULES_PART1.sql
-- 4. FUTURE_MODULES_PART2.sql
-- 5. CONSULTANT_CONFIG_INTERFACE.sql
-- 6. DYNAMIC_NUMBER_RANGE_CONFIG.sql
-- 7. TEST_NUMBER_RANGE_SYSTEM.sql

-- Step 7: Production validation
SELECT 'Production Deployment Validation' as status;

-- Check total ranges deployed
SELECT 
    company_code,
    COUNT(*) as total_ranges,
    COUNT(CASE WHEN status = 'ACTIVE' THEN 1 END) as active_ranges,
    COUNT(CASE WHEN year_dependent = true THEN 1 END) as year_dependent_ranges
FROM document_number_ranges 
GROUP BY company_code
ORDER BY company_code;

-- Check system functions
SELECT 'System Functions Status' as check_type;
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name IN (
    'get_next_number',
    'get_number_range_statistics',
    'configure_company_number_ranges',
    'configure_multiple_companies'
)
ORDER BY routine_name;

-- Check templates (if consultant interface deployed)
SELECT 'Configuration Templates' as check_type;
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'number_range_templates') 
        THEN 'Templates table exists'
        ELSE 'Templates table not deployed yet'
    END as template_status;

-- Final status
SELECT 
    'DEPLOYMENT VALIDATION COMPLETE' as deployment_status,
    CURRENT_TIMESTAMP as validation_time,
    'Run individual scripts as listed above for full deployment' as message;