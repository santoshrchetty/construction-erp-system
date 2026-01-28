-- ========================================
-- ALIGNMENT VERIFICATION SCRIPT
-- ========================================

-- Check 1: Core functions exist
SELECT 
    'get_next_number' as function_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.routines 
        WHERE routine_name = 'get_next_number'
    ) THEN '✅ EXISTS' ELSE '❌ MISSING' END as status
UNION ALL
SELECT 
    'get_next_number_by_group' as function_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.routines 
        WHERE routine_name = 'get_next_number_by_group'
    ) THEN '✅ EXISTS' ELSE '❌ MISSING' END as status
UNION ALL
SELECT 
    'get_fiscal_year' as function_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.routines 
        WHERE routine_name = 'get_fiscal_year'
    ) THEN '✅ EXISTS' ELSE '❌ MISSING' END as status;

-- Check 2: Core tables exist
SELECT 
    'document_type_config' as table_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'document_type_config'
    ) THEN '✅ EXISTS' ELSE '❌ MISSING' END as status
UNION ALL
SELECT 
    'document_number_ranges' as table_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'document_number_ranges'
    ) THEN '✅ EXISTS' ELSE '❌ MISSING' END as status
UNION ALL
SELECT 
    'sap_document_type_mapping' as table_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables 
        WHERE table_name = 'sap_document_type_mapping'
    ) THEN '✅ EXISTS' ELSE '❌ MISSING' END as status;

-- Check 3: Document types configured
SELECT 
    'Document Types Configured:' as info,
    COUNT(DISTINCT base_document_type) as count,
    STRING_AGG(DISTINCT base_document_type, ', ') as types
FROM document_type_config 
WHERE company_code = 'C001';

-- Check 4: Number ranges configured
SELECT 
    'Number Ranges Configured:' as info,
    COUNT(*) as count,
    STRING_AGG(DISTINCT document_type, ', ') as types
FROM document_number_ranges 
WHERE company_code = 'C001';

-- Check 5: Standards compliance
SELECT 
    document_type,
    number_range_group,
    prefix,
    CASE 
        WHEN prefix ~ '^[A-Z]{2}-\d{2}-\d{2}-$' THEN '✅ COMPLIANT'
        ELSE '❌ NON-COMPLIANT: ' || prefix
    END as format_check,
    CASE 
        WHEN to_number = 999999 THEN '6-digit (1M)'
        WHEN to_number = 99999999 THEN '8-digit (100M)'
        ELSE 'Custom: ' || to_number::TEXT
    END as capacity
FROM document_number_ranges 
WHERE company_code = 'C001'
ORDER BY document_type, number_range_group;