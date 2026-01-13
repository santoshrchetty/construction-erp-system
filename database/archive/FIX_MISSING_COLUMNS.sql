-- Fix Missing Columns in GL Posting Tables
-- Add missing columns that may not have been created

-- Add missing columns to document_number_ranges table
ALTER TABLE document_number_ranges 
ADD COLUMN IF NOT EXISTS number_range_object VARCHAR(10) NOT NULL DEFAULT 'RF_BELEG';

-- Add missing columns to fiscal_year_variants table
ALTER TABLE fiscal_year_variants 
ADD COLUMN IF NOT EXISTS variant_code VARCHAR(2) NOT NULL DEFAULT 'K4',
ADD COLUMN IF NOT EXISTS variant_name VARCHAR(50) NOT NULL DEFAULT 'Calendar Year',
ADD COLUMN IF NOT EXISTS start_month INTEGER NOT NULL DEFAULT 1,
ADD COLUMN IF NOT EXISTS start_day INTEGER NOT NULL DEFAULT 1;

-- Add unique constraint on variant_code if it doesn't exist
ALTER TABLE fiscal_year_variants 
ADD CONSTRAINT fiscal_year_variants_variant_code_key UNIQUE (variant_code)
ON CONFLICT DO NOTHING;

-- Add missing company_code_id column to profit_centers table
ALTER TABLE profit_centers 
ADD COLUMN IF NOT EXISTS company_code_id UUID;

-- Add foreign key constraint if it doesn't exist
ALTER TABLE profit_centers 
ADD CONSTRAINT fk_profit_centers_company_code 
FOREIGN KEY (company_code_id) REFERENCES company_codes(id)
ON CONFLICT DO NOTHING;

SELECT 'Missing columns added successfully' as status;