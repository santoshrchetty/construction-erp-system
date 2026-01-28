-- Check if MATERIAL range exists
SELECT 
    document_type,
    description,
    range_from,
    range_to,
    prefix,
    year_dependent,
    status
FROM document_number_ranges
WHERE document_type = 'MATERIAL';

-- If not exists, create it
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'MATERIAL', 'MATERIAL', fiscal_year,
    '5600000000', '5699999999', 5600000000, 5699999999, '5600000000',
    external_numbering, 'MAT', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, false,
    'Material Master Number Range (MARA/MATNR)'
FROM document_number_ranges 
WHERE document_type = 'MR' 
AND NOT EXISTS (SELECT 1 FROM document_number_ranges WHERE document_type = 'MATERIAL')
LIMIT 1;

-- Verify
SELECT 
    document_type,
    description,
    range_from,
    range_to,
    prefix,
    year_dependent,
    status
FROM document_number_ranges
WHERE document_type = 'MATERIAL';
