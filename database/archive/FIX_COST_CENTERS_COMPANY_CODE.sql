-- Minimal fix: Add missing company_code column to cost_centers
-- Run this first to fix the immediate error

-- Add company_code column to existing cost_centers table
ALTER TABLE cost_centers ADD COLUMN IF NOT EXISTS company_code VARCHAR(4);

-- Update existing records to derive company_code from organizational_hierarchy
UPDATE cost_centers 
SET company_code = (
    SELECT DISTINCT company_code 
    FROM organizational_hierarchy 
    WHERE company_code IS NOT NULL 
    LIMIT 1
)
WHERE company_code IS NULL;

-- If no organizational_hierarchy data exists, leave as nullable
-- Make company_code NOT NULL only if all records have values
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM cost_centers WHERE company_code IS NULL) THEN
        ALTER TABLE cost_centers ALTER COLUMN company_code SET NOT NULL;
    END IF;
END
$$;

SELECT 'Company code column added to cost_centers successfully' as status;