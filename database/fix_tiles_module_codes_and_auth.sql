-- ============================================================================
-- Fix Tiles with Mismatched Auth Objects and Module Codes
-- ============================================================================

-- Step 1: Find tiles with auth_object that don't match any authorization object
SELECT 
  t.id,
  t.title,
  t.module_code,
  t.auth_object as tile_auth_object,
  'No matching authorization object' as issue
FROM tiles t
WHERE t.auth_object IS NOT NULL
  AND t.is_active = true
  AND NOT EXISTS (
    SELECT 1 
    FROM authorization_objects ao 
    WHERE ao.object_name = t.auth_object
  )
ORDER BY t.module_code, t.title;

-- Step 2: Fix old SAP module codes in tiles
UPDATE tiles SET module_code = 'controlling' WHERE module_code = 'CO';
UPDATE tiles SET module_code = 'materials' WHERE module_code = 'MAT';
UPDATE tiles SET module_code = 'production' WHERE module_code = 'PP';
UPDATE tiles SET module_code = 'planning' WHERE module_code = 'PLANNING';

-- Step 3: Show tiles with NULL module_code (need manual review)
SELECT 
  id,
  title,
  subtitle,
  auth_object,
  tile_category
FROM tiles
WHERE module_code IS NULL
  AND is_active = true;

-- Step 4: Verify all tiles now have proper module codes
SELECT 
  module_code,
  COUNT(*) as tile_count
FROM tiles
WHERE is_active = true
GROUP BY module_code
ORDER BY module_code;
