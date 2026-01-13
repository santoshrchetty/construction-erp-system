-- Fix potential limit issue in get_user_authorized_tiles function
-- ==============================================================

-- Recreate function without any potential limits
CREATE OR REPLACE FUNCTION get_user_authorized_tiles(p_user_id UUID)
RETURNS TABLE (
    tile_id UUID,
    title VARCHAR(100),
    subtitle VARCHAR(200),
    icon VARCHAR(50),
    color VARCHAR(20),
    route VARCHAR(200),
    module_code VARCHAR(2),
    tile_category VARCHAR(50),
    construction_action VARCHAR(20),
    has_authorization BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id::UUID,
        t.title::VARCHAR(100),
        t.subtitle::VARCHAR(200),
        t.icon::VARCHAR(50),
        t.color::VARCHAR(20),
        t.route::VARCHAR(200),
        t.module_code::VARCHAR(2),
        t.tile_category::VARCHAR(50),
        t.construction_action::VARCHAR(20),
        CASE 
            WHEN t.auth_object IS NOT NULL THEN
                check_construction_authorization(
                    p_user_id,
                    t.auth_object,
                    t.construction_action,
                    '{}'::jsonb
                )
            ELSE true
        END::BOOLEAN as has_authorization
    FROM tiles t
    WHERE t.is_active = true
    ORDER BY t.sequence_order, t.module_code;
END;
$$ LANGUAGE plpgsql;

-- Test the function returns all 43 tiles
SELECT 'TOTAL TILES FROM FUNCTION' as status, COUNT(*) as count
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f');

-- Test specific categories that were missing
SELECT 'ADMINISTRATION TILES' as status, COUNT(*) as count
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f')
WHERE tile_category = 'Administration';

SELECT 'MATERIALS TILES' as status, COUNT(*) as count
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f')
WHERE tile_category = 'Materials';