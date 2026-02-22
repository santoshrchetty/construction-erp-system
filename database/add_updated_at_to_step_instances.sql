-- Add updated_at column to step_instances
ALTER TABLE step_instances 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE;

-- Verify the column was added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'step_instances'
AND column_name IN ('created_at', 'updated_at')
ORDER BY ordinal_position;
