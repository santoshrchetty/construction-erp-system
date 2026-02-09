-- Remove organizational columns from projects table
-- Projects in SAP are logical containers without direct organizational assignments
-- All organizational assignments are maintained at WBS element level

-- Step 1: Remove company_code column
ALTER TABLE projects DROP COLUMN IF EXISTS company_code;

-- Step 2: Remove plant_code column  
ALTER TABLE projects DROP COLUMN IF EXISTS plant_code;

-- Step 3: Remove cost_center column
ALTER TABLE projects DROP COLUMN IF EXISTS cost_center;

-- Step 4: Remove profit_center column
ALTER TABLE projects DROP COLUMN IF EXISTS profit_center;

-- Step 5: Remove site_code column
ALTER TABLE projects DROP COLUMN IF EXISTS site_code;

-- Step 6: Remove site_name column
ALTER TABLE projects DROP COLUMN IF EXISTS site_name;

-- Verify the changes
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'projects' 
ORDER BY ordinal_position;