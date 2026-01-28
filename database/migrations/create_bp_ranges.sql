-- Business Partner Number Ranges (SAP BUT000)

-- Copy from MR to create BP master data ranges

-- 1. BP (Business Partner) - General BP number
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'BP', 'BP', fiscal_year,
    '0010000000', '0019999999', 10000000, 19999999, '0010000000',
    external_numbering, 'BP', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, false,
    'Business Partner Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- 2. CUSTOMER (Customer Master) - SAP KUNNR
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'CUSTOMER', 'CUSTOMER', fiscal_year,
    '0020000000', '0029999999', 20000000, 29999999, '0020000000',
    external_numbering, 'CU', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, false,
    'Customer Master Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- 3. VENDOR (Vendor Master) - SAP LIFNR
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'VENDOR', 'VENDOR', fiscal_year,
    '0030000000', '0039999999', 30000000, 39999999, '0030000000',
    external_numbering, 'VE', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, false,
    'Vendor Master Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- 4. EMPLOYEE (Employee Master) - SAP PERNR
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'EMPLOYEE', 'EMPLOYEE', fiscal_year,
    '0040000000', '0049999999', 40000000, 49999999, '0040000000',
    external_numbering, 'EM', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, false,
    'Employee Master Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- 5. CONTACT (Contact Person)
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'CONTACT', 'CONTACT', fiscal_year,
    '0050000000', '0059999999', 50000000, 59999999, '0050000000',
    external_numbering, 'CP', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, false,
    'Contact Person Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- Verify all BP ranges
SELECT 
    document_type,
    description,
    range_from,
    range_to,
    prefix,
    year_dependent,
    status,
    CASE document_type
        WHEN 'BP' THEN 'Business Partner (BUT000)'
        WHEN 'CUSTOMER' THEN 'Customer (KNA1/KUNNR)'
        WHEN 'VENDOR' THEN 'Vendor (LFA1/LIFNR)'
        WHEN 'EMPLOYEE' THEN 'Employee (PA0000/PERNR)'
        WHEN 'CONTACT' THEN 'Contact Person (KNVK)'
    END as sap_tables
FROM document_number_ranges
WHERE document_type IN ('BP', 'CUSTOMER', 'VENDOR', 'EMPLOYEE', 'CONTACT')
ORDER BY document_type;
