-- Check if PO range exists
SELECT document_type, range_from, range_to, status 
FROM document_number_ranges 
WHERE document_type = 'PO';

-- Insert PO number range if not exists
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
) 
SELECT 
    '1000',
    'PO',
    'PO',
    2024,
    '5400000000',
    '5499999999',
    5400000000,
    5499999999,
    '5400000000',
    false,
    'PO',
    '',
    '01',
    false,
    'ACTIVE',
    90,
    'Purchase Order Number Range'
WHERE NOT EXISTS (
    SELECT 1 FROM document_number_ranges WHERE document_type = 'PO'
);
