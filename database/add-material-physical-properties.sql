-- Add weight and volume fields to materials table
ALTER TABLE materials
ADD COLUMN IF NOT EXISTS weight_unit VARCHAR(10),
ADD COLUMN IF NOT EXISTS gross_weight DECIMAL(15,3) DEFAULT 0,
ADD COLUMN IF NOT EXISTS net_weight DECIMAL(15,3) DEFAULT 0,
ADD COLUMN IF NOT EXISTS volume_unit VARCHAR(10),
ADD COLUMN IF NOT EXISTS volume DECIMAL(15,3) DEFAULT 0;

-- Verify the columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'materials' 
AND column_name IN ('weight_unit', 'gross_weight', 'net_weight', 'volume_unit', 'volume')
ORDER BY column_name;
