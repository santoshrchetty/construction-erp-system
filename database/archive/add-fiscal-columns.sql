-- Add fiscal_year and period columns to universal_journal table
ALTER TABLE universal_journal 
ADD COLUMN fiscal_year INTEGER,
ADD COLUMN period INTEGER;

-- Update existing records with fiscal_year and period based on posting_date
UPDATE universal_journal 
SET 
    fiscal_year = EXTRACT(YEAR FROM posting_date),
    period = EXTRACT(MONTH FROM posting_date)
WHERE fiscal_year IS NULL OR period IS NULL;

-- Make columns NOT NULL after populating existing data
ALTER TABLE universal_journal 
ALTER COLUMN fiscal_year SET NOT NULL,
ALTER COLUMN period SET NOT NULL;

-- Verify the changes
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'universal_journal' 
AND column_name IN ('fiscal_year', 'period')
ORDER BY column_name;