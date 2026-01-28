-- Check the constraint definition
SELECT conname, pg_get_constraintdef(oid) 
FROM pg_constraint 
WHERE conrelid = 'document_number_ranges'::regclass 
AND conname = 'check_range_validity';

-- Check existing records to see pattern
SELECT 
    company_code,
    document_type,
    range_from,
    range_to,
    from_number,
    to_number,
    current_number,
    status
FROM document_number_ranges
LIMIT 3;
