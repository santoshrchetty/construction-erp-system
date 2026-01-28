-- Copy existing range and create new MM ranges (SAP-style)

-- 1. Copy from MR to create MATERIAL range
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code,
    'MATERIAL' as document_type,
    'MATERIAL' as number_range_object,
    fiscal_year,
    '5600000000' as range_from,
    '5699999999' as range_to,
    5600000000 as from_number,
    5699999999 as to_number,
    '5600000000' as current_number,
    external_numbering,
    'MAT' as prefix,
    suffix,
    range_number,
    is_external,
    status,
    warning_threshold,
    critical_threshold,
    interval_size,
    buffer_size,
    fiscal_year_variant,
    year_dependent,
    'Material Master Number Range' as description
FROM document_number_ranges 
WHERE document_type = 'MR' 
LIMIT 1;

-- 2. Copy from MR to create GR range
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code,
    'GR' as document_type,
    'GR' as number_range_object,
    fiscal_year,
    '5700000000' as range_from,
    '5799999999' as range_to,
    5700000000 as from_number,
    5799999999 as to_number,
    '5700000000' as current_number,
    external_numbering,
    'GR' as prefix,
    suffix,
    range_number,
    is_external,
    status,
    warning_threshold,
    critical_threshold,
    interval_size,
    buffer_size,
    fiscal_year_variant,
    year_dependent,
    'Goods Receipt Number Range' as description
FROM document_number_ranges 
WHERE document_type = 'MR' 
LIMIT 1;

-- 3. Copy from MR to create INVOICE range
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code,
    'INVOICE' as document_type,
    'INVOICE' as number_range_object,
    fiscal_year,
    '5800000000' as range_from,
    '5899999999' as range_to,
    5800000000 as from_number,
    5899999999 as to_number,
    '5800000000' as current_number,
    external_numbering,
    'INV' as prefix,
    suffix,
    range_number,
    is_external,
    status,
    warning_threshold,
    critical_threshold,
    interval_size,
    buffer_size,
    fiscal_year_variant,
    year_dependent,
    'Invoice Number Range' as description
FROM document_number_ranges 
WHERE document_type = 'MR' 
LIMIT 1;

-- Verify all MM ranges
SELECT 
    document_type,
    description,
    range_from,
    range_to,
    prefix,
    status
FROM document_number_ranges
WHERE document_type IN ('MATERIAL', 'MR', 'PR', 'PO', 'GR', 'INVOICE')
ORDER BY document_type;
