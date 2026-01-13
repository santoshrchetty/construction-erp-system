-- Add Admin Management Tiles Only
-- ================================

-- Drop existing function if it exists
DROP FUNCTION IF EXISTS check_construction_authorization(uuid,character varying,character varying,jsonb);

-- Add system administration authorization objects
INSERT INTO authorization_objects (object_name, description, module) VALUES
('SY_USR_MANAGE', 'User Management Authorization', 'system'),
('SY_ROL_MANAGE', 'Role Management Authorization', 'system'),
('SY_USR_ASSIGN', 'User Role Assignment Authorization', 'system')
ON CONFLICT (object_name) DO NOTHING;

-- Add authorization fields for system objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'ACTION', 'System Action', ARRAY['CREATE', 'MODIFY', 'DELETE', 'ASSIGN']
FROM authorization_objects ao
WHERE ao.object_name IN ('SY_USR_MANAGE', 'SY_ROL_MANAGE', 'SY_USR_ASSIGN')
AND NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'ACTION'
);

-- Add Admin role mappings for system administration
INSERT INTO role_authorization_mapping (role_name, auth_object_name, field_values) VALUES
('Admin', 'SY_USR_MANAGE', '{"ACTION": ["CREATE", "MODIFY", "DELETE"]}'::jsonb),
('Admin', 'SY_ROL_MANAGE', '{"ACTION": ["CREATE", "MODIFY", "DELETE"]}'::jsonb),
('Admin', 'SY_USR_ASSIGN', '{"ACTION": ["ASSIGN", "MODIFY"]}'::jsonb)
ON CONFLICT (role_name, auth_object_name) DO NOTHING;

-- Add Administration tiles
INSERT INTO tiles (title, subtitle, icon, color, route, roles, sequence_order, auth_object, construction_action, module_code, tile_category) VALUES
('User Management', 'Create, modify, and manage users', 'users', 'bg-blue-600', '#', '{admin}', 90, 'SY_USR_MANAGE', 'MODIFY', 'SY', 'Administration'),
('Role Management', 'Create roles and assign authorization objects', 'shield', 'bg-purple-600', '#', '{admin}', 91, 'SY_ROL_MANAGE', 'MODIFY', 'SY', 'Administration'),
('User Role Assignment', 'Assign users to roles', 'user-check', 'bg-green-600', '#', '{admin}', 92, 'SY_USR_ASSIGN', 'MODIFY', 'SY', 'Administration')
ON CONFLICT DO NOTHING;

-- Recreate the authorization function with correct parameters
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
    -- Check user authorizations
    SELECT ua.field_values INTO v_auth_record
    FROM user_authorizations ua
    WHERE ua.user_id = p_user_id 
    AND ua.auth_object_name = p_auth_object
    AND ua.is_active = true
    AND (ua.expires_at IS NULL OR ua.expires_at > NOW());
    
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

-- Reassign Admin role to get new authorizations
DO $$
BEGIN
    PERFORM assign_role_authorizations('70f8baa8-27b8-4061-84c4-6dd027d6b89f', 'Admin');
    RAISE NOTICE 'Admin role updated with administration authorizations';
END $$;

-- Verify the admin tiles were added
SELECT 'ADMIN TILES ADDED' as status, title, tile_category 
FROM tiles 
WHERE tile_category = 'Administration'
ORDER BY sequence_order;