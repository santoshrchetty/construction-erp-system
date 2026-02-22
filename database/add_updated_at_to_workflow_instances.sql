-- Check if updated_at column exists
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'workflow_instances';

-- Add updated_at column if it doesn't exist
ALTER TABLE workflow_instances 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Verify the column was added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'workflow_instances'
ORDER BY ordinal_position;
