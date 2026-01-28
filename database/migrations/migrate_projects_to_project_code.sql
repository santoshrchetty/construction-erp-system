-- Migration: Projects table - rename code to project_code
-- Step 1: Add project_code column
ALTER TABLE projects ADD COLUMN IF NOT EXISTS project_code VARCHAR(31);

-- Step 2: Copy code to project_code
UPDATE projects SET project_code = code;

-- Step 3: Make project_code NOT NULL and UNIQUE
ALTER TABLE projects ALTER COLUMN project_code SET NOT NULL;
ALTER TABLE projects ADD CONSTRAINT projects_project_code_unique UNIQUE (project_code);

-- Step 4: Drop dependent views first
DROP VIEW IF EXISTS project_stock_overview CASCADE;

-- Step 5: Drop code column
ALTER TABLE projects DROP COLUMN code;

-- Step 6: Verify
SELECT column_name FROM information_schema.columns WHERE table_name = 'projects' ORDER BY ordinal_position;
