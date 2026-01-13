-- =====================================================
-- UNIFIED SCHEMA FIXES
-- Apply these fixes to the unified schema
-- =====================================================

-- Fix 1: Clean up orphaned vendor references and add foreign key constraint
-- First, set orphaned vendor_id to NULL
UPDATE activities 
SET vendor_id = NULL 
WHERE vendor_id IS NOT NULL 
  AND vendor_id NOT IN (SELECT id FROM vendors);

-- Then add the foreign key constraint
ALTER TABLE activities 
ADD CONSTRAINT activities_vendor_id_fkey 
FOREIGN KEY (vendor_id) REFERENCES vendors(id);

-- Fix 2: Add missing critical tables (with IF NOT EXISTS)
-- Note: Skip controlling_areas as it already exists

-- Movement Type Account Mappings (for automatic GL posting)
CREATE TABLE IF NOT EXISTS movement_type_account_mappings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR(4) NOT NULL,
    movement_type VARCHAR(10) NOT NULL,
    material_type VARCHAR(10) DEFAULT '*',
    account_modification VARCHAR(3) DEFAULT '001',
    debit_account VARCHAR(10) NOT NULL,
    credit_account VARCHAR(10) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(company_code, movement_type, material_type, account_modification)
);

-- Document Number Ranges
CREATE TABLE IF NOT EXISTS document_number_ranges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR(4) NOT NULL,
    document_type VARCHAR(10) NOT NULL,
    fiscal_year INTEGER NOT NULL,
    range_from VARCHAR(20) NOT NULL,
    range_to VARCHAR(20) NOT NULL,
    current_number VARCHAR(20) NOT NULL,
    external_numbering BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(company_code, document_type, fiscal_year)
);

-- Profit Centers
CREATE TABLE IF NOT EXISTS profit_centers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    profit_center_code VARCHAR(10) UNIQUE NOT NULL,
    profit_center_name VARCHAR(255) NOT NULL,
    responsible_person VARCHAR(255),
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Company Code to Controlling Area Assignment (using existing controlling_areas table)
-- Note: This references the existing controlling_areas table structure
CREATE TABLE IF NOT EXISTS company_controlling_areas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    controlling_area_id UUID NOT NULL REFERENCES controlling_areas(id),
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    UNIQUE(company_code_id, controlling_area_id)
);

-- Fix 3: Add profit center to relevant tables (if columns don't exist)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'projects' AND column_name = 'profit_center_id') THEN
        ALTER TABLE projects ADD COLUMN profit_center_id UUID REFERENCES profit_centers(id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cost_centers' AND column_name = 'profit_center_id') THEN
        ALTER TABLE cost_centers ADD COLUMN profit_center_id UUID REFERENCES profit_centers(id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'journal_entries' AND column_name = 'profit_center') THEN
        ALTER TABLE journal_entries ADD COLUMN profit_center VARCHAR(10);
    END IF;
END $$;

-- Fix 4: Add controlling area to cost centers (if column doesn't exist)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cost_centers' AND column_name = 'controlling_area_id') THEN
        ALTER TABLE cost_centers ADD COLUMN controlling_area_id UUID REFERENCES controlling_areas(id);
    END IF;
END $$;

-- Fix 5: Resolve circular reference by making plants.project_id optional
-- This is already handled correctly in the schema with project_id UUID (nullable)

-- Fix 6: Add missing indexes for new tables (if they don't exist)
DO $$
BEGIN
    -- Only create indexes if the tables exist
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movement_type_account_mappings') THEN
        CREATE INDEX IF NOT EXISTS idx_movement_type_mappings_company ON movement_type_account_mappings(company_code);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'document_number_ranges') THEN
        CREATE INDEX IF NOT EXISTS idx_document_ranges_company_type ON document_number_ranges(company_code, document_type);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profit_centers') THEN
        CREATE INDEX IF NOT EXISTS idx_profit_centers_company ON profit_centers(company_code_id);
    END IF;
    
    -- Add index for existing controlling_areas table (uses cocarea_code)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'controlling_areas') THEN
        CREATE INDEX IF NOT EXISTS idx_controlling_areas_code ON controlling_areas(cocarea_code);
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'company_controlling_areas') THEN
        CREATE INDEX IF NOT EXISTS idx_company_controlling_company ON company_controlling_areas(company_code_id);
    END IF;
END $$;

-- Fix 7: Add missing triggers for new tables (if they exist)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profit_centers') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'update_profit_centers_updated_at') THEN
            CREATE TRIGGER update_profit_centers_updated_at BEFORE UPDATE ON profit_centers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
        END IF;
    END IF;
END $$;

-- Fix 8: Add comments for new tables (skip existing controlling_areas)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'movement_type_account_mappings') THEN
        COMMENT ON TABLE movement_type_account_mappings IS 'Account determination for inventory movements';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'document_number_ranges') THEN
        COMMENT ON TABLE document_number_ranges IS 'Document numbering configuration per company';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profit_centers') THEN
        COMMENT ON TABLE profit_centers IS 'Profit center master data for profitability analysis';
    END IF;
END $$;

-- Fix 9: Add sample data using existing controlling_areas table
-- Skip inserting data since controlling_areas already exists with data

-- Fix 10: Add validation constraints (if they don't exist and columns exist)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_range_validity') THEN
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'document_number_ranges') THEN
            ALTER TABLE document_number_ranges ADD CONSTRAINT check_range_validity 
            CHECK (range_from <= range_to AND current_number >= range_from AND current_number <= range_to);
        END IF;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_profit_center_dates') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profit_centers' AND column_name = 'valid_to') THEN
            ALTER TABLE profit_centers ADD CONSTRAINT check_profit_center_dates 
            CHECK (valid_to IS NULL OR valid_to >= valid_from);
        END IF;
    END IF;
    
    -- Only add cost center date constraint if both valid_from and valid_to columns exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE constraint_name = 'check_cost_center_dates') THEN
        IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cost_centers' AND column_name = 'valid_to') 
           AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cost_centers' AND column_name = 'valid_from') THEN
            ALTER TABLE cost_centers ADD CONSTRAINT check_cost_center_dates 
            CHECK (valid_to IS NULL OR valid_to >= valid_from);
        END IF;
    END IF;
END $$;

-- Schema fixes completed
SELECT 'Unified Schema Fixes Applied Successfully!' as status;