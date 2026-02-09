-- ============================================================================
-- Find Tiles Without Matching Authorization Objects
-- ============================================================================
-- Identifies tiles that don't have corresponding authorization objects
-- ============================================================================

-- Find tiles with auth_object that don't match any authorization object
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

-- Find tiles without auth_object set
SELECT 
  t.id,
  t.title,
  t.module_code,
  t.auth_object,
  'auth_object is NULL' as issue
FROM tiles t
WHERE t.auth_object IS NULL
  AND t.is_active = true
ORDER BY t.module_code, t.title;

-- Count tiles by module and auth_object status
SELECT 
  t.module_code,
  COUNT(*) as total_tiles,
  COUNT(t.auth_object) as tiles_with_auth_object,
  COUNT(*) - COUNT(t.auth_object) as tiles_without_auth_object
FROM tiles t
WHERE t.is_active = true
GROUP BY t.module_code
ORDER BY t.module_code;
