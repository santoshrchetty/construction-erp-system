-- CHECK AND REMOVE DUPLICATE TILES IN SAME CATEGORY
-- Identifies duplicates by title and tile_category, keeps the latest one

-- ========================================
-- 1. IDENTIFY DUPLICATE TILES
-- ========================================

-- Check for duplicate titles in same category
SELECT 
  title,
  tile_category,
  COUNT(*) as duplicate_count,
  STRING_AGG(construction_action, ', ') as actions,
  STRING_AGG(id::text, ', ') as tile_ids
FROM tiles 
GROUP BY title, tile_category
HAVING COUNT(*) > 1
ORDER BY tile_category, title;

-- Check for duplicate construction_actions (should be unique)
SELECT 
  construction_action,
  COUNT(*) as duplicate_count,
  STRING_AGG(title, ', ') as titles,
  STRING_AGG(tile_category, ', ') as categories
FROM tiles 
GROUP BY construction_action
HAVING COUNT(*) > 1
ORDER BY construction_action;

-- ========================================
-- 2. REMOVE DUPLICATE CONSTRUCTION_ACTIONS FIRST
-- ========================================

-- Remove duplicate construction_actions, keep the one with highest ID
DELETE FROM tiles 
WHERE id NOT IN (
  SELECT MAX(id::text)::uuid
  FROM tiles 
  GROUP BY construction_action
);

-- ========================================
-- 3. REMOVE DUPLICATE TILES BY TITLE/CATEGORY
-- ========================================

-- Remove duplicate tiles by title and category, keep the one with highest ID (latest)
DELETE FROM tiles 
WHERE id NOT IN (
  SELECT MAX(id::text)::uuid
  FROM tiles 
  GROUP BY title, tile_category
);

-- ========================================
-- 4. ENSURE CONSTRUCTION_ACTION UNIQUENESS
-- ========================================

-- Add unique constraint to prevent future duplicates
ALTER TABLE tiles ADD CONSTRAINT unique_construction_action UNIQUE (construction_action);

-- ========================================
-- 5. VERIFICATION AFTER CLEANUP
-- ========================================

-- Verify no duplicates remain
SELECT 'DUPLICATE CHECK AFTER CLEANUP' as check_type;

SELECT 
  title,
  tile_category,
  COUNT(*) as count
FROM tiles 
GROUP BY title, tile_category
HAVING COUNT(*) > 1;

-- Should return no rows if cleanup successful

-- ========================================
-- 6. FINAL TILE COUNT BY CATEGORY
-- ========================================

SELECT 
  tile_category,
  COUNT(*) as tile_count,
  STRING_AGG(title, ', ') as tiles
FROM tiles 
GROUP BY tile_category
ORDER BY tile_category;