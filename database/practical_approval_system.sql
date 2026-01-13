-- Practical Approval System: Global Defaults + Selective Project Overrides
-- 80% Global, 15% Department, 5% Project-specific

-- Add optional scope columns (nullable for backward compatibility)
ALTER TABLE flexible_approval_levels 
ADD COLUMN IF NOT EXISTS scope_type VARCHAR(20) DEFAULT 'GLOBAL',
ADD COLUMN IF NOT EXISTS department_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS project_code VARCHAR(20);

-- Clean existing test data (proper order to avoid FK violations)
DELETE FROM approval_actions WHERE execution_id IN (
  SELECT ae.id FROM approval_executions ae
  JOIN customer_approval_configuration cac ON ae.config_id = cac.id
  WHERE cac.customer_id = '550e8400-e29b-41d4-a716-446655440001'
);

DELETE FROM approval_executions WHERE config_id IN (
  SELECT id FROM customer_approval_configuration 
  WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
);

DELETE FROM material_requests WHERE requested_by = '550e8400-e29b-41d4-a716-446655440001';

DELETE FROM flexible_approval_levels WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001';

DELETE FROM customer_approval_configuration WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001';

-- 1. GLOBAL APPROVAL (80% of cases) - Default for most requests
INSERT INTO customer_approval_configuration (
    customer_id, document_type, config_name, is_template_based
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 'Global Standard Approval', false
);

INSERT INTO flexible_approval_levels (
    customer_id, document_type, level_number, level_name, 
    amount_threshold_min, amount_threshold_max, approver_role, scope_type
) VALUES 
-- Standard global workflow
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 1, 'Department Manager', 0, 25000, 'DEPT_MANAGER', 'GLOBAL'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 2, 'Finance Manager', 25001, 100000, 'FINANCE_MANAGER', 'GLOBAL'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 3, 'General Manager', 100001, 999999999, 'GENERAL_MANAGER', 'GLOBAL');

-- 2. DEPARTMENT-SPECIFIC (15% of cases) - For specialized departments
INSERT INTO flexible_approval_levels (
    customer_id, document_type, level_number, level_name, 
    amount_threshold_min, amount_threshold_max, approver_role, 
    scope_type, department_code
) VALUES 
-- Construction Department (higher thresholds due to material costs)
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 10, 'Site Supervisor', 0, 50000, 'SITE_SUPERVISOR', 'DEPARTMENT', 'CONSTRUCTION'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 11, 'Construction Manager', 50001, 999999999, 'CONSTRUCTION_MANAGER', 'DEPARTMENT', 'CONSTRUCTION'),

-- Safety Department (strict controls)
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 20, 'Safety Officer', 0, 10000, 'SAFETY_OFFICER', 'DEPARTMENT', 'SAFETY'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 21, 'Operations Manager', 10001, 999999999, 'OPERATIONS_MANAGER', 'DEPARTMENT', 'SAFETY');

-- 3. PROJECT-SPECIFIC (5% of cases) - Only for critical/high-value projects
INSERT INTO flexible_approval_levels (
    customer_id, document_type, level_number, level_name, 
    amount_threshold_min, amount_threshold_max, approver_role, 
    scope_type, project_code
) VALUES 
-- Critical Infrastructure Project (strict controls)
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 30, 'Project Manager', 50000, 200000, 'PROJECT_MANAGER', 'PROJECT', 'CRITICAL-INFRA-001'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 31, 'Project Director', 200001, 500000, 'PROJECT_DIRECTOR', 'PROJECT', 'CRITICAL-INFRA-001'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 32, 'CEO Approval', 500001, 999999999, 'CEO', 'PROJECT', 'CRITICAL-INFRA-001');

-- Smart approval routing function
CREATE OR REPLACE FUNCTION get_smart_approval_path(
    p_customer_id UUID,
    p_document_type VARCHAR(50),
    p_amount DECIMAL(15,2),
    p_department_code VARCHAR(20) DEFAULT NULL,
    p_project_code VARCHAR(20) DEFAULT NULL
)
RETURNS TABLE(
    level_number INTEGER,
    level_name VARCHAR(100),
    approver_role VARCHAR(50),
    scope_type VARCHAR(20),
    routing_reason TEXT
) AS $$
BEGIN
    -- Priority: Project-specific > Department-specific > Global
    
    -- 1. Check for project-specific approval (5% of cases)
    IF EXISTS (
        SELECT 1 FROM flexible_approval_levels 
        WHERE customer_id = p_customer_id 
        AND document_type = p_document_type
        AND project_code = p_project_code
        AND p_amount >= amount_threshold_min 
        AND p_amount <= amount_threshold_max
        AND is_active = true
    ) THEN
        RETURN QUERY
        SELECT 
            fal.level_number,
            fal.level_name,
            fal.approver_role,
            fal.scope_type,
            'Project-specific approval required for ' || p_project_code as routing_reason
        FROM flexible_approval_levels fal
        WHERE fal.customer_id = p_customer_id
        AND fal.document_type = p_document_type
        AND fal.project_code = p_project_code
        AND p_amount >= fal.amount_threshold_min
        AND p_amount <= fal.amount_threshold_max
        AND fal.is_active = true
        ORDER BY fal.level_number;
        RETURN;
    END IF;
    
    -- 2. Check for department-specific approval (15% of cases)
    IF p_department_code IS NOT NULL AND EXISTS (
        SELECT 1 FROM flexible_approval_levels 
        WHERE customer_id = p_customer_id 
        AND document_type = p_document_type
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
            fal.scope_type,
            'Department-specific approval for ' || p_department_code as routing_reason
        FROM flexible_approval_levels fal
        WHERE fal.customer_id = p_customer_id
        AND fal.document_type = p_document_type
        AND fal.department_code = p_department_code
        AND p_amount >= fal.amount_threshold_min
        AND p_amount <= fal.amount_threshold_max
        AND fal.is_active = true
        ORDER BY fal.level_number;
        RETURN;
    END IF;
    
    -- 3. Default to global approval (80% of cases)
    RETURN QUERY
    SELECT 
        fal.level_number,
        fal.level_name,
        fal.approver_role,
        fal.scope_type,
        'Standard global approval workflow' as routing_reason
    FROM flexible_approval_levels fal
    WHERE fal.customer_id = p_customer_id
    AND fal.document_type = p_document_type
    AND fal.scope_type = 'GLOBAL'
    AND p_amount >= fal.amount_threshold_min
    AND p_amount <= fal.amount_threshold_max
    AND fal.is_active = true
    ORDER BY fal.level_number;
END;
$$ LANGUAGE plpgsql;

-- Test realistic scenarios
SELECT 'REALISTIC APPROVAL SCENARIOS:' as info;

-- Scenario 1: Standard office supplies ($2,000) - Global
SELECT 'Office Supplies ($2,000) - Should use Global:' as test_case;
SELECT * FROM get_smart_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'MATERIAL_REQ',
    2000
);

-- Scenario 2: Construction materials ($75,000) - Department
SELECT 'Construction Materials ($75,000) - Should use Department:' as test_case;
SELECT * FROM get_smart_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'MATERIAL_REQ',
    75000,
    'CONSTRUCTION'
);

-- Scenario 3: Safety equipment ($15,000) - Department (strict)
SELECT 'Safety Equipment ($15,000) - Should use Department:' as test_case;
SELECT * FROM get_smart_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'MATERIAL_REQ',
    15000,
    'SAFETY'
);

-- Scenario 4: Critical project materials ($300,000) - Project-specific
SELECT 'Critical Project Materials ($300,000) - Should use Project:' as test_case;
SELECT * FROM get_smart_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'MATERIAL_REQ',
    300000,
    'CONSTRUCTION',
    'CRITICAL-INFRA-001'
);

-- Scenario 5: Regular equipment ($40,000) - Global (no special rules)
SELECT 'Regular Equipment ($40,000) - Should use Global:' as test_case;
SELECT * FROM get_smart_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'MATERIAL_REQ',
    40000
);

SELECT 'PRACTICAL APPROVAL SYSTEM READY' as result;