-- Test and fix get_user_authorized_tiles function
-- ===============================================

-- Test if function exists and works
SELECT 'FUNCTION TEST' as status, COUNT(*) as tile_count
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f');

-- Recreate the function to ensure it works properly
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
        t.id,
        t.title,
        t.subtitle,
        t.icon,
        t.color,
        t.route,
        t.module_code,
        t.tile_category,
        t.construction_action,
        CASE 
            WHEN t.auth_object IS NOT NULL THEN
                check_construction_authorization(
                    p_user_id,
                    t.auth_object,
                    t.construction_action,
                    '{}'::jsonb
                )
            ELSE true
        END as has_authorization
    FROM tiles t
    WHERE t.is_active = true
    ORDER BY t.module_code, t.sequence_order;
END;
$$ LANGUAGE plpgsql;

-- Test the function again
SELECT 'FUNCTION FIXED TEST' as status, COUNT(*) as tile_count
FROM get_user_authorized_tiles('70f8baa8-27b8-4061-84c4-6dd027d6b89f');