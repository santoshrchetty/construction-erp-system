-- UNIVERSAL ENTERPRISE APPROVAL ENGINE - RUNTIME FUNCTION
-- Implements the 7-Step Dynamic Approval Flow Generation

CREATE OR REPLACE FUNCTION generate_approval_flow(
    -- INPUT CONTRACT (Guaranteed) - Required parameters first
    p_approval_object_type VARCHAR(20),
    p_approval_object_document_type VARCHAR(10),
    p_document_id UUID,
    p_company_code VARCHAR(10),
    p_country_code VARCHAR(3),
    p_department_code VARCHAR(20),
    p_requestor_user_id UUID,
    p_customer_id UUID,
    -- Optional parameters with defaults last
    p_document_value DECIMAL(15,2) DEFAULT NULL,
    p_currency VARCHAR(3) DEFAULT 'USD',
    p_plant_code VARCHAR(10) DEFAULT NULL,
    p_project_code VARCHAR(20) DEFAULT NULL
)
RETURNS TABLE(
    instance_id UUID,
    strategy VARCHAR(20),
    pattern VARCHAR(30),
    approval_steps JSONB,
    audit_explanation JSONB
) AS $$
DECLARE
    v_instance_id UUID;
    v_strategy VARCHAR(20);
    v_pattern VARCHAR(30);
    v_check_for_value BOOLEAN;
    v_policy_record RECORD;
    v_approval_flow JSONB := '[]'::JSONB;
    v_audit_explanation JSONB := '{}'::JSONB;
    v_sequence_number INTEGER := 1;
    v_functional_approvers JSONB := '[]'::JSONB;
    v_hierarchy_approvers JSONB := '[]'::JSONB;
    v_current_user_id UUID;
    v_current_manager_id UUID;
    v_cumulative_authority DECIMAL(15,2) := 0;
    v_approver_record RECORD;
    v_step JSONB;
BEGIN
    -- Generate unique instance ID
    v_instance_id := uuid_generate_v4();
    
    -- STEP 1: RESOLVE APPROVAL STRATEGY
    SELECT check_for_value, default_strategy 
    INTO v_check_for_value, v_strategy
    FROM approval_object_registry 
    WHERE approval_object_type = p_approval_object_type 
    AND approval_object_document_type = p_approval_object_document_type;
    
    -- Find most specific policy (Project → Plant → Department → Country → Company → Global)
    SELECT * INTO v_policy_record
    FROM approval_policies 
    WHERE customer_id = p_customer_id
    AND approval_object_type = p_approval_object_type
    AND approval_object_document_type = p_approval_object_document_type
    AND (project_code = p_project_code OR project_code IS NULL)
    AND (plant_code = p_plant_code OR plant_code IS NULL)
    AND (department_code = p_department_code OR department_code IS NULL)
    AND (country_code = p_country_code OR country_code IS NULL)
    AND (company_code = p_company_code OR company_code IS NULL)
    AND is_active = true
    ORDER BY 
        CASE WHEN project_code = p_project_code THEN 1 ELSE 6 END,
        CASE WHEN plant_code = p_plant_code THEN 2 ELSE 6 END,
        CASE WHEN department_code = p_department_code THEN 3 ELSE 6 END,
        CASE WHEN country_code = p_country_code THEN 4 ELSE 6 END,
        CASE WHEN company_code = p_company_code THEN 5 ELSE 6 END,
        priority_order
    LIMIT 1;
    
    -- Override strategy from policy if found
    IF v_policy_record.approval_strategy IS NOT NULL THEN
        v_strategy := v_policy_record.approval_strategy;
        v_pattern := v_policy_record.approval_pattern;
    ELSE
        v_pattern := 'HIERARCHY_ONLY';
    END IF;
    
    -- If check_for_value = false, ignore document_value
    IF NOT v_check_for_value THEN
        v_strategy := 'ROLE_BASED';
    END IF;
    
    v_audit_explanation := jsonb_set(v_audit_explanation, '{strategy_resolution}', 
        jsonb_build_object(
            'resolved_strategy', v_strategy,
            'resolved_pattern', v_pattern,
            'check_for_value', v_check_for_value,
            'policy_matched', v_policy_record.policy_name
        )
    );
    
    -- STEP 2 & 3: RESOLVE FUNCTIONAL APPROVAL REQUIREMENTS
    IF v_pattern IN ('FUNCTIONAL_THEN_HIERARCHY', 'PARALLEL_FUNCTIONAL', 'ESCALATED_GLOBAL') THEN
        -- Get functional approvers based on policy
        FOR v_approver_record IN
            SELECT DISTINCT 
                faa.approver_user_id,
                faa.approver_role,
                faa.functional_domain,
                faa.approval_scope,
                faa.approval_limit,
                faa.execution_mode,
                CASE faa.approval_scope 
                    WHEN 'DEPARTMENT' THEN 1 
                    WHEN 'COUNTRY' THEN 2 
                    WHEN 'MULTI_COUNTRY' THEN 3 
                    WHEN 'GLOBAL' THEN 4 
                END as scope_order
            FROM functional_approver_assignments faa
            WHERE faa.customer_id = p_customer_id
            AND faa.functional_domain = ANY(
                SELECT jsonb_array_elements_text(
                    COALESCE(v_policy_record.functional_domains->'required', '[]'::jsonb)
                )
            )
            AND (faa.company_code = p_company_code OR faa.company_code IS NULL)
            AND (faa.country_code = p_country_code OR faa.country_code IS NULL)
            AND (faa.department_code = p_department_code OR faa.department_code IS NULL)
            AND faa.is_active = true
            AND (faa.approval_limit >= p_document_value OR p_document_value IS NULL OR NOT v_check_for_value)
            ORDER BY scope_order
        LOOP
            v_step := jsonb_build_object(
                'sequence_number', v_sequence_number,
                'approver_user_id', v_approver_record.approver_user_id,
                'approver_role', v_approver_record.approver_role,
                'approval_type', 'FUNCTIONAL',
                'approval_domain', v_approver_record.functional_domain,
                'approval_scope', v_approver_record.approval_scope,
                'approval_limit_used', v_approver_record.approval_limit,
                'execution_mode', v_approver_record.execution_mode,
                'parallel_group', CASE WHEN v_approver_record.execution_mode = 'PARALLEL' THEN 1 ELSE NULL END
            );
            
            v_functional_approvers := v_functional_approvers || v_step;
            v_sequence_number := v_sequence_number + 1;
        END LOOP;
    END IF;
    
    -- STEP 4: TRAVERSE REPORTING HIERARCHY
    v_current_user_id := p_requestor_user_id;
    
    -- Get requestor's manager
    SELECT manager_id INTO v_current_manager_id
    FROM organizational_hierarchy 
    WHERE user_id = v_current_user_id 
    AND is_active = true 
    AND (effective_to IS NULL OR effective_to >= CURRENT_DATE);
    
    -- Walk up hierarchy until CEO or sufficient authority
    WHILE v_current_manager_id IS NOT NULL LOOP
        -- Get manager details
        SELECT * INTO v_approver_record
        FROM organizational_hierarchy 
        WHERE user_id = v_current_manager_id 
        AND is_active = true 
        AND (effective_to IS NULL OR effective_to >= CURRENT_DATE);
        
        -- Check if this approver has sufficient authority
        IF v_strategy = 'AMOUNT_BASED' OR v_strategy = 'HYBRID' THEN
            v_cumulative_authority := v_cumulative_authority + COALESCE(v_approver_record.approval_limit, 0);
        END IF;
        
        -- Add to hierarchy approvers
        v_step := jsonb_build_object(
            'sequence_number', v_sequence_number,
            'approver_user_id', v_current_manager_id,
            'approver_role', v_approver_record.position_title,
            'approval_type', 'SUPERVISORY',
            'approval_domain', 'HIERARCHY',
            'approval_scope', CASE 
                WHEN v_approver_record.position_title ILIKE '%CEO%' THEN 'GLOBAL'
                WHEN v_approver_record.position_title ILIKE '%COUNTRY%' THEN 'COUNTRY'
                ELSE 'DEPT'
            END,
            'approval_limit_used', v_approver_record.approval_limit,
            'execution_mode', 'SEQUENTIAL'
        );
        
        v_hierarchy_approvers := v_hierarchy_approvers || v_step;
        v_sequence_number := v_sequence_number + 1;
        
        -- Stop if CEO or sufficient authority reached
        IF v_approver_record.position_title ILIKE '%CEO%' THEN
            EXIT;
        END IF;
        
        IF v_strategy = 'AMOUNT_BASED' AND v_cumulative_authority >= COALESCE(p_document_value, 0) THEN
            EXIT;
        END IF;
        
        -- Move to next level
        v_current_user_id := v_current_manager_id;
        SELECT manager_id INTO v_current_manager_id
        FROM organizational_hierarchy 
        WHERE user_id = v_current_user_id 
        AND is_active = true 
        AND (effective_to IS NULL OR effective_to >= CURRENT_DATE);
    END LOOP;
    
    -- STEP 7: CONSTRUCT FINAL APPROVAL FLOW
    CASE v_pattern
        WHEN 'FUNCTIONAL_THEN_HIERARCHY' THEN
            v_approval_flow := v_functional_approvers || v_hierarchy_approvers;
        WHEN 'HIERARCHY_THEN_FUNCTIONAL' THEN
            v_approval_flow := v_hierarchy_approvers || v_functional_approvers;
        WHEN 'PARALLEL_FUNCTIONAL' THEN
            v_approval_flow := v_functional_approvers || v_hierarchy_approvers;
        ELSE -- HIERARCHY_ONLY
            v_approval_flow := v_hierarchy_approvers;
    END CASE;
    
    -- Create immutable approval instance
    INSERT INTO approval_instances (
        id, document_id, approval_object_type, approval_object_document_type,
        document_value, currency, requestor_user_id, company_code, country_code,
        department_code, plant_code, project_code, resolved_strategy, resolved_pattern,
        approval_flow, audit_explanation
    ) VALUES (
        v_instance_id, p_document_id, p_approval_object_type, p_approval_object_document_type,
        p_document_value, p_currency, p_requestor_user_id, p_company_code, p_country_code,
        p_department_code, p_plant_code, p_project_code, v_strategy, v_pattern,
        v_approval_flow, v_audit_explanation
    );
    
    -- Create approval steps
    FOR i IN 0..jsonb_array_length(v_approval_flow) - 1 LOOP
        v_step := v_approval_flow->i;
        INSERT INTO approval_steps (
            instance_id, sequence_number, approver_user_id, approver_role,
            approval_type, approval_domain, approval_scope, approval_limit_used,
            execution_mode, parallel_group
        ) VALUES (
            v_instance_id,
            (v_step->>'sequence_number')::INTEGER,
            (v_step->>'approver_user_id')::UUID,
            v_step->>'approver_role',
            v_step->>'approval_type',
            v_step->>'approval_domain',
            v_step->>'approval_scope',
            (v_step->>'approval_limit_used')::DECIMAL,
            v_step->>'execution_mode',
            (v_step->>'parallel_group')::INTEGER
        );
    END LOOP;
    
    -- Return results
    RETURN QUERY
    SELECT 
        v_instance_id,
        v_strategy,
        v_pattern,
        v_approval_flow,
        v_audit_explanation;
END;
$$ LANGUAGE plpgsql;

-- Test function to verify engine works
CREATE OR REPLACE FUNCTION test_approval_engine()
RETURNS TABLE(test_case TEXT, result JSONB) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'PO Standard $75000'::TEXT as test_case,
        row_to_json(r)::JSONB as result
    FROM (
        SELECT * FROM generate_approval_flow(
            'PO', 'NB', uuid_generate_v4(), 
            'C001', 'USA', 'PROCUREMENT',
            '550e8400-e29b-41d4-a716-446655440013'::UUID,
            '550e8400-e29b-41d4-a716-446655440001'::UUID,
            75000.00, 'USD', 'B001', NULL
        )
    ) r;
END;
$$ LANGUAGE plpgsql;

SELECT 'UNIVERSAL ENTERPRISE APPROVAL ENGINE RUNTIME READY' as status;