-- Check and Fix Approval Configuration Tile Routing
-- This ensures the tile points to the correct route

-- Check current tile configuration
SELECT 
    title,
    route,
    is_active,
    created_at
FROM tiles 
WHERE title ILIKE '%approval%config%' 
   OR route ILIKE '%approval%config%'
ORDER BY created_at DESC;

-- Update tile to point to correct route
UPDATE tiles 
SET 
    route = '/approval-configuration',
    updated_at = NOW()
WHERE title = 'Approval Configuration'
  AND is_active = true;

-- Ensure only one active approval configuration tile
UPDATE tiles 
SET is_active = false 
WHERE (title ILIKE '%approval%config%' OR route ILIKE '%approval%config%')
  AND title != 'Approval Configuration';

-- Verify the fix
SELECT 
    'Fixed tile routing' as status,
    title,
    route,
    is_active
FROM tiles 
WHERE title = 'Approval Configuration'
  AND is_active = true;