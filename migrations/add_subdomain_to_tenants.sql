-- Migration: Add subdomain column to tenants table
-- Purpose: Enable subdomain-based multi-tenancy (abc.omegadatalabs.com)

-- Add subdomain column
ALTER TABLE tenants 
ADD COLUMN IF NOT EXISTS subdomain VARCHAR(50) UNIQUE;

-- Add index for fast subdomain lookups
CREATE INDEX IF NOT EXISTS idx_tenants_subdomain ON tenants(subdomain);

-- Update existing tenants with subdomain based on tenant_code
-- Example: ABC001 -> abc, XYZ001 -> xyz
UPDATE tenants 
SET subdomain = LOWER(REGEXP_REPLACE(tenant_code, '[^a-zA-Z]', '', 'g'))
WHERE subdomain IS NULL;

-- Add comment
COMMENT ON COLUMN tenants.subdomain IS 'Unique subdomain for tenant (e.g., abc for abc.omegadatalabs.com)';

-- Verify
SELECT id, tenant_code, tenant_name, subdomain FROM tenants;
