-- Remove request_number from items table (it belongs in header only)
ALTER TABLE material_request_items DROP COLUMN IF EXISTS request_number;

-- The wbs_element column should store the WBS code (not ID)
-- wbs_element_id stores the UUID reference
-- Both are valid and serve different purposes
