-- Clean up duplicate admin tiles and verify access
-- ================================================

-- Remove duplicate tiles (keep only one of each)
DELETE FROM tiles a
USING tiles b
WHERE a.tile_category = 'Administration' 
AND b.tile_category = 'Administration'
AND a.title = b.title 
AND a.created_at > b.created_at;

-- Verify clean tiles
SELECT 'CLEANED ADMIN TILES' as status, title, tile_category, auth_object, construction_action
FROM tiles 
WHERE tile_category = 'Administration'
ORDER BY sequence_order;

-- Check admin user authorizations
SELECT 'ADMIN AUTHORIZATIONS' as status, auth_object_name, field_values
FROM user_authorizations 
WHERE user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f'
AND auth_object_name LIKE 'SY_%'
ORDER BY auth_object_name;

-- Test authorization function for admin tiles
SELECT 
    'ADMIN TILE ACCESS' as status,
    t.title,
    check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) as has_access
FROM tiles t
WHERE t.tile_category = 'Administration'
ORDER BY t.sequence_order;