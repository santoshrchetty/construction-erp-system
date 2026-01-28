-- Add activity_code column to material_requests for account assignment
ALTER TABLE material_requests ADD COLUMN IF NOT EXISTS activity_code VARCHAR(31);

-- Populate from activity_id if exists
UPDATE material_requests mr
SET activity_code = a.code
FROM activities a
WHERE mr.activity_id = a.id AND mr.activity_code IS NULL;

-- Verify
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'material_requests' AND column_name = 'activity_code';
