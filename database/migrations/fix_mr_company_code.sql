-- Update MR number range to use correct company code
UPDATE document_number_ranges 
SET company_code = 'C001' 
WHERE document_type = 'MR' AND company_code = '1000';

-- Verify
SELECT company_code, document_type, prefix, from_number, to_number, current_number 
FROM document_number_ranges 
WHERE document_type = 'MR';
