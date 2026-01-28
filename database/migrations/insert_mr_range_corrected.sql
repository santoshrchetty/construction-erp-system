-- Insert MR number range (matching actual schema and pattern)
INSERT INTO document_number_ranges (
    company_code,
    document_type,
    number_range_object,
    fiscal_year,
    range_from,
    range_to,
    from_number,
    to_number,
    current_number,
    external_numbering,
    prefix,
    suffix,
    range_number,
    is_external,
    status,
    warning_threshold,
    description
) VALUES (
    '1000',
    'MR',
    'MR',
    2024,
    '5300000000',
    '5399999999',
    5300000000,
    5399999999,
    '5300000000',
    false,
    'MR',
    '',
    '01',
    false,
    'ACTIVE',
    90,
    'Material Request Number Range'
);

-- Verify
SELECT 
    company_code,
    document_type,
    description,
    from_number,
    to_number,
    current_number,
    prefix,
    status
FROM document_number_ranges 
WHERE document_type = 'MR';
