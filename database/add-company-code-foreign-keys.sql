-- Add foreign key constraints for company_code string relationships
-- This ensures referential integrity while using business-friendly string keys

-- Drop existing constraints first, then add new ones
DO $$ 
BEGIN
    -- Plants table
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'plants_company_code_fkey') THEN
        ALTER TABLE plants ADD CONSTRAINT plants_company_code_fkey 
        FOREIGN KEY (company_code) REFERENCES company_codes(company_code);
    END IF;
    
    -- Purchasing Organizations table
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'porg_company_code_fkey') THEN
        ALTER TABLE purchasing_organizations ADD CONSTRAINT porg_company_code_fkey 
        FOREIGN KEY (company_code) REFERENCES company_codes(company_code);
    END IF;
    
    -- Profit Centers table
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profit_centers_company_code_fkey') THEN
        ALTER TABLE profit_centers ADD CONSTRAINT profit_centers_company_code_fkey 
        FOREIGN KEY (company_code) REFERENCES company_codes(company_code);
    END IF;
    
    -- Cost Centers table
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'cost_centers_company_code_fkey') THEN
        ALTER TABLE cost_centers ADD CONSTRAINT cost_centers_company_code_fkey 
        FOREIGN KEY (company_code) REFERENCES company_codes(company_code);
    END IF;
    
    -- Projects table
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'projects_company_code_fkey') THEN
        ALTER TABLE projects ADD CONSTRAINT projects_company_code_fkey 
        FOREIGN KEY (company_code) REFERENCES company_codes(company_code);
    END IF;
END $$;