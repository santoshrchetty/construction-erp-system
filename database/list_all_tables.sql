-- List all tables in the database
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- Alternative: List tables with row counts
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

-- List only approval/workflow related tables
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size('public.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
  AND (tablename LIKE '%approval%' OR tablename LIKE '%workflow%' OR tablename LIKE '%step%' OR tablename LIKE '%agent%')
ORDER BY tablename;
