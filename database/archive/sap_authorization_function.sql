-- SAP Authorization Check Function
-- ================================

CREATE OR REPLACE FUNCTION check_sap_authorization(
    p_user_id UUID,
    p_object_name VARCHAR(10),
    p_activity VARCHAR(2),
    p_field_values JSONB DEFAULT '{}'::jsonb
) RETURNS BOOLEAN AS $$
DECLARE
    auth_record RECORD;
    field_record RECORD;
    field_key TEXT;
    field_value TEXT;
    user_values TEXT[];
    has_access BOOLEAN := false;
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
    
    -- Check ACTVT (Activity) field
    user_values := ARRAY(SELECT jsonb_array_elements_text(auth_record.field_values->'ACTVT'));
    IF NOT (p_activity = ANY(user_values)) THEN
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