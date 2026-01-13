-- Fix get_user_module_access function type mismatch
-- =================================================

DROP FUNCTION IF EXISTS get_user_module_access(UUID);

CREATE OR REPLACE FUNCTION get_user_module_access(p_user_id UUID)
RETURNS TABLE (
    module_code TEXT,
    module_name TEXT,
    auth_objects TEXT[],
    actions TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        LEFT(ao.object_name, 2)::TEXT as module_code,
        CASE LEFT(ao.object_name, 2)
            WHEN 'PS' THEN 'Project System'::TEXT
            WHEN 'MM' THEN 'Materials Management'::TEXT
            WHEN 'PP' THEN 'Production Planning'::TEXT
            WHEN 'QM' THEN 'Quality Management'::TEXT
            WHEN 'FI' THEN 'Financial Accounting'::TEXT
            WHEN 'CO' THEN 'Controlling'::TEXT
            WHEN 'HR' THEN 'Human Resources'::TEXT
            WHEN 'WM' THEN 'Warehouse Management'::TEXT
            ELSE 'Other'::TEXT
        END as module_name,
        ARRAY_AGG(DISTINCT ao.object_name::TEXT) as auth_objects,
        ARRAY_AGG(DISTINCT action_val::TEXT) as actions
    FROM user_authorizations ua
    JOIN authorization_objects ao ON ua.auth_object_id = ao.id
    CROSS JOIN LATERAL jsonb_array_elements_text(ua.field_values->'ACTION') as action_val
    WHERE ua.user_id = p_user_id
      AND (ua.valid_to IS NULL OR ua.valid_to >= CURRENT_DATE)
      AND ua.valid_from <= CURRENT_DATE
    GROUP BY LEFT(ao.object_name, 2)
    ORDER BY module_code;
END;
$$ LANGUAGE plpgsql;