-- Verify tables exist and have data
SELECT 
    'projects' as table_name,
    COUNT(*) as row_count,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'projects') as column_count
FROM projects
UNION ALL
SELECT 
    'wbs_nodes',
    COUNT(*),
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'wbs_nodes')
FROM wbs_nodes
UNION ALL
SELECT 
    'activities',
    COUNT(*),
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'activities')
FROM activities
UNION ALL
SELECT 
    'tasks',
    COUNT(*),
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'tasks')
FROM tasks;
