-- Test Runner - Execute All Tests
-- ================================

-- Clean up any existing test users first
DELETE FROM user_authorizations 
WHERE user_id IN (
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    '33333333-3333-3333-3333-333333333333',
    '44444444-4444-4444-4444-444444444444',
    '55555555-5555-5555-5555-555555555555'
);

-- Run the comprehensive test suite
\i comprehensive_test_suite.sql

-- Final summary
SELECT 
    '🎯 RBAC SYSTEM TEST SUMMARY' as summary,
    'All tests completed' as status,
    NOW() as test_time;