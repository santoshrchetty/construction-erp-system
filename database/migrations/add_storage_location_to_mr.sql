-- Add storage_location column to material_requests
ALTER TABLE material_requests ADD COLUMN IF NOT EXISTS storage_location VARCHAR(31);

-- Verify
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'material_requests' AND column_name = 'storage_location';
