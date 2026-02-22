-- Delete all material requests and related data
-- Delete material request items
DELETE FROM material_request_items;

-- Delete material requests
DELETE FROM material_requests;

-- Reset document numbering for MR
DELETE FROM document_number_ranges WHERE document_type = 'MR';
