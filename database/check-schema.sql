-- Minimal Schema Check - Run this first to see exact column constraints
-- This will show you the exact column sizes causing the error

SELECT 
    table_name,
    column_name, 
    data_type,
    character_maximum_length,
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('company_codes', 'companies')
ORDER BY table_name, ordinal_position;

-- Show existing data in company_codes to understand current structure
SELECT * FROM company_codes LIMIT 5;

-- If country column is VARCHAR(2), fix it:
-- ALTER TABLE company_codes ALTER COLUMN country TYPE VARCHAR(10);

-- If currency column is VARCHAR(2), fix it:  
-- ALTER TABLE company_codes ALTER COLUMN currency TYPE VARCHAR(3);