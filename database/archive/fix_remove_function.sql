-- Function to remove module assignments
CREATE OR REPLACE FUNCTION remove_module_assignments(
    target_role_id UUID,
    target_module TEXT
) RETURNS INTEGER AS $$
DECLARE
    objects_removed INTEGER := 0;
BEGIN
    DELETE FROM role_authorization_objects 
    WHERE role_id = target_role_id 
    AND auth_object_id IN (
        SELECT id FROM authorization_objects WHERE module = target_module
    );
    
    GET DIAGNOSTICS objects_removed = ROW_COUNT;
    RETURN objects_removed;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;