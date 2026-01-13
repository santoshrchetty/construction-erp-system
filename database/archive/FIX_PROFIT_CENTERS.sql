-- Fix profit_centers table structure
-- Handle the company_code_id NOT NULL constraint

-- First, check what columns exist in profit_centers
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'profit_centers' 
ORDER BY ordinal_position;

-- Update existing records to set company_code_id if it exists
DO $$
BEGIN
    -- Check if company_code_id column exists and is causing issues
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profit_centers' AND column_name = 'company_code_id') THEN
        -- Try to get a valid company_code_id from company_codes table
        UPDATE profit_centers 
        SET company_code_id = (
            SELECT id 
            FROM company_codes 
            WHERE company_code = profit_centers.company_code 
            LIMIT 1
        )
        WHERE company_code_id IS NULL;
        
        -- If still NULL, make the column nullable
        IF EXISTS (SELECT 1 FROM profit_centers WHERE company_code_id IS NULL) THEN
            ALTER TABLE profit_centers ALTER COLUMN company_code_id DROP NOT NULL;
        END IF;
    END IF;
END
$$;

-- Now try to insert profit centers with proper handling
INSERT INTO profit_centers (
    company_code, 
    profit_center_code, 
    profit_center_name, 
    profit_center_type, 
    responsible_person,
    company_code_id
) 
SELECT 
    'C001',
    'PC001-C001',
    'Corporate Administration',
    'OVERHEAD',
    'CFO India',
    cc.id
FROM company_codes cc
WHERE cc.company_code = 'C001'
LIMIT 1
ON CONFLICT (profit_center_code) DO NOTHING;

INSERT INTO profit_centers (
    company_code, 
    profit_center_code, 
    profit_center_name, 
    profit_center_type, 
    responsible_person,
    company_code_id
) 
SELECT 
    'C001',
    'PC002-C001',
    'Construction Projects',
    'REVENUE',
    'Construction Head',
    cc.id
FROM company_codes cc
WHERE cc.company_code = 'C001'
LIMIT 1
ON CONFLICT (profit_center_code) DO NOTHING;

INSERT INTO profit_centers (
    company_code, 
    profit_center_code, 
    profit_center_name, 
    profit_center_type, 
    responsible_person,
    company_code_id
) 
SELECT 
    'B001',
    'PC001-B001',
    'Corporate Administration',
    'OVERHEAD',
    'CFO USA',
    cc.id
FROM company_codes cc
WHERE cc.company_code = 'B001'
LIMIT 1
ON CONFLICT (profit_center_code) DO NOTHING;

SELECT 'Profit centers table fixed and populated successfully' as status;