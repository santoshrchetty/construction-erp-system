-- Drop old document numbering function
DROP FUNCTION IF EXISTS get_next_document_number(TEXT, UUID);

-- Update sample data to use new numbering pattern
UPDATE document_records SET document_number = 'DRW-24-0001' WHERE document_number = 'DRAWING-000001';