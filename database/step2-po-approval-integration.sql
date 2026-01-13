-- STEP 2: INTEGRATE PO WITH UNIVERSAL APPROVAL ENGINE

-- Add PO approval policies to existing approval_policies table
INSERT INTO approval_policies (
    policy_name, document_type, company_code, amount_threshold_min, amount_threshold_max,
    approver_level, approver_role, is_mandatory, created_by
) VALUES 
    ('PO_SMALL', 'PURCHASE_ORDER', 'C001', 0, 50000, 1, 'SUPERVISOR', true, 'SYSTEM'),
    ('PO_MEDIUM', 'PURCHASE_ORDER', 'C001', 50001, 200000, 2, 'MANAGER', true, 'SYSTEM'),
    ('PO_LARGE', 'PURCHASE_ORDER', 'C001', 200001, 999999999, 3, 'DIRECTOR', true, 'SYSTEM')
ON CONFLICT (policy_name, document_type, company_code) DO NOTHING;

-- Add PO context fields for approval routing
INSERT INTO context_fields (field_name, field_type, is_required, options, created_by)
VALUES 
    ('po_amount', 'NUMBER', true, NULL, 'SYSTEM'),
    ('vendor_code', 'TEXT', true, NULL, 'SYSTEM'),
    ('department', 'TEXT', false, '["CONSTRUCTION","PROCUREMENT","FINANCE"]', 'SYSTEM'),
    ('priority', 'TEXT', false, '["LOW","NORMAL","HIGH","URGENT"]', 'SYSTEM')
ON CONFLICT (field_name) DO NOTHING;

-- Update purchase_orders to include approval fields
ALTER TABLE purchase_orders 
ADD COLUMN IF NOT EXISTS approval_route_id UUID,
ADD COLUMN IF NOT EXISTS current_approval_level INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS approval_status VARCHAR(20) DEFAULT 'PENDING';

-- Create PO approval integration function
CREATE OR REPLACE FUNCTION initiate_po_approval(
    p_po_number VARCHAR(20),
    p_amount DECIMAL(15,2),
    p_vendor_code VARCHAR(20),
    p_department VARCHAR(50),
    p_priority VARCHAR(10),
    p_created_by VARCHAR(50)
) RETURNS UUID AS $$
DECLARE
    v_route_id UUID;
    v_policy_id UUID;
BEGIN
    -- Get applicable approval policy
    SELECT id INTO v_policy_id
    FROM approval_policies 
    WHERE document_type = 'PURCHASE_ORDER'
      AND p_amount BETWEEN amount_threshold_min AND amount_threshold_max
    ORDER BY approver_level
    LIMIT 1;
    
    -- Create approval route
    INSERT INTO approval_routes (
        document_type, document_id, policy_id, current_level, 
        total_levels, status, created_by
    ) VALUES (
        'PURCHASE_ORDER', p_po_number, v_policy_id, 1, 
        (SELECT MAX(approver_level) FROM approval_policies WHERE document_type = 'PURCHASE_ORDER'), 
        'PENDING', p_created_by
    ) RETURNING id INTO v_route_id;
    
    -- Update PO with approval route
    UPDATE purchase_orders 
    SET approval_route_id = v_route_id, 
        approval_status = 'PENDING_APPROVAL'
    WHERE po_number = p_po_number;
    
    RETURN v_route_id;
END;
$$ LANGUAGE plpgsql;

SELECT 'STEP 2 COMPLETE - PO APPROVAL INTEGRATION' as status;