-- QUICK APPROVAL ENGINE TEST
-- Test the generate_approval_flow function with sample data

-- Test 1: Material Request (Low Value)
SELECT 'TEST 1: Material Request $500' as test_name;
SELECT * FROM generate_approval_flow('MR', 'NB', 500.00, 'USD', 'DEPT001', 'PROJ001', 'user123');

-- Test 2: Purchase Order (High Value) 
SELECT 'TEST 2: Purchase Order $50000' as test_name;
SELECT * FROM generate_approval_flow('PO', 'NB', 50000.00, 'USD', 'DEPT001', 'PROJ001', 'user123');

-- Test 3: Claims (Emergency)
SELECT 'TEST 3: Emergency Claim $25000' as test_name;
SELECT * FROM generate_approval_flow('CLAIM', 'EM', 25000.00, 'USD', 'DEPT001', 'PROJ001', 'user123');

SELECT 'Approval engine tests complete' as result;