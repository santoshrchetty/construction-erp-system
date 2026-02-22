-- Fix document subtypes to use correct 3-letter codes
UPDATE documents SET document_subtype = 'GA' WHERE document_subtype = 'GEN';
UPDATE documents SET document_subtype = 'DTL' WHERE document_subtype = 'DET';  
UPDATE documents SET document_subtype = 'SEC' WHERE document_subtype = 'SEC';
UPDATE documents SET document_subtype = 'MAT' WHERE document_subtype = 'MATERIAL';
UPDATE documents SET document_subtype = 'TEC' WHERE document_subtype = 'TECHNICAL';

-- Verify the updates
SELECT document_number, document_type, document_subtype, title 
FROM documents 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY document_type, document_number;