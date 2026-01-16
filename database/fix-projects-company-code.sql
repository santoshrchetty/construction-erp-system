-- Add company_code column to projects table
-- This is needed for the dashboard API to work

-- Add the column
ALTER TABLE projects ADD COLUMN IF NOT EXISTS company_code VARCHAR(10);

-- Populate from existing company_code_id
UPDATE projects 
SET company_code = cc.company_code
FROM company_codes cc 
WHERE projects.company_code_id = cc.id 
AND projects.company_code IS NULL;

-- Create index
CREATE INDEX IF NOT EXISTS idx_projects_company_code_string ON projects(company_code);

-- Verify the update
SELECT 
    COUNT(*) as total_projects,
    COUNT(company_code_id) as with_uuid,
    COUNT(company_code) as with_string,
    COUNT(CASE WHEN company_code_id IS NOT NULL AND company_code IS NOT NULL THEN 1 END) as both_populated
FROM projects;