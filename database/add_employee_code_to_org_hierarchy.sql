-- Add employee_code field to org_hierarchy
ALTER TABLE org_hierarchy 
ADD COLUMN IF NOT EXISTS employee_code VARCHAR(20);

-- Create unique index on employee_code
CREATE UNIQUE INDEX IF NOT EXISTS idx_org_hierarchy_employee_code 
ON org_hierarchy(employee_code) WHERE employee_code IS NOT NULL;
