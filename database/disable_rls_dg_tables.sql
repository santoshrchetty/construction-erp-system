-- Disable RLS on all Document Governance tables
ALTER TABLE drawings DISABLE ROW LEVEL SECURITY;
ALTER TABLE contracts DISABLE ROW LEVEL SECURITY;
ALTER TABLE rfis DISABLE ROW LEVEL SECURITY;
ALTER TABLE specifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE submittals DISABLE ROW LEVEL SECURITY;
ALTER TABLE change_orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE master_data_documents DISABLE ROW LEVEL SECURITY;

-- Drop any existing RLS policies that reference app.current_tenant_id
DROP POLICY IF EXISTS drawings_tenant_isolation ON drawings;
DROP POLICY IF EXISTS tenant_isolation_policy ON contracts;
DROP POLICY IF EXISTS tenant_isolation_policy ON rfis;
DROP POLICY IF EXISTS tenant_isolation_policy ON specifications;
DROP POLICY IF EXISTS tenant_isolation_policy ON submittals;
DROP POLICY IF EXISTS tenant_isolation_policy ON change_orders;
DROP POLICY IF EXISTS tenant_isolation_policy ON master_data_documents;

-- Verify RLS is disabled
SELECT 
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename IN ('drawings', 'contracts', 'rfis', 'specifications', 'submittals', 'change_orders', 'master_data_documents')
ORDER BY tablename;
