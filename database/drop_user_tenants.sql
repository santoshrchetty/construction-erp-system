-- =====================================================
-- DROP USER_TENANTS TABLE (NOW REDUNDANT)
-- =====================================================

-- Drop the table
DROP TABLE IF EXISTS user_tenants CASCADE;

-- Verify it's gone
SELECT 'user_tenants table dropped successfully' as status;
