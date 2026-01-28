-- Check if Material Request (MR) number range is configured

-- 1. Check for MR number range
SELECT 
    company_code,
    document_type,
    description,
    from_number,
    to_number,
    current_number,
    prefix,
    suffix,
    is_active
FROM document_number_ranges
WHERE document_type IN ('MR', 'MATERIAL_REQUEST', 'MAT_REQ')
ORDER BY company_code;

-- 2. Check all configured document types
SELECT DISTINCT 
    document_type,
    COUNT(*) as range_count
FROM document_number_ranges
GROUP BY document_type
ORDER BY document_type;

-- 3. If MR doesn't exist, create sample configuration
-- Uncomment to create:
/*
INSERT INTO document_number_ranges (
    company_code,
    document_type,
    description,
    from_number,
    to_number,
    current_number,
    prefix,
    suffix,
    padding_length,
    range_number,
    fiscal_year,
    is_external,
    is_active,
    warning_threshold
) VALUES (
    '1000',
    'MR',
    'Material Request Number Range',
    '1',
    '999999',
    '0',
    'MR',
    '',
    6,
    '01',
    '2024',
    false,
    true,
    90
);
*/
