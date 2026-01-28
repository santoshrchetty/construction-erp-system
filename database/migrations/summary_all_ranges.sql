-- Complete Number Range Configuration Summary

SELECT 
    CASE 
        WHEN document_type IN ('MATERIAL', 'MR', 'PR', 'PO', 'GR', 'GI', 'TR', 'MI', 'RV', 'INVOICE') THEN 'MM - Materials Management'
        WHEN document_type IN ('FI_DOC', 'AP_DOC', 'AR_DOC', 'PAYMENT', 'JOURNAL', 'CLEARING') THEN 'FI - Finance'
        WHEN document_type IN ('BP', 'CUSTOMER', 'VENDOR', 'EMPLOYEE', 'CONTACT') THEN 'MD - Master Data'
        ELSE 'Other'
    END as module,
    document_type,
    description,
    prefix,
    range_from,
    range_to,
    current_number,
    year_dependent,
    status
FROM document_number_ranges
WHERE document_type IN (
    'MATERIAL', 'MR', 'PR', 'PO', 'GR', 'GI', 'TR', 'MI', 'RV', 'INVOICE',
    'FI_DOC', 'AP_DOC', 'AR_DOC', 'PAYMENT', 'JOURNAL', 'CLEARING',
    'BP', 'CUSTOMER', 'VENDOR', 'EMPLOYEE', 'CONTACT'
)
ORDER BY module, document_type;

-- Count by module
SELECT 
    CASE 
        WHEN document_type IN ('MATERIAL', 'MR', 'PR', 'PO', 'GR', 'GI', 'TR', 'MI', 'RV', 'INVOICE') THEN 'MM'
        WHEN document_type IN ('FI_DOC', 'AP_DOC', 'AR_DOC', 'PAYMENT', 'JOURNAL', 'CLEARING') THEN 'FI'
        WHEN document_type IN ('BP', 'CUSTOMER', 'VENDOR', 'EMPLOYEE', 'CONTACT') THEN 'MD'
    END as module,
    COUNT(*) as range_count
FROM document_number_ranges
WHERE document_type IN (
    'MATERIAL', 'MR', 'PR', 'PO', 'GR', 'GI', 'TR', 'MI', 'RV', 'INVOICE',
    'FI_DOC', 'AP_DOC', 'AR_DOC', 'PAYMENT', 'JOURNAL', 'CLEARING',
    'BP', 'CUSTOMER', 'VENDOR', 'EMPLOYEE', 'CONTACT'
)
GROUP BY module
ORDER BY module;
