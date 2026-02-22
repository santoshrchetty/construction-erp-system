-- Remove requested_by from line items (keep only at header level)
ALTER TABLE material_request_items 
DROP COLUMN IF EXISTS requested_by;
