-- Authorization Object-Based RLS Policies
-- ==========================================

-- Enhanced RLS function that checks authorization objects
CREATE OR REPLACE FUNCTION check_auth_object_access(
    user_id UUID,
    auth_object TEXT,
    activity TEXT,
    org_data JSONB DEFAULT '{}'::JSONB
) RETURNS BOOLEAN AS $$
DECLARE
    user_role_name TEXT;
    auth_fields JSONB;
    field_key TEXT;
    field_values TEXT[];
    check_value TEXT;
BEGIN
    -- Get user's role
    SELECT r.name INTO user_role_name
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE u.id = user_id;
    
    IF user_role_name IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Admin has full access
    IF user_role_name = 'Admin' THEN
        RETURN TRUE;
    END IF;
    
    -- Get role's authorization for this object
    SELECT rao.field_values INTO auth_fields
    FROM role_authorization_objects rao
    JOIN authorization_objects ao ON rao.auth_object_id = ao.id
    JOIN roles r ON rao.role_id = r.id
    WHERE r.name = user_role_name
      AND ao.object_name = auth_object
      AND rao.is_active = true
      AND ao.is_active = true;
    
    IF auth_fields IS NULL THEN
        RETURN FALSE;
    END IF;
    
    -- Check ACTVT (Activity) field
    SELECT ARRAY(SELECT jsonb_array_elements_text(auth_fields->'ACTVT')) INTO field_values;
    IF NOT ('*' = ANY(field_values) OR activity = ANY(field_values)) THEN
        RETURN FALSE;
    END IF;
    
    -- Check organizational fields from org_data
    FOR field_key IN SELECT jsonb_object_keys(org_data)
    LOOP
        SELECT ARRAY(SELECT jsonb_array_elements_text(auth_fields->field_key)) INTO field_values;
        SELECT jsonb_extract_path_text(org_data, field_key) INTO check_value;
        
        -- Skip if field not in authorization or no value to check
        IF field_values IS NULL OR check_value IS NULL THEN
            CONTINUE;
        END IF;
        
        -- Check if authorized (wildcard * allows all)
        IF NOT ('*' = ANY(field_values) OR check_value = ANY(field_values)) THEN
            RETURN FALSE;
        END IF;
    END LOOP;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Projects Table RLS Policies
DROP POLICY IF EXISTS "projects_select" ON projects;
DROP POLICY IF EXISTS "projects_insert" ON projects;
DROP POLICY IF EXISTS "projects_update" ON projects;
DROP POLICY IF EXISTS "projects_delete" ON projects;

CREATE POLICY "projects_select" ON projects FOR SELECT
USING (
    check_auth_object_access(
        auth.uid(), 
        'F_PROJ_DIS', 
        '03',
        jsonb_build_object('BUKRS', company_code, 'PROJ_TYPE', project_type)
    )
);

CREATE POLICY "projects_insert" ON projects FOR INSERT
WITH CHECK (
    check_auth_object_access(
        auth.uid(), 
        'F_PROJ_CRE', 
        '01',
        jsonb_build_object('BUKRS', company_code, 'PROJ_TYPE', project_type)
    )
);

CREATE POLICY "projects_update" ON projects FOR UPDATE
USING (
    check_auth_object_access(
        auth.uid(), 
        'F_PROJ_CHG', 
        '02',
        jsonb_build_object('BUKRS', company_code, 'PROJ_TYPE', project_type)
    )
);

-- Purchase Orders Table RLS Policies
DROP POLICY IF EXISTS "purchase_orders_select" ON purchase_orders;
DROP POLICY IF EXISTS "purchase_orders_insert" ON purchase_orders;
DROP POLICY IF EXISTS "purchase_orders_update" ON purchase_orders;

CREATE POLICY "purchase_orders_select" ON purchase_orders FOR SELECT
USING (
    check_auth_object_access(
        auth.uid(), 
        'F_PO_DIS', 
        '03',
        jsonb_build_object('BUKRS', company_code, 'EKORG', purchasing_org)
    )
);

CREATE POLICY "purchase_orders_insert" ON purchase_orders FOR INSERT
WITH CHECK (
    check_auth_object_access(
        auth.uid(), 
        'F_PO_CRE', 
        '01',
        jsonb_build_object('BUKRS', company_code, 'EKORG', purchasing_org, 'PO_TYPE', po_type)
    )
);

CREATE POLICY "purchase_orders_update" ON purchase_orders FOR UPDATE
USING (
    CASE 
        WHEN status IN ('submitted', 'pending_approval') THEN
            check_auth_object_access(
                auth.uid(), 
                'F_PO_APP', 
                '05',
                jsonb_build_object('BUKRS', company_code, 'EKORG', purchasing_org, 'PO_VALUE', total_amount::text)
            )
        ELSE
            check_auth_object_access(
                auth.uid(), 
                'F_PO_CHG', 
                '02',
                jsonb_build_object('BUKRS', company_code, 'EKORG', purchasing_org, 'PO_TYPE', po_type)
            )
    END
);

-- Materials Table RLS Policies (assuming materials table exists)
CREATE POLICY "materials_select" ON stock_items FOR SELECT
USING (
    check_auth_object_access(
        auth.uid(), 
        'F_MAT_DIS', 
        '03',
        jsonb_build_object('MAT_TYPE', category)
    )
);

CREATE POLICY "materials_insert" ON stock_items FOR INSERT
WITH CHECK (
    check_auth_object_access(
        auth.uid(), 
        'F_MAT_CRE', 
        '01',
        jsonb_build_object('MAT_TYPE', category)
    )
);

-- Inventory/Stock Movements RLS Policies
DROP POLICY IF EXISTS "stock_movements_select" ON stock_movements;
DROP POLICY IF EXISTS "stock_movements_insert" ON stock_movements;

CREATE POLICY "stock_movements_select" ON stock_movements FOR SELECT
USING (
    check_auth_object_access(
        auth.uid(), 
        'F_INV_DISP', 
        '03',
        jsonb_build_object(
            'BUKRS', (SELECT cc.company_code FROM stores s JOIN company_codes cc ON s.company_code_id = cc.id WHERE s.id = store_id),
            'WERKS', (SELECT p.plant_code FROM stores s JOIN plants p ON s.plant_id = p.id WHERE s.id = store_id)
        )
    )
);

CREATE POLICY "stock_movements_insert" ON stock_movements FOR INSERT
WITH CHECK (
    CASE 
        WHEN movement_type = 'receipt' THEN
            check_auth_object_access(
                auth.uid(), 
                'F_GRN_POST', 
                '01',
                jsonb_build_object(
                    'BUKRS', (SELECT cc.company_code FROM stores s JOIN company_codes cc ON s.company_code_id = cc.id WHERE s.id = store_id),
                    'WERKS', (SELECT p.plant_code FROM stores s JOIN plants p ON s.plant_id = p.id WHERE s.id = store_id)
                )
            )
        ELSE
            check_auth_object_access(
                auth.uid(), 
                'F_INV_POST', 
                '01',
                jsonb_build_object(
                    'BUKRS', (SELECT cc.company_code FROM stores s JOIN company_codes cc ON s.company_code_id = cc.id WHERE s.id = store_id),
                    'WERKS', (SELECT p.plant_code FROM stores s JOIN plants p ON s.plant_id = p.id WHERE s.id = store_id)
                )
            )
    END
);

-- Timesheets RLS Policies
DROP POLICY IF EXISTS "timesheets_select" ON timesheets;
DROP POLICY IF EXISTS "timesheets_insert" ON timesheets;
DROP POLICY IF EXISTS "timesheets_update" ON timesheets;

CREATE POLICY "timesheets_select" ON timesheets FOR SELECT
USING (
    user_id = auth.uid() OR -- Own timesheets
    check_auth_object_access(
        auth.uid(), 
        'F_TIME_DIS', 
        '03',
        jsonb_build_object('BUKRS', company_code)
    )
);

CREATE POLICY "timesheets_insert" ON timesheets FOR INSERT
WITH CHECK (
    user_id = auth.uid() AND -- Own timesheets only
    check_auth_object_access(
        auth.uid(), 
        'F_TIME_CRE', 
        '01',
        jsonb_build_object('BUKRS', company_code)
    )
);

CREATE POLICY "timesheets_update" ON timesheets FOR UPDATE
USING (
    CASE 
        WHEN status = 'submitted' THEN
            check_auth_object_access(
                auth.uid(), 
                'F_TIME_APP', 
                '05',
                jsonb_build_object('BUKRS', company_code)
            )
        WHEN user_id = auth.uid() AND status = 'draft' THEN
            check_auth_object_access(
                auth.uid(), 
                'F_TIME_CRE', 
                '02',
                jsonb_build_object('BUKRS', company_code)
            )
        ELSE FALSE
    END
);

-- GL Postings RLS Policies (assuming gl_postings table exists)
-- CREATE POLICY "gl_postings_insert" ON gl_postings FOR INSERT
-- WITH CHECK (
--     check_auth_object_access(
--         auth.uid(), 
--         'F_GL_POST', 
--         '01',
--         jsonb_build_object('BUKRS', company_code, 'GL_ACCT', account_number)
--     )
-- );

-- Quality Inspections RLS Policies (assuming quality_inspections table exists)
-- CREATE POLICY "quality_inspections_select" ON quality_inspections FOR SELECT
-- USING (
--     check_auth_object_access(
--         auth.uid(), 
--         'F_QM_INSP', 
--         '03',
--         jsonb_build_object('BUKRS', company_code, 'WERKS', plant_code)
--     )
-- );

-- Safety Incidents RLS Policies (assuming safety_incidents table exists)
-- CREATE POLICY "safety_incidents_insert" ON safety_incidents FOR INSERT
-- WITH CHECK (
--     check_auth_object_access(
--         auth.uid(), 
--         'F_SAFE_INC', 
--         '01',
--         jsonb_build_object('BUKRS', company_code, 'WERKS', plant_code)
--     )
-- );

-- User Management RLS Policies
CREATE POLICY "users_select" ON users FOR SELECT
USING (
    id = auth.uid() OR -- Own record
    check_auth_object_access(
        auth.uid(), 
        'F_USER_MGMT', 
        '03',
        jsonb_build_object('BUKRS', '*')
    )
);

CREATE POLICY "users_insert" ON users FOR INSERT
WITH CHECK (
    check_auth_object_access(
        auth.uid(), 
        'F_USER_MGMT', 
        '01',
        jsonb_build_object('BUKRS', '*')
    )
);

CREATE POLICY "users_update" ON users FOR UPDATE
USING (
    id = auth.uid() OR -- Own record
    check_auth_object_access(
        auth.uid(), 
        'F_USER_MGMT', 
        '02',
        jsonb_build_object('BUKRS', '*')
    )
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_role_auth_objects_lookup ON role_authorization_objects(role_id, auth_object_id) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_users_role_lookup ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_auth_objects_name ON authorization_objects(object_name) WHERE is_active = true;