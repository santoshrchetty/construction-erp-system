-- STEP 2: SIMPLIFIED PO APPROVAL SYSTEM

-- Add approval fields to purchase_orders table
ALTER TABLE purchase_orders 
ADD COLUMN IF NOT EXISTS approval_route_id UUID,
ADD COLUMN IF NOT EXISTS current_approval_level INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS approval_status VARCHAR(20) DEFAULT 'PENDING';

-- Create PO-specific approval policies table
CREATE TABLE IF NOT EXISTS po_approval_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_name VARCHAR(50) NOT NULL,
    company_code VARCHAR(4) DEFAULT 'C001',
    amount_min DECIMAL(15,2) DEFAULT 0,
    amount_max DECIMAL(15,2) DEFAULT 999999999,
    approval_level INTEGER NOT NULL,
    approver_role VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create PO approval routes table
CREATE TABLE IF NOT EXISTS po_approval_routes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    po_number VARCHAR(20) NOT NULL,
    policy_id UUID REFERENCES po_approval_policies(id),
    current_level INTEGER DEFAULT 1,
    total_levels INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_by VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- Create PO approval history table
CREATE TABLE IF NOT EXISTS po_approval_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    route_id UUID REFERENCES po_approval_routes(id),
    approver_id VARCHAR(50),
    approval_level INTEGER,
    action VARCHAR(20), -- 'APPROVED' or 'REJECTED'
    comments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create release strategy configuration (SAP-style)
CREATE TABLE IF NOT EXISTS release_strategies (
    strategy_id VARCHAR(10) PRIMARY KEY,
    strategy_name VARCHAR(50),
    document_type VARCHAR(10) DEFAULT 'PO',
    company_code VARCHAR(4) DEFAULT 'C001',
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS release_groups (
    group_id VARCHAR(10) PRIMARY KEY,
    strategy_id VARCHAR(10) REFERENCES release_strategies(strategy_id),
    group_name VARCHAR(50),
    amount_min DECIMAL(15,2),
    amount_max DECIMAL(15,2),
    material_group VARCHAR(10),
    plant_code VARCHAR(4),
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE IF NOT EXISTS release_codes (
    code_id VARCHAR(10) PRIMARY KEY,
    group_id VARCHAR(10) REFERENCES release_groups(group_id),
    sequence_number INTEGER,
    code_name VARCHAR(50),
    approver_role VARCHAR(50),
    is_mandatory BOOLEAN DEFAULT true
);

-- Insert SAP-style release strategy
INSERT INTO release_strategies VALUES ('PO_STD', 'Standard PO Release', 'PO', 'C001', true);
INSERT INTO release_groups VALUES 
('G1', 'PO_STD', 'Small PO', 0, 50000, '*', '*', true),
('G2', 'PO_STD', 'Medium PO', 50001, 200000, '*', '*', true),
('G3', 'PO_STD', 'Large PO', 200001, 999999999, '*', '*', true);
INSERT INTO release_codes VALUES
('R1', 'G1', 1, 'Supervisor Release', 'SUPERVISOR', true),
('R2', 'G2', 1, 'Manager Release', 'MANAGER', true),
('R3', 'G3', 1, 'Director Release', 'DIRECTOR', true);

-- Create PO approval initiation function
CREATE OR REPLACE FUNCTION initiate_po_approval(
    p_po_number VARCHAR(20),
    p_amount DECIMAL(15,2),
    p_created_by VARCHAR(50)
) RETURNS UUID AS $$
DECLARE
    v_route_id UUID;
    v_policy_id UUID;
    v_total_levels INTEGER;
BEGIN
    -- Get applicable approval policy (SAP-style multi-dimensional)
    SELECT id, approval_level INTO v_policy_id, v_total_levels
    FROM po_approval_policies 
    WHERE p_amount BETWEEN amount_min AND amount_max
      AND (company_code = (SELECT LEFT(p_po_number, 4)) OR company_code = 'C001')
      AND is_active = true
    ORDER BY approval_level DESC, amount_max ASC
    LIMIT 1;
    
    -- Create approval route
    INSERT INTO po_approval_routes (
        po_number, policy_id, current_level, total_levels, status, created_by
    ) VALUES (
        p_po_number, v_policy_id, 1, v_total_levels, 'PENDING', p_created_by
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

-- Create PO approval processing function
CREATE OR REPLACE FUNCTION process_po_approval(
    p_po_number VARCHAR(20),
    p_approver_id VARCHAR(50),
    p_action VARCHAR(20),
    p_comments TEXT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_route_id UUID;
    v_current_level INTEGER;
    v_total_levels INTEGER;
    v_required_role VARCHAR(50);
    v_approver_authorized BOOLEAN := FALSE;
BEGIN
    -- Get approval route details
    SELECT ar.id, ar.current_level, ar.total_levels, pol.approver_role
    INTO v_route_id, v_current_level, v_total_levels, v_required_role
    FROM po_approval_routes ar
    JOIN purchase_orders po ON po.approval_route_id = ar.id
    JOIN po_approval_policies pol ON ar.policy_id = pol.id
    WHERE po.po_number = p_po_number
      AND pol.approval_level = ar.current_level;
    
    -- SAP-style authority check (simplified)
    SELECT EXISTS(
        SELECT 1 FROM user_roles 
        WHERE user_id = p_approver_id 
        AND role = v_required_role
    ) INTO v_approver_authorized;
    
    IF NOT v_approver_authorized THEN
        RAISE EXCEPTION 'Approver % does not have authority for role %', p_approver_id, v_required_role;
    END IF;
    
    -- Record approval action
    INSERT INTO po_approval_history (
        route_id, approver_id, approval_level, action, comments
    ) VALUES (
        v_route_id, p_approver_id, v_current_level, p_action, p_comments
    );
    
    IF p_action = 'APPROVED' THEN
        IF v_current_level >= v_total_levels THEN
            -- Final approval
            UPDATE purchase_orders 
            SET approval_status = 'APPROVED', 
                status = 'APPROVED',
                approved_by = p_approver_id,
                approved_at = CURRENT_TIMESTAMP
            WHERE po_number = p_po_number;
            
            UPDATE po_approval_routes 
            SET status = 'APPROVED', completed_at = CURRENT_TIMESTAMP
            WHERE id = v_route_id;
        ELSE
            -- Move to next level
            UPDATE po_approval_routes 
            SET current_level = current_level + 1
            WHERE id = v_route_id;
        END IF;
    ELSE
        -- Rejection
        UPDATE purchase_orders 
        SET approval_status = 'REJECTED', status = 'REJECTED'
        WHERE po_number = p_po_number;
        
        UPDATE po_approval_routes 
        SET status = 'REJECTED', completed_at = CURRENT_TIMESTAMP
        WHERE id = v_route_id;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

SELECT 'STEP 2 COMPLETE - PO APPROVAL SYSTEM CREATED' as status;