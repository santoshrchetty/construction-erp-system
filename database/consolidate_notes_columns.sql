-- Keep only 'notes' column, drop 'purpose' and 'justification'
ALTER TABLE material_request_items 
DROP COLUMN IF EXISTS purpose,
DROP COLUMN IF EXISTS justification;
