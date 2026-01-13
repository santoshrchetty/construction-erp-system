-- PO TYPES WITH APPROVAL BYPASS

-- Add PO type and bypass fields to purchase_orders
ALTER TABLE purchase_orders 
ADD COLUMN IF NOT EXISTS po_type VARCHAR(20) DEFAULT 'STANDARD',
ADD COLUMN IF NOT EXISTS bypass_approval BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS bypass_reason VARCHAR(100),
ADD COLUMN IF NOT EXISTS auto_approved BOOLEAN DEFAULT false;

-- Create PO types configuration
CREATE TABLE IF NOT EXISTS po_types (
    po_type VARCHAR(20) PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    requires_approval BOOLEAN DEFAULT true,
    auto_approve_below DECIMAL(15,2) DEFAULT 0,
    bypass_conditions JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true
);

-- Insert PO types with approval rules
INSERT INTO po_types (po_type, type_name, requires_approval, auto_approve_below, bypass_conditions) VALUES
('STANDARD', 'Standard Purchase Order', true, 0, '{}'),
('EMERGENCY', 'Emergency Purchase Order', false, 999999999, '{"post_approval_required": true, "notification_required": true}'),
('BLANKET', 'Blanket Purchase Order', true, 0, '{"framework_approved": true}'),
('INTERNAL', 'Internal Transfer Order', false, 999999999, '{"internal_only": true}'),
('FRAMEWORK', 'Framework Purchase Order', true, 0, '{"master_agreement": true}'),
('PETTY_CASH', 'Petty Cash Purchase', false, 1000, '{"auto_approve": true}'),
('MAINTENANCE', 'Maintenance Purchase Order', true, 5000, '{"auto_approve_below": 5000}')
ON CONFLICT (po_type) DO NOTHING;

-- Enhanced PO approval initiation with bypass logic
CREATE OR REPLACE FUNCTION initiate_po_approval_with_bypass(
    p_po_number VARCHAR(20),
    p_amount DECIMAL(15,2),
    p_created_by VARCHAR(50)
) RETURNS UUID AS $$
DECLARE
    v_request_id UUID;
    v_po_type VARCHAR(20);
    v_requires_approval BOOLEAN;
    v_auto_approve_below DECIMAL(15,2);
    v_bypass_conditions JSONB;
BEGIN
    -- Get PO type and approval rules
    SELECT po.po_type, pt.requires_approval, pt.auto_approve_below, pt.bypass_conditions
    INTO v_po_type, v_requires_approval, v_auto_approve_below, v_bypass_conditions
    FROM purchase_orders po
    JOIN po_types pt ON po.po_type = pt.po_type
    WHERE po.po_number = p_po_number;
    
    -- Check if approval can be bypassed
    IF NOT v_requires_approval OR p_amount <= v_auto_approve_below THEN
        -- Auto-approve PO
        UPDATE purchase_orders 
        SET approval_status = 'AUTO_APPROVED',
            status = 'APPROVED',
            auto_approved = true,
            bypass_approval = true,
            bypass_reason = CASE 
                WHEN NOT v_requires_approval THEN 'PO Type: ' || v_po_type || ' - No approval required'
                ELSE 'Amount $' || p_amount || ' below threshold $' || v_auto_approve_below
            END,
            approved_by = 'SYSTEM',
            approved_at = CURRENT_TIMESTAMP
        WHERE po_number = p_po_number;
        
        RETURN NULL; -- No approval request needed
    END IF;
    
    -- Standard approval process
    RETURN initiate_po_approval(p_po_number, p_amount, p_created_by);
END;
$$ LANGUAGE plpgsql;

-- View for PO approval status including bypassed POs
CREATE OR REPLACE VIEW v_po_approval_status AS
SELECT 
    po.po_number,
    po.po_type,
    po.total_amount,
    po.approval_status,
    po.status,
    po.bypass_approval,
    po.bypass_reason,
    po.auto_approved,
    po.approved_by,
    po.approved_at,
    pt.type_name,
    pt.requires_approval as type_requires_approval
FROM purchase_orders po
LEFT JOIN po_types pt ON po.po_type = pt.po_type;

SELECT 'PO TYPES WITH APPROVAL BYPASS CONFIGURED' as status;