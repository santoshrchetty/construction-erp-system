-- Verification Script: Check Number Range SAP Alignment
-- Run this to verify the migration was successful

-- 1. Check all columns exist
SELECT 
    column_name, 
    data_type, 
    character_maximum_length,
    column_default,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'document_number_ranges'
ORDER BY ordinal_position;

-- 2. Check new columns specifically
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'document_number_ranges' AND column_name = 'description') THEN '✓'
        ELSE '✗'
    END as description,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'document_number_ranges' AND column_name = 'fiscal_year') THEN '✓'
        ELSE '✗'
    END as fiscal_year,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'document_number_ranges' AND column_name = 'range_number') THEN '✓'
        ELSE '✗'
    END as range_number,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'document_number_ranges' AND column_name = 'is_external') THEN '✓'
        ELSE '✗'
    END as is_external;

-- 3. Check indexes
SELECT 
    indexname, 
    indexdef
FROM pg_indexes 
WHERE tablename = 'document_number_ranges'
ORDER BY indexname;

-- 4. Check table comment
SELECT 
    obj_description('document_number_ranges'::regclass) as table_comment;

-- 5. Check sample data with new fields
SELECT 
    id,
    company_code,
    document_type,
    description,
    fiscal_year,
    range_number,
    is_external,
    from_number,
    to_number,
    current_number
FROM document_number_ranges
LIMIT 5;

-- 6. Count total records
SELECT 
    COUNT(*) as total_records,
    COUNT(description) as records_with_description,
    COUNT(fiscal_year) as records_with_fiscal_year,
    COUNT(range_number) as records_with_range_number,
    COUNT(CASE WHEN is_external = true THEN 1 END) as external_ranges
FROM document_number_ranges;
