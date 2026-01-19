-- ============================================================================
-- ROLLBACK: Revert companies.grpcompany_name back to company_name
-- ============================================================================

BEGIN;

ALTER TABLE companies 
RENAME COLUMN grpcompany_name TO company_name;

COMMIT;

-- Verification
SELECT column_name, data_type
FROM information_schema.columns 
WHERE table_name = 'companies'
  AND table_schema = 'public'
ORDER BY ordinal_position;
