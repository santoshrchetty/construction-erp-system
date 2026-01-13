-- Step 4 Test Script - Enhanced Tile System
-- ==========================================

-- Test user authorization assignment first
DO $$
DECLARE
    test_user_id UUID := '00000000-0000-0000-0000-000000000001';
BEGIN
    -- Assign Admin role to test user
    PERFORM assign_role_authorizations(test_user_id, 'Admin');
    RAISE NOTICE 'Admin role assigned for tile testing';
END $$;

-- Verify tiles were created by module
SELECT 
    module_code,
    COUNT(*) as tile_count
FROM tiles 
WHERE is_active = true
GROUP BY module_code
ORDER BY module_code;

-- Test authorized tiles function
SELECT 
    title,
    module_code,
    tile_category,
    construction_action,
    has_authorization
FROM get_user_authorized_tiles('00000000-0000-0000-0000-000000000001'::UUID)
WHERE has_authorization = true
ORDER BY module_code, title
LIMIT 15;

-- Show tile categories
SELECT 
    category_name,
    module_code,
    description,
    (SELECT COUNT(*) FROM tiles WHERE tile_category = tc.category_name) as tile_count
FROM tile_categories tc
ORDER BY sequence_order;

-- Test tiles by construction action
SELECT 
    construction_action,
    COUNT(*) as tile_count
FROM tiles
WHERE is_active = true
GROUP BY construction_action
ORDER BY construction_action;

-- Show sample authorized tiles with details
SELECT 
    t.title,
    t.subtitle,
    t.module_code,
    t.construction_action,
    t.tile_category,
    t.auth_object,
    CASE 
        WHEN t.auth_object IS NOT NULL THEN
            check_construction_authorization(
                '00000000-0000-0000-0000-000000000001'::UUID,
                t.auth_object,
                t.construction_action,
                '{}'::jsonb
            )
        ELSE true
    END as user_has_access
FROM tiles t
WHERE t.is_active = true
ORDER BY t.module_code, t.title
LIMIT 20;

-- Verify tile-authorization integration
SELECT 
    'Total tiles created' as metric,
    COUNT(*)::TEXT as value
FROM tiles
UNION ALL
SELECT 
    'Tiles with authorization objects' as metric,
    COUNT(*)::TEXT as value
FROM tiles 
WHERE auth_object IS NOT NULL
UNION ALL
SELECT 
    'Tile categories created' as metric,
    COUNT(*)::TEXT as value
FROM tile_categories
UNION ALL
SELECT 
    'Modules covered' as metric,
    COUNT(DISTINCT module_code)::TEXT as value
FROM tiles;