-- Insert MR number range (corrected - without is_active)
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
    90
);

-- Verify
SELECT * FROM document_number_ranges WHERE document_type = 'MR';
