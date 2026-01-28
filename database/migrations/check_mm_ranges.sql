-- Check all MM (Materials Management) number ranges
SELECT 
    document_type,
    description,
    range_from,
    range_to,
    current_number,
    prefix,
    status,
    CASE 
        WHEN document_type IN ('MATERIAL', 'MAT') THEN 'Material Master'
        WHEN document_type IN ('MR', 'MATERIAL_REQUEST') THEN 'Material Request'
        WHEN document_type IN ('PR', 'BANFN') THEN 'Purchase Requisition'
        WHEN document_type IN ('PO', 'EBELN') THEN 'Purchase Order'
        WHEN document_type IN ('GR', 'MBLNR') THEN 'Goods Receipt'
        WHEN document_type IN ('INVOICE', 'INV') THEN 'Invoice'
        ELSE 'Other'
    END as mm_category
FROM document_number_ranges
WHERE document_type IN (
    'MATERIAL', 'MAT',
    'MR', 'MATERIAL_REQUEST',
    'PR', 'BANFN',
    'PO', 'EBELN',
    'GR', 'MBLNR',
    'INVOICE', 'INV'
)
ORDER BY document_type;

-- Summary
SELECT 
    CASE 
        WHEN document_type IN ('MATERIAL', 'MAT') THEN '✓ Material Master'
        WHEN document_type IN ('MR', 'MATERIAL_REQUEST') THEN '✓ Material Request'
        WHEN document_type IN ('PR', 'BANFN') THEN '✓ Purchase Requisition'
        WHEN document_type IN ('PO', 'EBELN') THEN '✓ Purchase Order'
        WHEN document_type IN ('GR', 'MBLNR') THEN '✓ Goods Receipt'
        WHEN document_type IN ('INVOICE', 'INV') THEN '✓ Invoice'
    END as configured
FROM document_number_ranges
WHERE document_type IN ('MATERIAL', 'MAT', 'MR', 'MATERIAL_REQUEST', 'PR', 'BANFN', 'PO', 'EBELN', 'GR', 'MBLNR', 'INVOICE', 'INV')
GROUP BY document_type;
