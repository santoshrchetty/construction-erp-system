-- Add missing columns to existing GL posting tables

-- Add missing columns to profit_centers table
ALTER TABLE profit_centers ADD COLUMN IF NOT EXISTS company_code VARCHAR(4);
ALTER TABLE profit_centers ADD COLUMN IF NOT EXISTS profit_center_code VARCHAR(10);
ALTER TABLE profit_centers ADD COLUMN IF NOT EXISTS profit_center_name VARCHAR(100);
ALTER TABLE profit_centers ADD COLUMN IF NOT EXISTS profit_center_type VARCHAR(20) DEFAULT 'STANDARD';
ALTER TABLE profit_centers ADD COLUMN IF NOT EXISTS responsible_person VARCHAR(100);
ALTER TABLE profit_centers ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE profit_centers ADD COLUMN IF NOT EXISTS valid_from DATE DEFAULT CURRENT_DATE;
ALTER TABLE profit_centers ADD COLUMN IF NOT EXISTS valid_to DATE DEFAULT '9999-12-31';

-- Add missing columns to wbs_elements table
ALTER TABLE wbs_elements ADD COLUMN IF NOT EXISTS company_code VARCHAR(4);
ALTER TABLE wbs_elements ADD COLUMN IF NOT EXISTS project_code VARCHAR(20);
ALTER TABLE wbs_elements ADD COLUMN IF NOT EXISTS wbs_element VARCHAR(24);
ALTER TABLE wbs_elements ADD COLUMN IF NOT EXISTS wbs_description VARCHAR(100);
ALTER TABLE wbs_elements ADD COLUMN IF NOT EXISTS wbs_level INTEGER DEFAULT 1;
ALTER TABLE wbs_elements ADD COLUMN IF NOT EXISTS parent_wbs VARCHAR(24);
ALTER TABLE wbs_elements ADD COLUMN IF NOT EXISTS project_manager VARCHAR(100);
ALTER TABLE wbs_elements ADD COLUMN IF NOT EXISTS profit_center_code VARCHAR(10);
ALTER TABLE wbs_elements ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE wbs_elements ADD COLUMN IF NOT EXISTS project_start_date DATE;
ALTER TABLE wbs_elements ADD COLUMN IF NOT EXISTS project_end_date DATE;

-- Add missing columns to fiscal_year_variants table
ALTER TABLE fiscal_year_variants ADD COLUMN IF NOT EXISTS company_code VARCHAR(4);
ALTER TABLE fiscal_year_variants ADD COLUMN IF NOT EXISTS fiscal_year_variant VARCHAR(2);
ALTER TABLE fiscal_year_variants ADD COLUMN IF NOT EXISTS fiscal_year INTEGER;
ALTER TABLE fiscal_year_variants ADD COLUMN IF NOT EXISTS period_number INTEGER;
ALTER TABLE fiscal_year_variants ADD COLUMN IF NOT EXISTS period_start_date DATE;
ALTER TABLE fiscal_year_variants ADD COLUMN IF NOT EXISTS period_end_date DATE;
ALTER TABLE fiscal_year_variants ADD COLUMN IF NOT EXISTS is_open BOOLEAN DEFAULT true;

-- Add unique constraints where needed
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profit_centers_company_code_key') THEN
        ALTER TABLE profit_centers ADD CONSTRAINT profit_centers_company_code_key UNIQUE(company_code, profit_center_code);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'wbs_elements_company_wbs_key') THEN
        ALTER TABLE wbs_elements ADD CONSTRAINT wbs_elements_company_wbs_key UNIQUE(company_code, wbs_element);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fiscal_year_variants_company_period_key') THEN
        ALTER TABLE fiscal_year_variants ADD CONSTRAINT fiscal_year_variants_company_period_key UNIQUE(company_code, fiscal_year, period_number);
    END IF;
END
$$;

SELECT 'Missing columns added to GL posting tables successfully' as status;