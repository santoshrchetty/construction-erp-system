-- ============================================================================
-- MIGRATION: Rename companies.company_name to grpcompany_name
-- ============================================================================
-- Purpose: Distinguish group company name from individual company names
-- Impact: Only affects the 'companies' table (parent/group companies)
-- ============================================================================

BEGIN;

-- Rename column in companies table
ALTER TABLE companies 
RENAME COLUMN company_name TO grpcompany_name;

COMMIT;

-- Verification
SELECT column_name, data_type
FROM information_schema.columns 
WHERE table_name = 'companies'
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- Expected result: Should show 'grpcompany_name' instead of 'company_name'
