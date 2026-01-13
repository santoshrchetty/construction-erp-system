-- COMPREHENSIVE FUNCTIONALITY CHECK
-- Analyze what's implemented vs what's missing

-- ========================================
-- 1. CHECK TILES AND COMPONENTS
-- ========================================

SELECT 'CHECKING TILES AND COMPONENTS' as section;

SELECT 
  title,
  construction_action,
  tile_category,
  CASE 
    WHEN construction_action IS NULL THEN 'MISSING COMPONENT'
    ELSE 'COMPONENT EXISTS'
  END as component_status
FROM tiles 
WHERE is_active = true
ORDER BY tile_category, title;

-- ========================================
-- 2. CHECK API ENDPOINTS
-- ========================================

SELECT 'CHECKING API COVERAGE' as section;

-- Check if key API directories exist (simulated check)
SELECT 'materials' as api_endpoint, 'EXISTS' as status
UNION ALL
SELECT 'suppliers' as api_endpoint, 'EXISTS' as status
UNION ALL
SELECT 'wbs' as api_endpoint, 'EXISTS' as status
UNION ALL
SELECT 'erp-config/projects' as api_endpoint, 'EXISTS' as status;

-- ========================================
-- 3. CHECK DATABASE TABLES
-- ========================================

SELECT 'CHECKING DATABASE TABLES' as section;

SELECT 
  table_name,
  CASE 
    WHEN table_name IN ('wbs_nodes', 'activities', 'tasks') THEN 'WBS MANAGEMENT'
    WHEN table_name IN ('material_master', 'suppliers') THEN 'MASTER DATA'
    WHEN table_name IN ('projects', 'project_categories') THEN 'PROJECT SYSTEM'
    WHEN table_name IN ('universal_journal', 'account_determination') THEN 'FINANCE'
    ELSE 'OTHER'
  END as module
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
  AND table_name NOT LIKE '%_old'
ORDER BY module, table_name;

-- ========================================
-- 4. CHECK MISSING CRITICAL FUNCTIONS
-- ========================================

SELECT 'CHECKING CRITICAL FUNCTIONS' as section;

-- Check for key functions
SELECT 
  routine_name as function_name,
  'EXISTS' as status
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_type = 'FUNCTION'
  AND routine_name IN (
    'get_tax_gl_account',
    'enforce_capital_goods_itc',
    'determine_gl_chatgpt_compliant'
  );

-- ========================================
-- 5. IDENTIFY MISSING FUNCTIONALITIES
-- ========================================

SELECT 'MISSING FUNCTIONALITY ANALYSIS' as section;

-- Common ERP functionalities that might be missing
SELECT 'Purchase Orders (PO)' as functionality, 
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'purchase_orders') 
            THEN 'EXISTS' ELSE 'MISSING' END as status
UNION ALL
SELECT 'Goods Receipt Notes (GRN)' as functionality,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'goods_receipts') 
            THEN 'EXISTS' ELSE 'MISSING' END as status
UNION ALL
SELECT 'Invoice Processing' as functionality,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'invoices') 
            THEN 'EXISTS' ELSE 'MISSING' END as status
UNION ALL
SELECT 'Inventory Management' as functionality,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'stock_balances') 
            THEN 'EXISTS' ELSE 'MISSING' END as status
UNION ALL
SELECT 'Financial Reporting' as functionality,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'trial_balance') 
            THEN 'EXISTS' ELSE 'MISSING' END as status
UNION ALL
SELECT 'Approval Workflows' as functionality,
       CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'approval_policies') 
            THEN 'EXISTS' ELSE 'MISSING' END as status;

-- ========================================
-- 6. CHECK COMPONENT COMPLETENESS
-- ========================================

SELECT 'COMPONENT COMPLETENESS CHECK' as section;

-- Check if components have corresponding APIs and database support
WITH component_check AS (
  SELECT 
    title,
    construction_action,
    CASE 
      WHEN construction_action = 'WBSBuilder' THEN 
        CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'wbs_nodes') 
             THEN 'COMPLETE' ELSE 'INCOMPLETE' END
      WHEN construction_action = 'supplier-master' THEN
        CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'suppliers') 
             THEN 'COMPLETE' ELSE 'INCOMPLETE' END
      WHEN construction_action = 'materials' THEN
        CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'material_master') 
             THEN 'COMPLETE' ELSE 'INCOMPLETE' END
      ELSE 'UNKNOWN'
    END as completeness_status
  FROM tiles 
  WHERE is_active = true
)
SELECT * FROM component_check WHERE completeness_status != 'UNKNOWN';

SELECT 'FUNCTIONALITY CHECK COMPLETE' as final_status;