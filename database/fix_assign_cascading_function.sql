-- ============================================================================
-- Fix assign_cascading_authorization Function
-- ============================================================================
-- Update the function to use authorization_object_fields instead of authorization_fields
-- ============================================================================

-- Drop the old function
DROP FUNCTION IF EXISTS assign_cascading_authorization(uuid, text, uuid, text, text);

-- Recreate with correct table name
CREATE OR REPLACE FUNCTION assign_cascading_authorization(
  target_role_id uuid,
  target_module text DEFAULT NULL,
  target_object_id uuid DEFAULT NULL,
  access_level text DEFAULT 'full_access',
  cascade_level text DEFAULT 'object'
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_tenant_id uuid;
  v_object_ids uuid[];
  v_field_values jsonb;
  v_count integer := 0;
  v_module_full_access boolean := false;
  v_object_full_access boolean := false;
BEGIN
  -- Get tenant_id from role
  SELECT tenant_id INTO v_tenant_id
  FROM roles
  WHERE id = target_role_id;

  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'Role not found';
  END IF;

  -- Set access flags based on cascade level
  IF cascade_level = 'module' THEN
    v_module_full_access := true;
    v_object_full_access := false;
  ELSIF cascade_level = 'object' THEN
    v_module_full_access := false;
    v_object_full_access := true;
  END IF;

  -- Set field values based on access level
  IF access_level = 'full_access' THEN
    v_field_values := '{"ACTVT": ["*"], "COMP_CODE": ["*"], "PLANT": ["*"], "DEPT": ["*"]}'::jsonb;
  ELSE
    v_field_values := '{"ACTVT": ["03"], "COMP_CODE": ["*"], "PLANT": ["*"], "DEPT": ["*"]}'::jsonb;
  END IF;

  -- Get object IDs based on target
  IF target_object_id IS NOT NULL THEN
    v_object_ids := ARRAY[target_object_id];
  ELSIF target_module IS NOT NULL THEN
    SELECT ARRAY_AGG(id) INTO v_object_ids
    FROM authorization_objects
    WHERE module = target_module
      AND tenant_id = v_tenant_id
      AND is_active = true;
  ELSE
    RAISE EXCEPTION 'Either target_module or target_object_id must be provided';
  END IF;

  -- Insert or update role authorization objects
  INSERT INTO role_authorization_objects (
    role_id,
    auth_object_id,
    field_values,
    module_full_access,
    object_full_access,
    tenant_id,
    is_active
  )
  SELECT
    target_role_id,
    unnest(v_object_ids),
    v_field_values,
    v_module_full_access,
    v_object_full_access,
    v_tenant_id,
    true
  ON CONFLICT (role_id, auth_object_id)
  DO UPDATE SET
    field_values = EXCLUDED.field_values,
    module_full_access = EXCLUDED.module_full_access,
    object_full_access = EXCLUDED.object_full_access,
    is_active = true,
    updated_at = NOW();

  GET DIAGNOSTICS v_count = ROW_COUNT;
  
  RETURN v_count;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION assign_cascading_authorization(uuid, text, uuid, text, text) TO authenticated;
