-- Update document_type to use 3-letter codes
ALTER TABLE document_records DROP CONSTRAINT IF EXISTS document_records_document_type_check;

-- Add new constraint with 3-letter codes
ALTER TABLE document_records ADD CONSTRAINT document_records_document_type_check 
CHECK (document_type IN ('DRW', 'SPE', 'CNT', 'RFI', 'SUB', 'CHG', 'DOC'));

-- Update existing records to use 3-letter codes
UPDATE document_records SET document_type = 'DRW' WHERE document_type = 'DRAWING';
UPDATE document_records SET document_type = 'SPE' WHERE document_type = 'SPECIFICATION';
UPDATE document_records SET document_type = 'CNT' WHERE document_type = 'CONTRACT';
UPDATE document_records SET document_type = 'RFI' WHERE document_type = 'RFI';
UPDATE document_records SET document_type = 'SUB' WHERE document_type = 'SUBMITTAL';
UPDATE document_records SET document_type = 'CHG' WHERE document_type = 'CHANGE_ORDER';
UPDATE document_records SET document_type = 'DOC' WHERE document_type = 'OTHER';

-- Verify the updates
SELECT document_number, document_type, title FROM document_records 
WHERE tenant_id = '9bd339ec-9877-4d9f-b3dc-3e60048c1b15';