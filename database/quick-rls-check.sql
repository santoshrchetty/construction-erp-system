-- Single Query: Check RLS Status and Policies
SELECT 
    t.tablename,
    t.rowsecurity as rls_enabled,
    COUNT(p.policyname) as policy_count,
    STRING_AGG(p.policyname, ', ') as policies
FROM pg_tables t
LEFT JOIN pg_policies p ON t.tablename = p.tablename AND t.schemaname = p.schemaname
WHERE t.schemaname = 'public'
  AND t.tablename IN ('projects', 'wbs_nodes', 'activities', 'tasks')
GROUP BY t.tablename, t.rowsecurity
ORDER BY t.tablename;
