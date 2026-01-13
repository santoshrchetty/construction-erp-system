-- RUN WBS SCHEMA CREATION AND VERIFICATION
-- Execute the WBS schema creation and verify setup

-- ========================================
-- 1. RUN WBS SCHEMA CREATION
-- ========================================

\i database/create-wbs-schema.sql

-- ========================================
-- 2. VERIFY WBS TABLES CREATED
-- ========================================

SELECT 'Checking WBS tables...' as status;

SELECT table_name 
FROM information_schema.tables 
WHERE table_name IN ('wbs_nodes', 'activities', 'tasks', 'vendors')
ORDER BY table_name;

-- ========================================
-- 3. VERIFY TILE MAPPING UPDATED
-- ========================================

SELECT 'Checking WBS tile mapping...' as status;

SELECT 
  title,
  construction_action,
  tile_category
FROM tiles 
WHERE title = 'WBS Management';

-- ========================================
-- 4. VERIFY SAMPLE VENDORS CREATED
-- ========================================

SELECT 'Checking sample vendors...' as status;

SELECT code, name, status FROM vendors ORDER BY code;

SELECT 'WBS SETUP VERIFICATION COMPLETE' as final_status;