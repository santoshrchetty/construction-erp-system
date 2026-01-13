-- CHECK EXISTING DATABASE STRUCTURE FOR PO IMPLEMENTATION

-- ========================================
-- 1. CHECK IF PURCHASE_ORDERS TABLE EXISTS
-- ========================================

SELECT 'CHECKING PURCHASE_ORDERS TABLE' as section;

SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'purchase_orders') 
    THEN 'EXISTS' 
    ELSE 'MISSING' 
  END as purchase_orders_table;

-- If exists, show columns
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'purchase_orders' 
ORDER BY ordinal_position;

-- ========================================
-- 2. CHECK VENDORS TABLE STRUCTURE
-- ========================================

SELECT 'CHECKING VENDORS TABLE' as section;

SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'vendors' 
ORDER BY ordinal_position;

-- ========================================
-- 3. CHECK PROJECTS TABLE STRUCTURE
-- ========================================

SELECT 'CHECKING PROJECTS TABLE' as section;

SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'projects' 
ORDER BY ordinal_position;

-- ========================================
-- 4. CHECK MATERIAL_MASTER TABLE STRUCTURE
-- ========================================

SELECT 'CHECKING MATERIAL_MASTER TABLE' as section;

SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'material_master' 
ORDER BY ordinal_position;

-- ========================================
-- 5. LIST ALL RELEVANT TABLES
-- ========================================

SELECT 'LISTING ALL RELEVANT TABLES' as section;

SELECT table_name
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE'
  AND table_name IN ('purchase_orders', 'purchase_order_items', 'vendors', 'projects', 'material_master', 'suppliers')
ORDER BY table_name;

SELECT 'DATABASE STRUCTURE CHECK COMPLETE' as final_status;