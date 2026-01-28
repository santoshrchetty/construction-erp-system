-- Material Movement Document Number Ranges (SAP MKPF/MSEG)

-- Copy from MR to create movement document ranges

-- 1. GI (Goods Issue) - Movement Type 201, 261, etc.
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'GI', 'GI', fiscal_year,
    '5900000000', '5999999999', 5900000000, 5999999999, '5900000000',
    external_numbering, 'GI', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent,
    'Goods Issue Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- 2. TR (Transfer Posting) - Movement Type 311, 313, etc.
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'TR', 'TR', fiscal_year,
    '6000000000', '6099999999', 6000000000, 6099999999, '6000000000',
    external_numbering, 'TR', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent,
    'Transfer Posting Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- 3. MI (Material Inventory) - Physical inventory documents
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'MI', 'MI', fiscal_year,
    '6100000000', '6199999999', 6100000000, 6199999999, '6100000000',
    external_numbering, 'MI', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent,
    'Material Inventory Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- 4. RV (Goods Return) - Movement Type 122, 162, etc.
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'RV', 'RV', fiscal_year,
    '6200000000', '6299999999', 6200000000, 6299999999, '6200000000',
    external_numbering, 'RV', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent,
    'Goods Return Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- Verify all movement document ranges
SELECT 
    document_type,
    description,
    range_from,
    range_to,
    prefix,
    status,
    CASE document_type
        WHEN 'GR' THEN 'Goods Receipt (101, 103)'
        WHEN 'GI' THEN 'Goods Issue (201, 261)'
        WHEN 'TR' THEN 'Transfer (311, 313)'
        WHEN 'MI' THEN 'Physical Inventory'
        WHEN 'RV' THEN 'Returns (122, 162)'
    END as movement_types
FROM document_number_ranges
WHERE document_type IN ('GR', 'GI', 'TR', 'MI', 'RV')
ORDER BY document_type;
