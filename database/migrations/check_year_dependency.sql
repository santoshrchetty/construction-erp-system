-- Check year dependency settings
SELECT 
    document_type,
    fiscal_year,
    year_dependent,
    fiscal_year_variant,
    range_from,
    range_to
FROM document_number_ranges
WHERE document_type IN ('MR', 'PR', 'PO')
ORDER BY document_type;
