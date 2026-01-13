-- User-Role Organizational Restrictions
-- Allows user-specific organizational field overrides while maintaining role inheritance
-- =====================================================================================

-- 1. Create user_role_restrictions table
CREATE TABLE IF NOT EXISTS user_role_restrictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    auth_object_id UUID NOT NULL REFERENCES authorization_objects(id) ON DELETE CASCADE,
    organizational_restrictions JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, role_id, auth_object_id)
);

-- 2. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_role_restrictions_user ON user_role_restrictions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_role_restrictions_role ON user_role_restrictions(role_id);
CREATE INDEX IF NOT EXISTS idx_user_role_restrictions_object ON user_role_restrictions(auth_object_id);

-- 3. Function to get user effective permissions (role + organizational restrictions)
CREATE OR REPLACE FUNCTION get_user_effective_permissions(input_user_id UUID)
RETURNS TABLE (
    object_name TEXT,
    effective_field_values JSONB,
    has_restrictions BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ao.object_name,
        CASE 
            WHEN urr.organizational_restrictions IS NOT NULL THEN
                -- Apply organizational restrictions to inherited permissions
                rao.field_values || urr.organizational_restrictions
            ELSE
                -- Use role permissions as-is
                rao.field_values
        END as effective_field_values,
        urr.organizational_restrictions IS NOT NULL as has_restrictions
    FROM user_roles ur
    JOIN role_authorization_objects rao ON ur.role_id = rao.role_id
    JOIN authorization_objects ao ON rao.auth_object_id = ao.id
    LEFT JOIN user_role_restrictions urr ON (
        ur.user_id = urr.user_id 
        AND ur.role_id = urr.role_id 
        AND rao.auth_object_id = urr.auth_object_id
    )
    WHERE ur.user_id = input_user_id 
      AND ur.is_active = true
      AND rao.is_active = true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Function to set user organizational restrictions
CREATE OR REPLACE FUNCTION set_user_organizational_restrictions(
    input_user_id UUID,
    input_role_id UUID,
    input_auth_object_id UUID,
    restrictions JSONB
) RETURNS BOOLEAN AS $$
DECLARE
    organizational_fields TEXT[] := ARRAY['COMP_CODE', 'PLANT', 'DEPT', 'BUKRS', 'WERKS', 'EKORG', 'LGORT', 'KOSTL'];
    field_key TEXT;
BEGIN
    -- Validate that only organizational fields are being restricted
    FOR field_key IN SELECT jsonb_object_keys(restrictions)
    LOOP
        IF NOT (field_key = ANY(organizational_fields)) THEN
            RAISE EXCEPTION 'Field % is not an organizational field. Only organizational fields can be restricted.', field_key;
        END IF;
    END LOOP;

    -- Insert or update restrictions
    INSERT INTO user_role_restrictions (user_id, role_id, auth_object_id, organizational_restrictions)
    VALUES (input_user_id, input_role_id, input_auth_object_id, restrictions)
    ON CONFLICT (user_id, role_id, auth_object_id)
    DO UPDATE SET 
        organizational_restrictions = EXCLUDED.organizational_restrictions,
        updated_at = NOW();

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Sample data for the scenario
-- Role: Engineer with full module access
-- User1: Restricted to Company Code C001
-- User2: Restricted to Company Code C002

-- Example usage:
-- SELECT set_user_organizational_restrictions(
--     'user1-uuid',
--     'engineer-role-uuid', 
--     'auth-object-uuid',
--     '{"COMP_CODE": ["C001"], "PLANT": ["P001"]}'::jsonb
-- );

-- SELECT set_user_organizational_restrictions(
--     'user2-uuid',
--     'engineer-role-uuid',
--     'auth-object-uuid', 
--     '{"COMP_CODE": ["C002"], "PLANT": ["P002"]}'::jsonb
-- );