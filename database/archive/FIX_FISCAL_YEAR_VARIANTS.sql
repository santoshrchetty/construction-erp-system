-- Fix fiscal_year_variants table structure
-- Add missing variant_code column

-- Add variant_code column if it doesn't exist
ALTER TABLE fiscal_year_variants ADD COLUMN IF NOT EXISTS variant_code VARCHAR(2);

-- Update existing records to set variant_code
UPDATE fiscal_year_variants 
SET variant_code = fiscal_year_variant 
WHERE variant_code IS NULL;

-- Make variant_code NOT NULL after setting values
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM fiscal_year_variants WHERE variant_code IS NULL) THEN
        ALTER TABLE fiscal_year_variants ALTER COLUMN variant_code SET NOT NULL;
    END IF;
END
$$;

SELECT 'Fiscal year variants table fixed successfully' as status;