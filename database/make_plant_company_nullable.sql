-- Make company_code_id nullable in plants table
-- This allows plants to be created without company assignment
-- Assignments will be handled separately in the Assignments tab

ALTER TABLE plants 
ALTER COLUMN company_code_id DROP NOT NULL;

-- Verify the change
SELECT column_name, is_nullable, data_type 
FROM information_schema.columns 
WHERE table_name = 'plants' AND column_name = 'company_code_id';