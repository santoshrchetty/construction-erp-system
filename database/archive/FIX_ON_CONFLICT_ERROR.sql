-- Fix ON CONFLICT Error - Add Missing Unique Constraint
-- The error occurs because document_number_ranges table lacks unique constraint

-- Step 1: Check current table structure
SELECT 
    'Current Constraints' as info,
    conname as constraint_name,
    contype as constraint_type
FROM pg_constraint 
WHERE conrelid = 'document_number_ranges'::regclass;

-- Step 2: Add missing unique constraint
ALTER TABLE document_number_ranges 
DROP CONSTRAINT IF EXISTS unique_company_document_type;

ALTER TABLE document_number_ranges 
ADD CONSTRAINT unique_company_document_type 
UNIQUE (company_code, document_type);

-- Step 3: Create index for performance
CREATE INDEX IF NOT EXISTS idx_document_number_ranges_company_type 
ON document_number_ranges(company_code, document_type);

-- Step 4: Verify constraint was added
SELECT 
    'Constraint Added Successfully' as status,
    conname as constraint_name
FROM pg_constraint 
WHERE conrelid = 'document_number_ranges'::regclass
AND conname = 'unique_company_document_type';

SELECT 'Ready for deployment - ON CONFLICT error fixed' as final_status;