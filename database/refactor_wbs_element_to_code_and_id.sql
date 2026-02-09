-- Refactor material_requests to store both WBS code and ID
-- Step 1: Add new wbs_id column for foreign key relationship
ALTER TABLE material_requests
ADD COLUMN IF NOT EXISTS wbs_id UUID REFERENCES wbs_elements(id);

-- Step 2: Populate wbs_id from existing wbs_element (which currently stores ID)
UPDATE material_requests
SET wbs_id = wbs_element::uuid
WHERE wbs_element IS NOT NULL 
AND wbs_element ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$';

-- Step 3: Populate wbs_element with actual WBS codes from wbs_elements table
UPDATE material_requests mr
SET wbs_element = we.wbs_element
FROM wbs_elements we
WHERE mr.wbs_id = we.id;

-- Step 4: Create index on wbs_id for performance
CREATE INDEX IF NOT EXISTS idx_material_requests_wbs_id ON material_requests(wbs_id);

-- Step 5: Verify the migration
SELECT 
  request_number,
  wbs_element AS wbs_code,
  wbs_id,
  project_code
FROM material_requests
WHERE wbs_element IS NOT NULL
LIMIT 10;
