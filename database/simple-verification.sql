-- SIMPLE VERIFICATION - CHECK WHAT EXISTS
-- Check actual table structure and data

-- ========================================
-- 1. CHECK TILES TABLE STRUCTURE
-- ========================================

SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'tiles' 
ORDER BY ordinal_position;

-- ========================================
-- 2. VERIFY NEW COMPONENT TILES
-- ========================================

SELECT 
  title,
  construction_action,
  tile_category
FROM tiles 
WHERE construction_action IN ('supplier-master', 'period-controls', 'WBSManagement')
ORDER BY title;

-- ========================================
-- 3. CHECK FOR NULL CATEGORIES
-- ========================================

SELECT COUNT(*) as null_category_count FROM tiles WHERE tile_category IS NULL;

-- ========================================
-- 4. FINAL TILE COUNT
-- ========================================

SELECT 
  tile_category,
  COUNT(*) as tile_count
FROM tiles 
GROUP BY tile_category
ORDER BY tile_category;

SELECT 'BASIC VERIFICATION COMPLETE' as status;