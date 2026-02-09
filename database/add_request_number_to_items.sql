-- Add request_number column to material_request_items for easier understanding
ALTER TABLE material_request_items
ADD COLUMN IF NOT EXISTS request_number VARCHAR(50);

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_material_request_items_request_number 
ON material_request_items(request_number);

-- Populate existing records
UPDATE material_request_items mri
SET request_number = mr.request_number
FROM material_requests mr
WHERE mri.request_id = mr.id
AND mri.request_number IS NULL;
