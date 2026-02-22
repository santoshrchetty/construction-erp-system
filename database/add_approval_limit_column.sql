-- Add missing approval_limit column to org_hierarchy table
ALTER TABLE org_hierarchy 
ADD COLUMN IF NOT EXISTS approval_limit DECIMAL(15,2);
