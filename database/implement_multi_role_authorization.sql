-- Multi-Role Authorization Schema Implementation
-- =============================================

-- 1. Create user_roles table for multi-role support
CREATE TABLE IF NOT EXISTS user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, role_id)
);

-- 2. Migrate existing single role data to multi-role
INSERT INTO user_roles (user_id, role_id)
SELECT id, role_id 
FROM users 
WHERE role_id IS NOT NULL
ON CONFLICT (user_id, role_id) DO NOTHING;

-- 3. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_roles_user ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON user_roles(role_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_active ON user_roles(is_active);

-- 4. Function to get combined user permissions from all roles
CREATE OR REPLACE FUNCTION get_user_combined_permissions(input_user_id UUID)
RETURNS TABLE (
    object_name TEXT,
    combined_field_values JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ao.object_name,
        jsonb_object_agg(
            field_key, 
            jsonb_agg(DISTINCT field_value ORDER BY field_value)
        ) as combined_field_values
    FROM user_roles ur
    JOIN role_authorization_objects rao ON ur.role_id = rao.role_id
    JOIN authorization_objects ao ON rao.auth_object_id = ao.id,
    LATERAL jsonb_each(rao.field_values) AS field_entry(field_key, field_values),
    LATERAL jsonb_array_elements_text(field_values) AS field_value
    WHERE ur.user_id = input_user_id 
      AND ur.is_active = true
      AND rao.is_active = true
    GROUP BY ao.object_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Enhanced role_authorization_objects table with cascading support
ALTER TABLE role_authorization_objects 
ADD COLUMN IF NOT EXISTS module_full_access BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS object_full_access BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS inherited_from TEXT CHECK (inherited_from IN ('module', 'object'));

-- 6. Function for cascading authorization assignment
CREATE OR REPLACE FUNCTION assign_cascading_authorization(
    target_role_id UUID,
    target_module TEXT DEFAULT NULL,
    target_object_id UUID DEFAULT NULL,
    access_level TEXT DEFAULT 'full_access',
    cascade_level TEXT DEFAULT 'field' -- 'module', 'object', 'field'
) RETURNS INTEGER AS $$
DECLARE
    field_values_template JSONB;
    objects_assigned INTEGER := 0;
    module_full_access BOOLEAN := FALSE;
    object_full_access BOOLEAN := FALSE;
    obj_record RECORD;
    field_record RECORD;
    dynamic_field_values JSONB;
    field_count INTEGER;
BEGIN
    -- Set cascading flags based on level
    CASE cascade_level
        WHEN 'module' THEN
            module_full_access := TRUE;
            object_full_access := TRUE;
        WHEN 'object' THEN
            object_full_access := TRUE;
        ELSE
            -- Field level - no cascading
    END CASE;

    -- Insert/Update assignments based on scope
    IF target_module IS NOT NULL AND target_object_id IS NULL THEN
        -- Module-level assignment with dynamic field population
        FOR obj_record IN 
            SELECT id FROM authorization_objects WHERE module = target_module
        LOOP
            -- Build dynamic field values for this specific object
            dynamic_field_values := '{}'::jsonb;
            field_count := 0;
            
            -- Get all fields for this object
            FOR field_record IN 
                SELECT field_name FROM authorization_fields WHERE auth_object_id = obj_record.id
            LOOP
                field_count := field_count + 1;
                CASE access_level
                    WHEN 'full_access' THEN
                        dynamic_field_values := dynamic_field_values || jsonb_build_object(field_record.field_name, '["*"]'::jsonb);
                    WHEN 'read_only' THEN
                        dynamic_field_values := dynamic_field_values || jsonb_build_object(field_record.field_name, '["REVIEW"]'::jsonb);
                    ELSE
                        dynamic_field_values := dynamic_field_values || jsonb_build_object(field_record.field_name, '["LIMITED"]'::jsonb);
                END CASE;
            END LOOP;
            
            -- If no fields found, use default organizational fields
            IF field_count = 0 THEN
                CASE access_level
                    WHEN 'full_access' THEN
                        dynamic_field_values := '{"COMP_CODE": ["*"], "PLANT": ["*"], "DEPT": ["*"], "ACTVT": ["*"]}'::jsonb;
                    WHEN 'read_only' THEN
                        dynamic_field_values := '{"COMP_CODE": ["*"], "PLANT": ["*"], "DEPT": ["*"], "ACTVT": ["03"]}'::jsonb;
                    ELSE
                        dynamic_field_values := '{"COMP_CODE": ["1000"], "PLANT": ["P001"], "DEPT": ["ADMIN"], "ACTVT": ["03"]}'::jsonb;
                END CASE;
            END IF;
            
            -- Insert/Update with dynamic field values
            INSERT INTO role_authorization_objects (role_id, auth_object_id, field_values, module_full_access, object_full_access, inherited_from)
            VALUES (
                target_role_id,
                obj_record.id,
                dynamic_field_values,
                module_full_access,
                object_full_access,
                CASE WHEN cascade_level = 'module' THEN 'module' ELSE NULL END
            )
            ON CONFLICT (role_id, auth_object_id) 
            DO UPDATE SET 
                field_values = EXCLUDED.field_values,
                module_full_access = EXCLUDED.module_full_access,
                object_full_access = EXCLUDED.object_full_access,
                inherited_from = EXCLUDED.inherited_from;
                
            objects_assigned := objects_assigned + 1;
        END LOOP;
        
    ELSIF target_object_id IS NOT NULL THEN
        -- Object-level assignment with dynamic field population
        dynamic_field_values := '{}'::jsonb;
        field_count := 0;
        
        FOR field_record IN 
            SELECT field_name FROM authorization_fields WHERE auth_object_id = target_object_id
        LOOP
            field_count := field_count + 1;
            CASE access_level
                WHEN 'full_access' THEN
                    dynamic_field_values := dynamic_field_values || jsonb_build_object(field_record.field_name, '["*"]'::jsonb);
                WHEN 'read_only' THEN
                    dynamic_field_values := dynamic_field_values || jsonb_build_object(field_record.field_name, '["REVIEW"]'::jsonb);
                ELSE
                    dynamic_field_values := dynamic_field_values || jsonb_build_object(field_record.field_name, '["LIMITED"]'::jsonb);
            END CASE;
        END LOOP;
        
        -- If no fields found, use default organizational fields
        IF field_count = 0 THEN
            CASE access_level
                WHEN 'full_access' THEN
                    dynamic_field_values := '{"COMP_CODE": ["*"], "PLANT": ["*"], "DEPT": ["*"], "ACTVT": ["*"]}'::jsonb;
                WHEN 'read_only' THEN
                    dynamic_field_values := '{"COMP_CODE": ["*"], "PLANT": ["*"], "DEPT": ["*"], "ACTVT": ["03"]}'::jsonb;
                ELSE
                    dynamic_field_values := '{"COMP_CODE": ["1000"], "PLANT": ["P001"], "DEPT": ["ADMIN"], "ACTVT": ["03"]}'::jsonb;
            END CASE;
        END IF;
        
        INSERT INTO role_authorization_objects (role_id, auth_object_id, field_values, object_full_access, inherited_from)
        VALUES (
            target_role_id,
            target_object_id,
            dynamic_field_values,
            object_full_access,
            CASE WHEN cascade_level = 'object' THEN 'object' ELSE NULL END
        )
        ON CONFLICT (role_id, auth_object_id) 
        DO UPDATE SET 
            field_values = EXCLUDED.field_values,
            object_full_access = EXCLUDED.object_full_access,
            inherited_from = EXCLUDED.inherited_from;
            
        objects_assigned := 1;
        
    ELSE
        -- All objects assignment with static template
        CASE access_level
            WHEN 'full_access' THEN
                field_values_template := '{"COMP_CODE": ["*"], "PLANT": ["*"], "DEPT": ["*"], "ACTVT": ["*"]}'::jsonb;
            WHEN 'read_only' THEN
                field_values_template := '{"COMP_CODE": ["*"], "PLANT": ["*"], "DEPT": ["*"], "ACTVT": ["03"]}'::jsonb;
            ELSE
                field_values_template := '{"COMP_CODE": ["1000"], "PLANT": ["P001"], "DEPT": ["ADMIN"], "ACTVT": ["03"]}'::jsonb;
        END CASE;
        
        INSERT INTO role_authorization_objects (role_id, auth_object_id, field_values, module_full_access, object_full_access)
        SELECT 
            target_role_id,
            ao.id,
            field_values_template,
            module_full_access,
            object_full_access
        FROM authorization_objects ao
        ON CONFLICT (role_id, auth_object_id) 
        DO UPDATE SET 
            field_values = EXCLUDED.field_values,
            module_full_access = EXCLUDED.module_full_access,
            object_full_access = EXCLUDED.object_full_access;
            
        GET DIAGNOSTICS objects_assigned = ROW_COUNT;
    END IF;

    RETURN objects_assigned;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Function to remove module assignments
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

-- 8. Function for bulk role assignment (backward compatibility)
CREATE OR REPLACE FUNCTION assign_all_objects_to_role(
    target_role_id UUID,
    template_type TEXT DEFAULT 'full_access'
) RETURNS INTEGER AS $$
BEGIN
    RETURN assign_cascading_authorization(target_role_id, NULL, NULL, template_type, 'field');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Function to check user authorization with multi-role support
CREATE OR REPLACE FUNCTION check_user_multi_role_authorization(
    input_user_id UUID,
    auth_object TEXT,
    check_fields JSONB
) RETURNS BOOLEAN AS $$
DECLARE
    user_permissions RECORD;
    field_key TEXT;
    field_values TEXT[];
    check_value TEXT;
BEGIN
    -- Get combined permissions for this object
    SELECT combined_field_values INTO user_permissions
    FROM get_user_combined_permissions(input_user_id) 
    WHERE object_name = auth_object;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Check each required field
    FOR field_key IN SELECT jsonb_object_keys(check_fields)
    LOOP
        -- Get authorized values for this field
        SELECT ARRAY(SELECT jsonb_array_elements_text(user_permissions.combined_field_values->field_key)) INTO field_values;
        
        -- Get value to check
        SELECT jsonb_extract_path_text(check_fields, field_key) INTO check_value;
        
        -- Check if authorized (wildcard * allows all)
        IF NOT ('*' = ANY(field_values) OR check_value = ANY(field_values)) THEN
            RETURN FALSE;
        END IF;
    END LOOP;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
values, module_full_access, object_full_access)
        SELECT 
            target_role_id,
            ao.id,
            field_values_template,
            module_full_access,
            object_full_access
        FROM authorization_objects ao
        ON CONFLICT (role_id, auth_object_id) 
        DO UPDATE SET 
            field_values = EXCLUDED.field_values,
            module_full_access = EXCLUDED.module_full_access,
            object_full_access = EXCLUDED.object_full_access;
            
        GET DIAGNOSTICS objects_assigned = ROW_COUNT;
    END IF;

    RETURN objects_assigned;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Function to remove module assignments (for unchecking)
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