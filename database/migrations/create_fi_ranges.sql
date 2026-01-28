-- Finance Document Number Ranges (SAP BKPF/BSEG - ACDOCA)

-- Copy from MR to create FI document ranges

-- 1. FI_DOC (General Ledger Document) - SAP BELNR
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'FI_DOC', 'FI_DOC', fiscal_year,
    '1000000000', '1099999999', 1000000000, 1099999999, '1000000000',
    external_numbering, 'FI', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, true,
    'FI Document Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- 2. AP_DOC (Accounts Payable) - Vendor invoices
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'AP_DOC', 'AP_DOC', fiscal_year,
    '1100000000', '1199999999', 1100000000, 1199999999, '1100000000',
    external_numbering, 'AP', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, true,
    'AP Document Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- 3. AR_DOC (Accounts Receivable) - Customer invoices
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'AR_DOC', 'AR_DOC', fiscal_year,
    '1200000000', '1299999999', 1200000000, 1299999999, '1200000000',
    external_numbering, 'AR', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, true,
    'AR Document Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- 4. PAYMENT (Payment Document)
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'PAYMENT', 'PAYMENT', fiscal_year,
    '1300000000', '1399999999', 1300000000, 1399999999, '1300000000',
    external_numbering, 'PAY', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, true,
    'Payment Document Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- 5. JOURNAL (Journal Entry)
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'JOURNAL', 'JOURNAL', fiscal_year,
    '1400000000', '1499999999', 1400000000, 1499999999, '1400000000',
    external_numbering, 'JE', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, true,
    'Journal Entry Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- 6. CLEARING (Clearing Document)
INSERT INTO document_number_ranges (
    company_code, document_type, number_range_object, fiscal_year,
    range_from, range_to, from_number, to_number, current_number,
    external_numbering, prefix, suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, year_dependent, description
)
SELECT 
    company_code, 'CLEARING', 'CLEARING', fiscal_year,
    '1500000000', '1599999999', 1500000000, 1599999999, '1500000000',
    external_numbering, 'CLR', suffix, range_number, is_external,
    status, warning_threshold, critical_threshold, interval_size,
    buffer_size, fiscal_year_variant, true,
    'Clearing Document Number Range'
FROM document_number_ranges WHERE document_type = 'MR' LIMIT 1;

-- Verify all FI document ranges
SELECT 
    document_type,
    description,
    range_from,
    range_to,
    prefix,
    year_dependent,
    status,
    CASE document_type
        WHEN 'FI_DOC' THEN 'General Ledger (SA, AB)'
        WHEN 'AP_DOC' THEN 'Vendor Invoice (KR)'
        WHEN 'AR_DOC' THEN 'Customer Invoice (DR)'
        WHEN 'PAYMENT' THEN 'Payment (ZP)'
        WHEN 'JOURNAL' THEN 'Journal Entry (SA)'
        WHEN 'CLEARING' THEN 'Clearing (AB)'
    END as sap_doc_types
FROM document_number_ranges
WHERE document_type IN ('FI_DOC', 'AP_DOC', 'AR_DOC', 'PAYMENT', 'JOURNAL', 'CLEARING')
ORDER BY document_type;
