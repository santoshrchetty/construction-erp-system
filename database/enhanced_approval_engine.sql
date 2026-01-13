-- Enhanced Universal Approval Engine Schema
-- Explicit configuration with approval types and organizational context

-- 1. Enhanced Flexible Approval Levels with explicit fields
ALTER TABLE flexible_approval_levels 
ADD COLUMN IF NOT EXISTS approval_type_scope VARCHAR(20) DEFAULT 'GLOBAL' CHECK (approval_type_scope IN ('GLOBAL', 'DEPARTMENT', 'PROJECT')),
ADD COLUMN IF NOT EXISTS approval_object_type VARCHAR(20) DEFAULT 'MATERIAL_REQ' CHECK (approval_object_type IN ('MR', 'PR', 'PO', 'RESERVATION', 'CHANGE_ORDER', 'CLAIM', 'QUALITY', 'SAFETY')),
ADD COLUMN IF NOT EXISTS company_code VARCHAR(10),
ADD COLUMN IF NOT EXISTS plant_code VARCHAR(10),
ADD COLUMN IF NOT EXISTS cost_center VARCHAR(20),
ADD COLUMN IF NOT EXISTS purchasing_org VARCHAR(10),
ADD COLUMN IF NOT EXISTS purchasing_group VARCHAR(10),
ADD COLUMN IF NOT EXISTS material_group VARCHAR(20),
ADD COLUMN IF NOT EXISTS vendor_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS approval_conditions JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS organizational_restrictions JSONB DEFAULT '{}';

-- 2. Approval Object Configuration Master
CREATE TABLE IF NOT EXISTS approval_object_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    object_type VARCHAR(20) NOT NULL CHECK (object_type IN ('MR', 'PR', 'PO', 'RESERVATION', 'CHANGE_ORDER', 'CLAIM', 'QUALITY', 'SAFETY')),
    object_name VARCHAR(100) NOT NULL,
    description TEXT,
    required_fields JSONB NOT NULL DEFAULT '[]',
    optional_fields JSONB DEFAULT '[]',
    default_approval_type VARCHAR(20) DEFAULT 'GLOBAL',
    routing_logic JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(object_type)
);

-- 3. Organizational Approval Rules
CREATE TABLE IF NOT EXISTS org_approval_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL,
    rule_name VARCHAR(100) NOT NULL,
    approval_type_scope VARCHAR(20) NOT NULL CHECK (approval_type_scope IN ('GLOBAL', 'DEPARTMENT', 'PROJECT')),
    object_type VARCHAR(20) NOT NULL,
    company_code VARCHAR(10),
    plant_code VARCHAR(10),
    department_code VARCHAR(20),
    project_code VARCHAR(20),
    cost_center VARCHAR(20),
    purchasing_org VARCHAR(10),
    rule_conditions JSONB NOT NULL DEFAULT '{}',
    priority_order INTEGER DEFAULT 100,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(customer_id, rule_name)
);

-- 4. Enhanced Approval Configuration UI Form Structure
CREATE TABLE IF NOT EXISTS approval_config_form_fields (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    field_group VARCHAR(50) NOT NULL,
    field_name VARCHAR(50) NOT NULL,
    field_label VARCHAR(100) NOT NULL,
    field_type VARCHAR(20) NOT NULL CHECK (field_type IN ('SELECT', 'TEXT', 'NUMBER', 'DATE', 'CHECKBOX', 'MULTI_SELECT')),
    field_options JSONB,
    is_required BOOLEAN DEFAULT false,
    display_order INTEGER DEFAULT 100,
    help_text TEXT,
    validation_rules JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true
);

-- 5. Populate Approval Object Configuration
INSERT INTO approval_object_config (object_type, object_name, description, required_fields, optional_fields, routing_logic) VALUES
('MR', 'Material Request', 'Material requisition for procurement', 
 '["total_amount", "plant_code", "requested_by"]', 
 '["cost_center", "project_code", "material_group"]',
 '{"amount_based": true, "org_based": true, "project_based": true}'),
 
('PR', 'Purchase Request', 'Purchase requisition for vendor procurement',
 '["total_amount", "plant_code", "purchasing_org", "requested_by"]',
 '["vendor_code", "material_group", "cost_center"]',
 '{"amount_based": true, "vendor_based": true, "org_based": true}'),
 
('PO', 'Purchase Order', 'Purchase order for vendor execution',
 '["total_amount", "vendor_code", "purchasing_org", "created_by"]',
 '["payment_terms", "delivery_date", "project_code"]',
 '{"amount_based": true, "vendor_based": true, "contract_based": true}'),
 
('CHANGE_ORDER', 'Change Order', 'Project scope/schedule changes',
 '["change_value", "project_code", "change_type", "requested_by"]',
 '["impact_assessment", "risk_level", "urgency"]',
 '{"value_based": true, "project_based": true, "risk_based": true}'),
 
('CLAIM', 'Claims & Disputes', 'Insurance/warranty claims',
 '["claim_amount", "claim_type", "project_code", "submitted_by"]',
 '["insurance_policy", "risk_category", "legal_review"]',
 '{"amount_based": true, "risk_based": true, "legal_based": true}');

-- 6. Populate Form Field Configuration
INSERT INTO approval_config_form_fields (field_group, field_name, field_label, field_type, field_options, is_required, display_order, help_text) VALUES
-- Basic Configuration
('basic', 'approval_type_scope', 'Type of Approval', 'SELECT', '["GLOBAL", "DEPARTMENT", "PROJECT"]', true, 1, 'Global: Standard company-wide rules, Department: Specialized departmental rules, Project: Critical project-specific rules'),
('basic', 'approval_object_type', 'Approval Object Type', 'SELECT', '["MR", "PR", "PO", "RESERVATION", "CHANGE_ORDER", "CLAIM", "QUALITY", "SAFETY"]', true, 2, 'Select the type of document/process requiring approval'),
('basic', 'level_name', 'Approval Level Name', 'TEXT', null, true, 3, 'Descriptive name for this approval level'),
('basic', 'approver_role', 'Approver Role', 'SELECT', '["DEPT_MANAGER", "FINANCE_MANAGER", "GENERAL_MANAGER", "PROJECT_MANAGER", "CEO"]', true, 4, 'Role responsible for approval at this level'),

-- Amount Thresholds
('thresholds', 'amount_threshold_min', 'Minimum Amount', 'NUMBER', null, true, 5, 'Minimum amount for this approval level'),
('thresholds', 'amount_threshold_max', 'Maximum Amount', 'NUMBER', null, true, 6, 'Maximum amount for this approval level'),
('thresholds', 'currency_code', 'Currency', 'SELECT', '["USD", "EUR", "GBP", "INR"]', false, 7, 'Currency for amount thresholds'),

-- Organizational Context
('organization', 'company_code', 'Company Code', 'SELECT', null, false, 8, 'Restrict to specific company (leave blank for all companies)'),
('organization', 'plant_code', 'Plant Code', 'SELECT', null, false, 9, 'Restrict to specific plant (leave blank for all plants)'),
('organization', 'department_code', 'Department Code', 'SELECT', '["CONSTRUCTION", "SAFETY", "FINANCE", "PROCUREMENT", "QUALITY"]', false, 10, 'Department-specific approval rules'),
('organization', 'project_code', 'Project Code', 'TEXT', null, false, 11, 'Project-specific approval rules (for critical projects only)'),

-- Advanced Settings
('advanced', 'is_required', 'Required Level', 'CHECKBOX', null, false, 12, 'Cannot be skipped in approval workflow'),
('advanced', 'can_delegate', 'Allow Delegation', 'CHECKBOX', null, false, 13, 'Approver can delegate to another user'),
('advanced', 'escalation_hours', 'Escalation Hours', 'NUMBER', null, false, 14, 'Hours before escalating to next level');

-- 7. Enhanced Smart Approval Engine Function
CREATE OR REPLACE FUNCTION get_enhanced_approval_path(
    p_customer_id UUID,
    p_object_type VARCHAR(20),
    p_amount DECIMAL(15,2),
    p_company_code VARCHAR(10) DEFAULT NULL,
    p_plant_code VARCHAR(10) DEFAULT NULL,
    p_department_code VARCHAR(20) DEFAULT NULL,
    p_project_code VARCHAR(20) DEFAULT NULL,
    p_additional_context JSONB DEFAULT '{}'
)
RETURNS TABLE(
    level_number INTEGER,
    level_name VARCHAR(100),
    approver_role VARCHAR(50),
    approval_type_scope VARCHAR(20),
    routing_reason TEXT,
    organizational_context JSONB
) AS $$
BEGIN
    -- Priority: Project-specific > Department-specific > Global
    -- Enhanced with explicit organizational context
    
    -- 1. Project-specific approval (5% of cases)
    IF p_project_code IS NOT NULL AND EXISTS (
        SELECT 1 FROM flexible_approval_levels 
        WHERE customer_id = p_customer_id 
        AND approval_object_type = p_object_type
        AND approval_type_scope = 'PROJECT'
        AND (project_code = p_project_code OR project_code IS NULL)
        AND p_amount >= amount_threshold_min 
        AND p_amount <= amount_threshold_max
        AND is_active = true
    ) THEN
        RETURN QUERY
        SELECT 
            fal.level_number,
            fal.level_name,
            fal.approver_role,
            fal.approval_type_scope,
            'Project-specific approval for ' || COALESCE(p_project_code, 'project') as routing_reason,
            jsonb_build_object(
                'company_code', p_company_code,
                'plant_code', p_plant_code,
                'project_code', p_project_code,
                'amount', p_amount
            ) as organizational_context
        FROM flexible_approval_levels fal
        WHERE fal.customer_id = p_customer_id
        AND fal.approval_object_type = p_object_type
        AND fal.approval_type_scope = 'PROJECT'
        AND (fal.project_code = p_project_code OR fal.project_code IS NULL)
        AND p_amount >= fal.amount_threshold_min
        AND p_amount <= fal.amount_threshold_max
        AND fal.is_active = true
        ORDER BY fal.level_number;
        RETURN;
    END IF;
    
    -- 2. Department-specific approval (15% of cases)
    IF p_department_code IS NOT NULL AND EXISTS (
        SELECT 1 FROM flexible_approval_levels 
        WHERE customer_id = p_customer_id 
        AND approval_object_type = p_object_type
        AND approval_type_scope = 'DEPARTMENT'
        AND department_code = p_department_code
        AND p_amount >= amount_threshold_min 
        AND p_amount <= amount_threshold_max
        AND is_active = true
    ) THEN
        RETURN QUERY
        SELECT 
            fal.level_number,
            fal.level_name,
            fal.approver_role,
            fal.approval_type_scope,
            'Department-specific approval for ' || p_department_code as routing_reason,
            jsonb_build_object(
                'company_code', p_company_code,
                'plant_code', p_plant_code,
                'department_code', p_department_code,
                'amount', p_amount
            ) as organizational_context
        FROM flexible_approval_levels fal
        WHERE fal.customer_id = p_customer_id
        AND fal.approval_object_type = p_object_type
        AND fal.approval_type_scope = 'DEPARTMENT'
        AND fal.department_code = p_department_code
        AND p_amount >= fal.amount_threshold_min
        AND p_amount <= fal.amount_threshold_max
        AND fal.is_active = true
        ORDER BY fal.level_number;
        RETURN;
    END IF;
    
    -- 3. Global approval (80% of cases)
    RETURN QUERY
    SELECT 
        fal.level_number,
        fal.level_name,
        fal.approver_role,
        fal.approval_type_scope,
        'Standard global approval workflow' as routing_reason,
        jsonb_build_object(
            'company_code', p_company_code,
            'plant_code', p_plant_code,
            'amount', p_amount,
            'object_type', p_object_type
        ) as organizational_context
    FROM flexible_approval_levels fal
    WHERE fal.customer_id = p_customer_id
    AND fal.approval_object_type = p_object_type
    AND fal.approval_type_scope = 'GLOBAL'
    AND p_amount >= fal.amount_threshold_min
    AND p_amount <= fal.amount_threshold_max
    AND fal.is_active = true
    ORDER BY fal.level_number;
END;
$$ LANGUAGE plpgsql;

-- 8. Test Enhanced Approval Engine
SELECT 'ENHANCED APPROVAL ENGINE READY' as status;

-- Test different object types
SELECT 'Testing MR (Material Request):' as test_case;
SELECT * FROM get_enhanced_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'MR',
    25000.00,
    'C001',
    'B001',
    'CONSTRUCTION'
);

SELECT 'Testing PO (Purchase Order):' as test_case;
SELECT * FROM get_enhanced_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'PO',
    150000.00,
    'C001',
    'B001',
    'PROCUREMENT'
);

SELECT 'ENHANCED APPROVAL ENGINE CONFIGURATION COMPLETE' as result;