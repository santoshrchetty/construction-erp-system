-- Add working calendar fields to projects table
ALTER TABLE projects 
ADD COLUMN working_days INTEGER[] DEFAULT '{1,2,3,4,5}', -- Monday to Friday
ADD COLUMN holidays DATE[] DEFAULT '{}';

-- Update existing projects with default calendar
UPDATE projects 
SET working_days = '{1,2,3,4,5}', 
    holidays = '{}' 
WHERE working_days IS NULL;

-- Add comment for clarity
COMMENT ON COLUMN projects.working_days IS 'Array of working days (0=Sunday, 6=Saturday)';
COMMENT ON COLUMN projects.holidays IS 'Array of holiday dates to exclude from working days';