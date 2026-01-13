-- Updated Authorization Check Function for Construction Framework
-- ===========================================================

-- Drop old function and create new one for construction actions
DROP FUNCTION IF EXISTS check_sap_authorization(UUID, VARCHAR(10), VARCHAR(2), JSONB);

CREATE OR REPLACE FUNCTION check_construction_authorization(
    p_user_id UUID,
    p_object_name VARCHAR(20),
    p_action VARCHAR(20),
    p_field_values JSONB DEFAULT '{}'::jsonb
) RETURNS BOOLEAN AS $$
DECLARE
    auth_record RECORD;
    field_key TEXT;
    field_value TEXT;
    user_values TEXT[];
BEGIN
    -- Get user authorization for the object
    SELECT ua.field_values INTO auth_record
    FROM user_authorizations ua
    JOIN authorization_objects ao ON ua.auth_object_id = ao.id
    WHERE ua.user_id = p_user_id 
      AND ao.object_name = p_object_name
      AND (ua.valid_to IS NULL OR ua.valid_to >= CURRENT_DATE)
      AND ua.valid_from <= CURRENT_DATE;
    
    -- If no authorization found, deny access
    IF auth_record IS NULL THEN
        RETURN false;
    END IF;
    
    -- Check ACTION field (construction actions)
    user_values := ARRAY(SELECT jsonb_array_elements_text(auth_record.field_values->'ACTION'));
    IF NOT (p_action = ANY(user_values)) THEN
        RETURN false;
    END IF;
    
    -- Check additional field values if provided
    FOR field_key, field_value IN SELECT * FROM jsonb_each_text(p_field_values) LOOP
        user_values := ARRAY(SELECT jsonb_array_elements_text(auth_record.field_values->field_key));
        IF user_values IS NULL OR NOT (field_value = ANY(user_values)) THEN
            RETURN false;
        END IF;
    END LOOP;
    
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create helper function to get user's module access
CREATE OR REPLACE FUNCTION get_user_module_access(p_user_id UUID)
RETURNS TABLE (
    module_code VARCHAR(2),
    module_name VARCHAR(50),
    auth_objects TEXT[],
    actions TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        LEFT(ao.object_name, 2) as module_code,
        CASE LEFT(ao.object_name, 2)
            WHEN 'PS' THEN 'Project System'
            WHEN 'MM' THEN 'Materials Management'
            WHEN 'PP' THEN 'Production Planning'
            WHEN 'QM' THEN 'Quality Management'
            WHEN 'FI' THEN 'Financial Accounting'
            WHEN 'CO' THEN 'Controlling'
            WHEN 'HR' THEN 'Human Resources'
            WHEN 'WM' THEN 'Warehouse Management'
            ELSE 'Other'
        END as module_name,
        ARRAY_AGG(DISTINCT ao.object_name) as auth_objects,
        ARRAY_AGG(DISTINCT action_val) as actions
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