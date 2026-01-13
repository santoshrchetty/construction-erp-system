-- Step 1 Verification Script - Run in Supabase SQL Editor
-- =======================================================
-- Run this AFTER executing the two main scripts manually

-- Verify tables were created
SELECT 
    'authorization_objects' as table_name,
    COUNT(*) as record_count
FROM authorization_objects
UNION ALL
SELECT 
    'authorization_fields' as table_name,
    COUNT(*) as record_count  
FROM authorization_fields
UNION ALL
SELECT 
    'user_authorizations' as table_name,
    COUNT(*) as record_count
FROM user_authorizations;

-- Test the authorization function
SELECT check_sap_authorization(
    '00000000-0000-0000-0000-000000000000'::UUID,
    'F_PROJ_DIS',
    '03',
    '{"PROJ_TYPE": "commercial"}'::jsonb
) as test_result;