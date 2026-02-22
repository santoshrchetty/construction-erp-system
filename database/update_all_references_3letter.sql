-- Update all reference documents to use 3-letter document type codes

-- Update document_records table to use 3-letter codes
UPDATE document_records SET document_type = 'DRW' WHERE document_type = 'DRAWING';
UPDATE document_records SET document_type = 'SPE' WHERE document_type = 'SPECIFICATION';
UPDATE document_records SET document_type = 'CNT' WHERE document_type = 'CONTRACT';
UPDATE document_records SET document_type = 'RFI' WHERE document_type = 'RFI';
UPDATE document_records SET document_type = 'SUB' WHERE document_type = 'SUBMITTAL';
UPDATE document_records SET document_type = 'CHG' WHERE document_type = 'CHANGE_ORDER';
UPDATE document_records SET document_type = 'DOC' WHERE document_type = 'OTHER';

-- Update document numbers to match 3-letter pattern
UPDATE document_records SET document_number = 'DRW-24-0001' WHERE document_number = 'DRAWING-000001';
UPDATE document_records SET document_number = 'SPE-24-0001' WHERE document_number = 'SPEC-000001';
UPDATE document_records SET document_number = 'RFI-24-0001' WHERE document_number = 'RFI-000001';

-- Update any references in other tables
UPDATE drawings SET drawing_number = 'DRW-24-0001' WHERE drawing_number = 'DRAWING-000001';
UPDATE specifications SET spec_number = 'SPE-24-0001' WHERE spec_number = 'SPEC-000001';
UPDATE rfis SET rfi_number = 'RFI-24-0001' WHERE rfi_number = 'RFI-000001';

-- Verify all updates
SELECT document_number, document_type, title FROM document_records 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'
ORDER BY document_number;