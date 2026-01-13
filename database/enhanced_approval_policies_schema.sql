-- Enhanced approval policies with organizational context (safe version)
-- Add columns only if they don't exist
DO $$ 
BEGIN
    -- Add company_code if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='company_code') THEN
        ALTER TABLE approval_policies ADD COLUMN company_code VARCHAR(10);
    END IF;
    
    -- Add country_code if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='country_code') THEN
        ALTER TABLE approval_policies ADD COLUMN country_code VARCHAR(3);
    END IF;
    
    -- Add plant_code if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='plant_code') THEN
        ALTER TABLE approval_policies ADD COLUMN plant_code VARCHAR(20);
    END IF;
    
    -- Add purchase_org if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='purchase_org') THEN
        ALTER TABLE approval_policies ADD COLUMN purchase_org VARCHAR(20);
    END IF;
    
    -- Add project_code if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='project_code') THEN
        ALTER TABLE approval_policies ADD COLUMN project_code VARCHAR(30);
    END IF;
    
    -- Add location_code if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='location_code') THEN
        ALTER TABLE approval_policies ADD COLUMN location_code VARCHAR(20);
    END IF;
END $$;

-- Add indexes for performance (safe)
CREATE INDEX IF NOT EXISTS idx_approval_policies_context ON approval_policies(company_code, country_code, plant_code);
CREATE INDEX IF NOT EXISTS idx_approval_policies_purchase_org ON approval_policies(purchase_org);
CREATE INDEX IF NOT EXISTS idx_approval_policies_project ON approval_policies(project_code);

-- Update existing policies with default context
UPDATE approval_policies 
SET company_code = 'C001',
    country_code = 'USA'
WHERE company_code IS NULL;

-- Add constraint to ensure at least one context dimension is specified
ALTER TABLE approval_policies 
ADD CONSTRAINT chk_policy_context 
CHECK (
    company_code IS NOT NULL OR 
    plant_code IS NOT NULL OR 
    purchase_org IS NOT NULL OR 
    project_code IS NOT NULL
);

-- Verify enhanced schema
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'approval_policies' 
ORDER BY ordinal_position;