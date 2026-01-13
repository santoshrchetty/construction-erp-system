-- FIX NULL CATEGORY AND FINAL CLEANUP
-- Address the Budget Approvals tile with null category

-- ========================================
-- 1. FIX NULL CATEGORY TILE
-- ========================================

-- Update Budget Approvals tile to proper category
UPDATE tiles 
SET tile_category = 'Finance'
WHERE title = 'Budget Approvals' AND tile_category IS NULL;

-- ========================================
-- 2. CHECK FOR POTENTIAL DUPLICATES AFTER FIX
-- ========================================

-- Check if Budget Approvals now creates duplicates in Finance category
SELECT 
  title,
  tile_category,
  COUNT(*) as count,
  STRING_AGG(construction_action, ', ') as actions
FROM tiles 
WHERE title = 'Budget Approvals'
GROUP BY title, tile_category;

-- ========================================
-- 3. FINAL VERIFICATION
-- ========================================

-- Verify no null categories remain
SELECT COUNT(*) as null_category_count
FROM tiles 
WHERE tile_category IS NULL;

-- Final tile count by category
SELECT 
  tile_category,
  COUNT(*) as tile_count
FROM tiles 
GROUP BY tile_category
ORDER BY tile_category;