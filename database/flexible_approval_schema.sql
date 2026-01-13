-- Comprehensive Flexible Approval System Database Schema
-- Creates all tables needed for the complete approval workflow

-- 1. Approval Level Templates
CREATE TABLE IF NOT EXISTS approval_level_templates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    template_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    customer_type VARCHAR(20) CHECK (customer_type IN ('SMALL', 'MEDIUM', 'LARGE', 'ENTERPRISE')),
    industry_type VARCHAR(50) DEFAULT 'CONSTRUCTION',
    is_public BOOLEAN DEFAULT true,
    usage_count INTEGER DEFAULT 0,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true
);

-- 2. Flexible Approval Levels
CREATE TABLE IF NOT EXISTS flexible_approval_levels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('MATERIAL_REQ', 'PURCHASE_REQ', 'PURCHASE_ORDER', 'RESERVATION')),
    level_number INTEGER NOT NULL,
    level_name VARCHAR(100) NOT NULL,
    amount_threshold_min DECIMAL(15,2) DEFAULT 0,
    amount_threshold_max DECIMAL(15,2) DEFAULT 999999999,
    approver_role VARCHAR(50) NOT NULL,
    approver_user_id UUID,
    approval_type VARCHAR(20) DEFAULT 'SEQUENTIAL' CHECK (approval_type IN ('SEQUENTIAL', 'PARALLEL', 'ANY_ONE')),
    is_required BOOLEAN DEFAULT true,
    can_delegate BOOLEAN DEFAULT true,
    delegation_rules JSONB,
    notification_settings JSONB,
    escalation_hours INTEGER DEFAULT 24,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(customer_id, document_type, level_number)
);

-- 3. Customer Approval Configuration
CREATE TABLE IF NOT EXISTS customer_approval_configuration (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    config_name VARCHAR(100) NOT NULL,
    template_id UUID REFERENCES approval_level_templates(id),
    is_template_based BOOLEAN DEFAULT false,
    emergency_override_enabled BOOLEAN DEFAULT true,
    emergency_override_roles TEXT[],
    bulk_approval_enabled BOOLEAN DEFAULT false,
    parallel_approval_enabled BOOLEAN DEFAULT false,
    auto_approval_rules JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(customer_id, document_type, config_name)
);

-- 4. Customer Material Request Config
CREATE TABLE IF NOT EXISTS customer_material_request_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    config_name VARCHAR(100) NOT NULL,
    request_mode VARCHAR(20) DEFAULT 'TRADITIONAL' CHECK (request_mode IN ('TRADITIONAL', 'HYBRID', 'INTELLIGENT')),
    intelligence_level VARCHAR(20) DEFAULT 'BASIC' CHECK (intelligence_level IN ('BASIC', 'STANDARD', 'ADVANCED')),
    auto_routing_enabled BOOLEAN DEFAULT false,
    smart_thresholds_enabled BOOLEAN DEFAULT false,
    predictive_approval_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(customer_id, config_name)
);

-- 5. Material Requests
CREATE TABLE IF NOT EXISTS material_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_number VARCHAR(50) NOT NULL UNIQUE,
    request_type VARCHAR(50) NOT NULL CHECK (request_type IN ('MATERIAL_REQ', 'PURCHASE_REQ', 'PURCHASE_ORDER', 'RESERVATION')),
    status VARCHAR(20) DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'SUBMITTED', 'IN_APPROVAL', 'APPROVED', 'REJECTED', 'CANCELLED')),
    priority VARCHAR(10) DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
    requested_by UUID NOT NULL,
    required_date DATE,
    company_code VARCHAR(10),
    plant_code VARCHAR(10),
    cost_center VARCHAR(20),
    project_code VARCHAR(20),
    purpose TEXT,
    notes TEXT,
    total_amount DECIMAL(15,2) DEFAULT 0,
    currency_code VARCHAR(3) DEFAULT 'USD',
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Material Request Items
CREATE TABLE IF NOT EXISTS material_request_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL REFERENCES material_requests(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    material_code VARCHAR(50),
    material_name VARCHAR(200),
    description TEXT,
    requested_quantity DECIMAL(15,3) NOT NULL,
    base_uom VARCHAR(10) NOT NULL,
    estimated_price DECIMAL(15,2),
    currency_code VARCHAR(3) DEFAULT 'USD',
    line_total DECIMAL(15,2) GENERATED ALWAYS AS (requested_quantity * COALESCE(estimated_price, 0)) STORED,
    delivery_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(request_id, line_number)
);

-- 7. Approval Executions
CREATE TABLE IF NOT EXISTS approval_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_id UUID NOT NULL REFERENCES material_requests(id) ON DELETE CASCADE,
    config_id UUID NOT NULL REFERENCES customer_approval_configuration(id),
    current_level INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'IN_PROGRESS', 'COMPLETED', 'REJECTED', 'CANCELLED')),
    total_levels INTEGER NOT NULL,
    execution_path JSONB NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Approval Actions
CREATE TABLE IF NOT EXISTS approval_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    execution_id UUID NOT NULL REFERENCES approval_executions(id) ON DELETE CASCADE,
    level_number INTEGER NOT NULL,
    approver_id UUID NOT NULL,
    approver_role VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('APPROVED', 'REJECTED', 'DELEGATED', 'ESCALATED')),
    comments TEXT,
    action_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    delegation_to UUID,
    escalation_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. Approval Delegations
CREATE TABLE IF NOT EXISTS approval_delegations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    delegator_id UUID NOT NULL,
    delegate_id UUID NOT NULL,
    document_types TEXT[] NOT NULL,
    amount_limit DECIMAL(15,2),
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL,
    reason TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_flexible_approval_levels_customer_doc ON flexible_approval_levels(customer_id, document_type);
CREATE INDEX IF NOT EXISTS idx_flexible_approval_levels_amount ON flexible_approval_levels(amount_threshold_min, amount_threshold_max);
CREATE INDEX IF NOT EXISTS idx_material_requests_status ON material_requests(status);
CREATE INDEX IF NOT EXISTS idx_material_requests_requested_by ON material_requests(requested_by);
CREATE INDEX IF NOT EXISTS idx_approval_executions_request ON approval_executions(request_id);
CREATE INDEX IF NOT EXISTS idx_approval_executions_status ON approval_executions(status);
CREATE INDEX IF NOT EXISTS idx_approval_actions_execution ON approval_actions(execution_id);
CREATE INDEX IF NOT EXISTS idx_approval_actions_approver ON approval_actions(approver_id);

-- 11. Create validation functions
CREATE OR REPLACE FUNCTION validate_approval_config(config_id UUID)
RETURNS TABLE(is_valid BOOLEAN, validation_errors TEXT[]) AS $$
DECLARE
    errors TEXT[] := '{}';
    level_count INTEGER;
    gap_exists BOOLEAN;
BEGIN
    -- Check if levels are sequential
    SELECT COUNT(*), 
           EXISTS(
               SELECT 1 FROM flexible_approval_levels fal1
               WHERE fal1.customer_id = (SELECT customer_id FROM customer_approval_configuration WHERE id = config_id)
               AND fal1.document_type = (SELECT document_type FROM customer_approval_configuration WHERE id = config_id)
               AND NOT EXISTS(
                   SELECT 1 FROM flexible_approval_levels fal2
                   WHERE fal2.customer_id = fal1.customer_id
                   AND fal2.document_type = fal1.document_type
                   AND fal2.level_number = fal1.level_number - 1
                   AND fal1.level_number > 1
               )
           )
    INTO level_count, gap_exists
    FROM flexible_approval_levels
    WHERE customer_id = (SELECT customer_id FROM customer_approval_configuration WHERE id = config_id)
    AND document_type = (SELECT document_type FROM customer_approval_configuration WHERE id = config_id);
    
    IF level_count = 0 THEN
        errors := array_append(errors, 'No approval levels defined');
    END IF;
    
    IF gap_exists THEN
        errors := array_append(errors, 'Approval levels are not sequential');
    END IF;
    
    RETURN QUERY SELECT array_length(errors, 1) = 0, errors;
END;
$$ LANGUAGE plpgsql;

-- 12. Create approval path calculation function
CREATE OR REPLACE FUNCTION get_approval_path(
    p_customer_id UUID,
    p_document_type VARCHAR(50),
    p_amount DECIMAL(15,2)
)
RETURNS TABLE(
    level_number INTEGER,
    level_name VARCHAR(100),
    approver_role VARCHAR(50),
    is_required BOOLEAN,
    approval_type VARCHAR(20)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        fal.level_number,
        fal.level_name,
        fal.approver_role,
        fal.is_required,
        fal.approval_type
    FROM flexible_approval_levels fal
    WHERE fal.customer_id = p_customer_id
    AND fal.document_type = p_document_type
    AND fal.is_active = true
    AND p_amount >= fal.amount_threshold_min
    AND p_amount <= fal.amount_threshold_max
    ORDER BY fal.level_number;
END;
$$ LANGUAGE plpgsql;

-- 13. Create template application function
CREATE OR REPLACE FUNCTION apply_approval_template(
    p_customer_id UUID,
    p_document_type VARCHAR(50),
    p_template_id UUID,
    p_config_name VARCHAR(100)
)
RETURNS UUID AS $$
DECLARE
    config_id UUID;
BEGIN
    -- Create customer configuration
    INSERT INTO customer_approval_configuration (
        customer_id, document_type, config_name, template_id, is_template_based
    ) VALUES (
        p_customer_id, p_document_type, p_config_name, p_template_id, true
    ) RETURNING id INTO config_id;
    
    -- Apply template levels (this would be expanded based on template structure)
    -- For now, create basic levels based on template type
    INSERT INTO flexible_approval_levels (
        customer_id, document_type, level_number, level_name, 
        amount_threshold_min, amount_threshold_max, approver_role
    )
    SELECT 
        p_customer_id,
        p_document_type,
        1,
        'Level 1 Approval',
        0,
        50000,
        'SUPERVISOR'
    WHERE p_template_id IS NOT NULL;
    
    RETURN config_id;
END;
$$ LANGUAGE plpgsql;

-- 14. Add comments for documentation
COMMENT ON TABLE approval_level_templates IS 'Pre-defined approval workflow templates for different customer types and industries';
COMMENT ON TABLE flexible_approval_levels IS 'Customer-specific approval levels with unlimited flexibility';
COMMENT ON TABLE customer_approval_configuration IS 'Master configuration for customer approval workflows';
COMMENT ON TABLE material_requests IS 'All types of material/purchase requests in the system';
COMMENT ON TABLE approval_executions IS 'Active approval workflow executions';
COMMENT ON TABLE approval_actions IS 'Individual approval actions taken by approvers';
COMMENT ON TABLE approval_delegations IS 'Approval authority delegations between users';

-- 15. Verify table creation
SELECT 'FLEXIBLE APPROVAL TABLES CREATED:' as info;
SELECT table_name, 
       (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE t.table_schema = 'public' 
AND (t.table_name LIKE '%approval%' OR t.table_name LIKE '%flexible%' OR t.table_name = 'material_requests' OR t.table_name = 'material_request_items')
ORDER BY t.table_name;