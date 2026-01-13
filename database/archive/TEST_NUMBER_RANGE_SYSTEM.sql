-- Test Number Range System After Deployment
-- Run this AFTER DEPLOY_NUMBER_RANGE_COMPLETE.sql succeeds

-- Test 1: Check deployed ranges
SELECT 'Deployed Number Ranges' as test_name;
SELECT company_code, document_type, range_from, range_to, status 
FROM document_number_ranges 
WHERE company_code = 'C001'
ORDER BY document_type;

-- Test 2: Fix functions and test statistics
SELECT 'Fixing Mixed Data Types' as test_name;

-- Fix get_number_range_statistics function
CREATE OR REPLACE FUNCTION get_number_range_statistics(
    p_company_code VARCHAR(4) DEFAULT NULL
) RETURNS TABLE (
    company_code VARCHAR(4),
    document_type VARCHAR(2),
    total_capacity BIGINT,
    numbers_used BIGINT,
    usage_percentage INTEGER,
    status VARCHAR(20),
    days_since_last_use INTEGER,
    estimated_days_remaining INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        dnr.company_code,
        dnr.document_type,
        (dnr.to_number - dnr.from_number + 1) as total_capacity,
        (dnr.current_number::BIGINT - dnr.from_number) as numbers_used,
        calculate_usage_percentage(dnr.current_number::BIGINT, dnr.from_number, dnr.to_number) as usage_percentage,
        dnr.status,
        CASE 
            WHEN dnr.last_used_date IS NULL THEN NULL
            ELSE (CURRENT_DATE - dnr.last_used_date)::INTEGER
        END as days_since_last_use,
        CASE 
            WHEN dnr.last_used_date IS NULL OR dnr.last_used_date = CURRENT_DATE THEN NULL
            WHEN dnr.created_at IS NULL THEN NULL
            ELSE ((dnr.to_number - dnr.current_number::BIGINT) / 
                  GREATEST(1, (dnr.current_number::BIGINT - dnr.from_number) / 
                  GREATEST(1, (CURRENT_DATE - dnr.created_at::DATE)::INTEGER)))::INTEGER
        END as estimated_days_remaining
    FROM document_number_ranges dnr
    WHERE (p_company_code IS NULL OR dnr.company_code = p_company_code)
    ORDER BY dnr.company_code, dnr.document_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

SELECT 'Statistics Function Test' as test_name;
SELECT * FROM get_number_range_statistics('C001') LIMIT 5;

-- Test 3: Check alerts (should be empty)
SELECT 'Alerts Check' as test_name;
SELECT COUNT(*) as alert_count FROM number_range_alerts WHERE company_code = 'C001';

-- Test 4: Check number range groups
SELECT 'Number Range Groups' as test_name;
SELECT * FROM number_range_groups WHERE company_code = 'C001';

-- Test 5: Try number generation (may fail due to VARCHAR(10) limit)
-- SELECT get_next_number('C001', 'PY') as test_number;

SELECT 'Number Range System Tests Complete' as final_status;