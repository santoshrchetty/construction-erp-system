-- STEP 2: UNIVERSAL APPROVAL ENGINE INTEGRATION

-- Add approval fields to purchase_orders table
ALTER TABLE purchase_orders 
ADD COLUMN IF NOT EXISTS approval_route_id UUID,
ADD COLUMN IF NOT EXISTS current_approval_level INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS approval_status VARCHAR(20) DEFAULT 'PENDING';

-- Add PO approval policies to existing approval_policies table
INSERT INTO approval_policies (
    policy_name, document_type, company_code, amount_threshold_min, amount_threshold_max,
    approver_level, approver_role, is_mandatory, created_by
) VALUES 
    ('PO_SMALL', 'PURCHASE_ORDER', 'C001', 0, 50000, 1, 'SUPERVISOR', true, 'SYSTEM'),
    ('PO_MEDIUM', 'PURCHASE_ORDER', 'C001', 50001, 200000, 2, 'MANAGER', true, 'SYSTEM'),
    ('PO_LARGE', 'PURCHASE_ORDER', 'C001', 200001, 999999999, 3, 'DIRECTOR', true, 'SYSTEM')
ON CONFLICT (policy_name, document_type, company_code) DO NOTHING;

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
    v_total_levels INTEGER;
BEGIN
    -- Get applicable approval policy
    SELECT id, approver_level INTO v_policy_id, v_total_levels
    FROM approval_policies 
    WHERE document_type = 'PURCHASE_ORDER'
      AND p_amount BETWEEN amount_threshold_min AND amount_threshold_max
    ORDER BY approver_level DESC
    LIMIT 1;
    
    -- Create approval route
    INSERT INTO approval_routes (
        document_type, document_id, policy_id, current_level, 
        total_levels, status, created_by
    ) VALUES (
        'PURCHASE_ORDER', p_po_number, v_policy_id, 1, 
        v_total_levels, 'PENDING', p_created_by
    ) RETURNING id INTO v_route_id;
    
    -- Update PO with approval route
    UPDATE purchase_orders 
    SET approval_route_id = v_route_id, 
        approval_status = 'PENDING_APPROVAL',
        status = 'PENDING_APPROVAL'
    WHERE po_number = p_po_number;
    
    RETURN v_route_id;
END;
$$ LANGUAGE plpgsql;

-- Create PO approval action function
CREATE OR REPLACE FUNCTION process_po_approval(
    p_po_number VARCHAR(20),
    p_approver_id VARCHAR(50),
    p_action VARCHAR(20), -- 'APPROVED' or 'REJECTED'
    p_comments TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_route_id UUID;
    v_current_level INTEGER;
    v_total_levels INTEGER;
BEGIN
    -- Get approval route details
    SELECT ar.id, ar.current_level, ar.total_levels
    INTO v_route_id, v_current_level, v_total_levels
    FROM approval_routes ar
    JOIN purchase_orders po ON po.approval_route_id = ar.id
    WHERE po.po_number = p_po_number;
    
    -- Record approval action
    INSERT INTO approval_history (
        route_id, approver_id, approval_level, action, comments, created_at
    ) VALUES (
        v_route_id, p_approver_id, v_current_level, p_action, p_comments, CURRENT_TIMESTAMP
    );
    
    IF p_action = 'APPROVED' THEN
        -- Check if final approval
        IF v_current_level >= v_total_levels THEN
            -- Final approval - update PO status
            UPDATE purchase_orders 
            SET approval_status = 'APPROVED', 
                status = 'APPROVED',
                approved_by = p_approver_id,
                approved_at = CURRENT_TIMESTAMP
            WHERE po_number = p_po_number;
            
            UPDATE approval_routes 
            SET status = 'APPROVED', completed_at = CURRENT_TIMESTAMP
            WHERE id = v_route_id;
        ELSE
            -- Move to next level
            UPDATE approval_routes 
            SET current_level = current_level + 1
            WHERE id = v_route_id;
            
            UPDATE purchase_orders 
            SET current_approval_level = current_approval_level + 1
            WHERE po_number = p_po_number;
        END IF;
    ELSE
        -- Rejection
        UPDATE purchase_orders 
        SET approval_status = 'REJECTED', 
            status = 'REJECTED'
        WHERE po_number = p_po_number;
        
        UPDATE approval_routes 
        SET status = 'REJECTED', completed_at = CURRENT_TIMESTAMP
        WHERE id = v_route_id;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Create function to get pending approvals for user
CREATE OR REPLACE FUNCTION get_pending_po_approvals(p_user_id VARCHAR(50))
RETURNS TABLE (
    po_number VARCHAR(20),
    vendor_code VARCHAR(20),
    total_amount DECIMAL(15,2),
    created_by VARCHAR(50),
    approval_level INTEGER,
    policy_name VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        po.po_number,
        po.vendor_code,
        po.total_amount,
        po.created_by,
        ar.current_level,
        ap.policy_name
    FROM purchase_orders po
    JOIN approval_routes ar ON po.approval_route_id = ar.id
    JOIN approval_policies ap ON ar.policy_id = ap.id
    WHERE ar.status = 'PENDING'
      AND ap.approver_role IN (
          SELECT role_name FROM user_roles WHERE user_id = p_user_id
      )
      AND ar.current_level = ap.approver_level;
END;
$$ LANGUAGE plpgsql;

SELECT 'STEP 2 COMPLETE - APPROVAL ENGINE INTEGRATED' as status;