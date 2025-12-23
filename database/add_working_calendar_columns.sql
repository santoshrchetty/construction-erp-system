-- Add created_by column if it doesn't exist
ALTER TABLE projects 
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id);

-- Update existing projects with default calendar (columns already exist)
UPDATE projects 
SET working_days = '{1,2,3,4,5}', 
    holidays = '{}' 
WHERE working_days IS NULL OR holidays IS NULL;

-- Add comments for clarity
COMMENT ON COLUMN projects.working_days IS 'Array of working days (0=Sunday, 6=Saturday)';
COMMENT ON COLUMN projects.holidays IS 'Array of holiday dates to exclude from working days';
COMMENT ON COLUMN projects.created_by IS 'User who created the project';

SELECT 'Working calendar columns and created_by updated successfully!' as status;