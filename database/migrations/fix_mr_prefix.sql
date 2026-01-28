-- Fix MR prefix (remove leading dash)
UPDATE document_number_ranges 
SET prefix = 'MR-C001-' 
WHERE document_type = 'MR' 
  AND prefix LIKE '-%';

-- Verify the fix
SELECT 
    document_type,
    prefix,
    current_number
FROM document_number_ranges 
WHERE document_type = 'MR';