-- Remove columns from material_requests header that belong at line item level
ALTER TABLE material_requests 
DROP COLUMN IF EXISTS justification,
DROP COLUMN IF EXISTS wbs_element,
DROP COLUMN IF EXISTS old_request_number,
DROP COLUMN IF EXISTS activity_code,
DROP COLUMN IF EXISTS storage_location,
DROP COLUMN IF EXISTS wbs_id,
DROP COLUMN IF EXISTS project_code,
DROP COLUMN IF EXISTS cost_center,
DROP COLUMN IF EXISTS purpose,
DROP COLUMN IF EXISTS notes,
DROP COLUMN IF EXISTS plant_code,
DROP COLUMN IF EXISTS total_amount,
DROP COLUMN IF EXISTS currency_code;
