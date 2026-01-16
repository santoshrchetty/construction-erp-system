-- Replace company_code_id (UUID) with company_code (VARCHAR)
-- This aligns with ERP business logic where company codes are string identifiers

-- Drop foreign key constraint first
ALTER TABLE projects DROP CONSTRAINT IF EXISTS projects_company_code_id_fkey;

-- Drop the UUID column
ALTER TABLE projects DROP COLUMN IF EXISTS company_code_id;

-- Add company_code as VARCHAR
ALTER TABLE projects ADD COLUMN company_code VARCHAR(10);

-- Update index
DROP INDEX IF EXISTS idx_projects_company_code;
CREATE INDEX idx_projects_company_code ON projects(company_code);

-- Set default value for existing records
UPDATE projects SET company_code = 'C001' WHERE company_code IS NULL;