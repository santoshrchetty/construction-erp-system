-- Fix authorization function with correct table structure
-- ======================================================

-- Drop and recreate the authorization function with correct logic
DROP FUNCTION IF EXISTS check_construction_authorization(uuid,character varying,character varying,jsonb);

CREATE OR REPLACE FUNCTION check_construction_authorization(
    p_user_id UUID,
    p_auth_object VARCHAR(20),
    p_action VARCHAR(20),
    p_context JSONB DEFAULT '{}'
) RETURNS BOOLEAN AS $$
DECLARE
    v_has_auth BOOLEAN := false;
    v_auth_record RECORD;
BEGIN
    -- Check user authorizations by joining with authorization_objects
    SELECT ua.field_values INTO v_auth_record
    FROM user_authorizations ua
    JOIN authorization_objects ao ON ua.auth_object_id = ao.id
    WHERE ua.user_id = p_user_id 
    AND ao.object_name = p_auth_object
    AND (ua.valid_to IS NULL OR ua.valid_to > CURRENT_DATE);
    
    IF FOUND THEN
        -- Check if user has the required action
        IF v_auth_record.field_values ? 'ACTION' THEN
            SELECT p_action = ANY(
                SELECT jsonb_array_elements_text(v_auth_record.field_values->'ACTION')
            ) INTO v_has_auth;
        END IF;
    END IF;
    
    RETURN COALESCE(v_has_auth, false);
END;
$$ LANGUAGE plpgsql;

-- Test the fixed function with admin tiles
SELECT 
    'ADMIN TILE ACCESS TEST' as status,
    t.title,
    t.auth_object,
    t.construction_action,
    check_construction_authorization(
        '70f8baa8-27b8-4061-84c4-6dd027d6b89f',
        t.auth_object,
        t.construction_action,
        '{}'::jsonb
    ) as has_access
FROM tiles t
WHERE t.tile_category = 'Administration'
ORDER BY t.title;