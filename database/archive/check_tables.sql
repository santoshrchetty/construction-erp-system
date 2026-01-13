-- Check existing tables in the database
SELECT table_name, table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check if specific tables exist
SELECT 
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'material_master') 
         THEN 'EXISTS' ELSE 'NOT EXISTS' END as material_master,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'material_stock') 
         THEN 'EXISTS' ELSE 'NOT EXISTS' END as material_stock,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'projects') 
         THEN 'EXISTS' ELSE 'NOT EXISTS' END as projects,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'wbs_nodes') 
         THEN 'EXISTS' ELSE 'NOT EXISTS' END as wbs_nodes,
    CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tiles') 
         THEN 'EXISTS' ELSE 'NOT EXISTS' END as tiles;