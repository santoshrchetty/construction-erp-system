-- ============================================================================
-- Create Missing Authorization Objects for All Tiles
-- ============================================================================
-- This creates authorization objects for all tiles that reference them
-- ============================================================================

-- Insert missing authorization objects based on tiles
INSERT INTO authorization_objects (object_name, description, module, is_active, tenant_id)
SELECT DISTINCT
  t.auth_object as object_name,
  t.title as description,
  t.module_code as module,
  true as is_active,
  '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid as tenant_id
FROM tiles t
WHERE t.auth_object IS NOT NULL
  AND t.is_active = true
  AND NOT EXISTS (
    SELECT 1 
    FROM authorization_objects ao 
    WHERE ao.object_name = t.auth_object
  );

-- Verify all tiles now have matching authorization objects
SELECT 
  COUNT(*) as tiles_without_auth_objects
FROM tiles t
WHERE t.auth_object IS NOT NULL
  AND t.is_active = true
  AND NOT EXISTS (
    SELECT 1 
    FROM authorization_objects ao 
    WHERE ao.object_name = t.auth_object
  );
-- Expected: 0

-- Show newly created authorization objects by module
SELECT 
  module,
  COUNT(*) as object_count
FROM authorization_objects
WHERE is_active = true
GROUP BY module
ORDER BY module;
