-- Complete GL Posting Enhancement Deployment
-- Run each script separately in this order:

-- 1. Run COMPLETE_GL_POSTING_MASTER_DATA.sql
-- 2. Run ENHANCED_GL_POSTING_CONTROLS.sql  
-- 3. Run POPULATE_GL_POSTING_MASTER_DATA.sql
-- 4. Run this verification script

-- Step 4: Verify Installation
SELECT 'Checking master data tables...' as status;

SELECT 
    'cost_centers' as table_name,
    COUNT(*) as record_count
FROM cost_centers
WHERE is_active = true

UNION ALL

SELECT 
    'profit_centers' as table_name,
    COUNT(*) as record_count
FROM profit_centers
WHERE is_active = true

UNION ALL

SELECT 
    'wbs_elements' as table_name,
    COUNT(*) as record_count
FROM wbs_elements
WHERE is_active = true

UNION ALL

SELECT 
    'fiscal_year_variants' as table_name,
    COUNT(*) as record_count
FROM fiscal_year_variants
WHERE is_open = true

UNION ALL

SELECT 
    'document_number_ranges' as table_name,
    COUNT(*) as record_count
FROM document_number_ranges

UNION ALL

SELECT 
    'document_types' as table_name,
    COUNT(*) as record_count
FROM document_types

UNION ALL

SELECT 
    'gl_account_authorization' as table_name,
    COUNT(*) as record_count
FROM gl_account_authorization;

-- Test validation function
SELECT 'Testing validation function...' as status;

SELECT * FROM validate_gl_posting(
    'C001',
    '2024-01-15',
    '[
        {"account_code": "110000", "debit_amount": 1000, "credit_amount": 0, "description": "Test debit"},
        {"account_code": "400100", "debit_amount": 0, "credit_amount": 1000, "description": "Test credit"}
    ]'::jsonb
);

-- Test document number generation
SELECT 'Testing document number generation...' as status;

SELECT get_next_document_number('C001', 'SA') as next_document_number;

SELECT 'GL Posting enhancement deployment completed successfully!' as final_status;