-- Check MR prefix configuration
SELECT 
    company_code,
    document_type,
    number_range_group,
    prefix,
    current_number,
    to_number,
    fiscal_year
FROM document_number_ranges 
WHERE document_type = 'MR';

-- Check if there are multiple MR ranges
SELECT COUNT(*) as mr_range_count FROM document_number_ranges WHERE document_type = 'MR';