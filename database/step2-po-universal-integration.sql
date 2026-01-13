-- STEP 2: INTEGRATE PO WITH UNIVERSAL APPROVAL ENGINE

-- Remove duplicate PO approval tables (use universal engine instead)
DROP TABLE IF EXISTS po_approval_policies CASCADE;
DROP TABLE IF EXISTS po_approval_routes CASCADE; 
DROP TABLE IF EXISTS po_approval_history CASCADE;
DROP TABLE IF EXISTS release_strategies CASCADE;
DROP TABLE IF EXISTS release_groups CASCADE;
DROP TABLE IF EXISTS release_codes CASCADE;

-- Add PO integration fields to purchase_orders
ALTER TABLE purchase_orders 
ADD COLUMN IF NOT EXISTS approval_request_id UUID,
ADD COLUMN IF NOT EXISTS approval_status VARCHAR(20) DEFAULT 'PENDING';

-- Create PO approval integration function
CREATE OR REPLACE FUNCTION initiate_po_approval(
    p_po_number VARCHAR(20),
    p_amount DECIMAL(15,2),
    p_created_by VARCHAR(50)
) RETURNS UUID AS $$
DECLARE
    v_request_id UUID;
    v_po_data JSONB;
    v_customer_id UUID := '550e8400-e29b-41d4-a716-446655440001';
BEGIN
    -- Get PO context data including department
    SELECT jsonb_build_object(
        'po_number', po.po_number,
        'vendor_code', po.vendor_code,
        'project_code', po.project_code,
        'total_amount', po.total_amount,
        'currency', COALESCE(po.currency, 'USD'),
        'company_code', COALESCE(po.company_code, 'C001'),
        'department_code', po.department,
        'plant_code', po.plant_code,
        'cost_center', po.cost_center
    ) INTO v_po_data
    FROM purchase_orders po
    WHERE po.po_number = p_po_number;
    
    -- Create approval request using universal engine
    INSERT INTO approval_requests (
        id, customer_id, object_type, object_id, object_data,
        requested_by, request_amount, request_currency,
        company_code, plant_code, project_code,
        status, created_at
    ) VALUES (
        gen_random_uuid(), v_customer_id, 'PO', p_po_number, v_po_data,
        p_created_by, p_amount, 'USD',
        COALESCE((v_po_data->>'company_code'), 'C001'),
        v_po_data->>'plant_code',
        v_po_data->>'project_code',
        'PENDING', NOW()
    ) RETURNING id INTO v_request_id;
    
    -- Update PO with approval request
    UPDATE purchase_orders 
    SET approval_request_id = v_request_id,
        approval_status = 'PENDING_APPROVAL',
        status = 'PENDING_APPROVAL'
    WHERE po_number = p_po_number;
    
    RETURN v_request_id;
END;
$$ LANGUAGE plpgsql;

-- Create PO approval processing function using universal engine
CREATE OR REPLACE FUNCTION process_po_approval(
    p_po_number VARCHAR(20),
    p_approver_id VARCHAR(50),
    p_action VARCHAR(20),
    p_comments TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_request_id UUID;
    v_approval_result BOOLEAN;
BEGIN
    -- Get approval request ID
    SELECT approval_request_id INTO v_request_id
    FROM purchase_orders
    WHERE po_number = p_po_number;
    
    IF v_request_id IS NULL THEN
        RAISE EXCEPTION 'No approval request found for PO %', p_po_number;
    END IF;
    
    -- Process approval using universal engine
    SELECT process_approval_request(
        v_request_id, p_approver_id, p_action, p_comments
    ) INTO v_approval_result;
    
    -- Update PO status based on approval result
    IF p_action = 'APPROVED' THEN
        -- Check if fully approved
        IF EXISTS (
            SELECT 1 FROM approval_requests 
            WHERE id = v_request_id AND status = 'APPROVED'
        ) THEN
            UPDATE purchase_orders 
            SET approval_status = 'APPROVED',
                status = 'APPROVED',
                approved_by = p_approver_id,
                approved_at = CURRENT_TIMESTAMP
            WHERE po_number = p_po_number;
        END IF;
    ELSE
        -- Rejection
        UPDATE purchase_orders 
        SET approval_status = 'REJECTED',
            status = 'REJECTED'
        WHERE po_number = p_po_number;
    END IF;
    
    RETURN v_approval_result;
END;
$$ LANGUAGE plpgsql;

-- Insert PO approval policy into universal engine
INSERT INTO approval_policies (
    id, customer_id, policy_name, 
    approval_object_type, approval_object_document_type,
    object_category, object_subtype,
    approval_strategy, approval_pattern,
    amount_thresholds, company_code, country_code,
    approval_context, business_rules, is_active
) VALUES (
    gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
    'Purchase Order Approval Policy',
    'PO', 'STANDARD', 'FINANCIAL', 'PROCUREMENT',
    'AMOUNT_BASED', 'HIERARCHY_ONLY',
    '{"min": 0, "max": 999999999, "currency": "USD"}',
    'C001', 'USA',
    '{"requires_budget_check": true, "vendor_approval_required": false}',
    '{"auto_approve_below": 1000, "require_three_quotes_above": 50000}',
    true
) ON CONFLICT DO NOTHING;

SELECT 'PO INTEGRATED WITH UNIVERSAL APPROVAL ENGINE' as status;