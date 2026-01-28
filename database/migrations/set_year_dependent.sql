-- Set year dependency for movement documents (SAP standard)
UPDATE document_number_ranges
SET year_dependent = true
WHERE document_type IN ('GR', 'GI', 'TR', 'MI', 'RV', 'MATERIAL');

-- Verify
SELECT 
    document_type,
    fiscal_year,
    year_dependent,
    description
FROM document_number_ranges
WHERE document_type IN ('GR', 'GI', 'TR', 'MI', 'RV', 'MATERIAL')
ORDER BY document_type;
