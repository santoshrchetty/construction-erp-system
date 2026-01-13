-- Enhanced Approval Configuration with Department and Project Support
-- Add department and project dimensions to approval workflows

-- Add columns to flexible_approval_levels for department and project filtering
ALTER TABLE flexible_approval_levels 
ADD COLUMN department_code VARCHAR(20),
ADD COLUMN project_code VARCHAR(20),
ADD COLUMN plant_code VARCHAR(10);

-- Add columns to customer_approval_configuration for scope definition
ALTER TABLE customer_approval_configuration
ADD COLUMN scope_type VARCHAR(20) DEFAULT 'GLOBAL' CHECK (scope_type IN ('GLOBAL', 'DEPARTMENT', 'PROJECT', 'PLANT')),
ADD COLUMN department_code VARCHAR(20),
ADD COLUMN project_code VARCHAR(20),
ADD COLUMN plant_code VARCHAR(10);

-- Create department-specific approval configuration
INSERT INTO customer_approval_configuration (
    customer_id, document_type, config_name, scope_type, department_code, is_template_based
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 'Construction Dept Config', 'DEPARTMENT', 'CONSTRUCTION', false
),
(
    '550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 'Engineering Dept Config', 'DEPARTMENT', 'ENGINEERING', false
);

-- Create department-specific approval levels
INSERT INTO flexible_approval_levels (
    customer_id, document_type, level_number, level_name, 
    amount_threshold_min, amount_threshold_max, approver_role,
    department_code
) VALUES 
-- Construction Department (Higher thresholds, more levels)
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 1, 'Site Supervisor', 0, 50000, 'SITE_SUPERVISOR', 'CONSTRUCTION'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 2, 'Construction Manager', 50001, 200000, 'CONSTRUCTION_MANAGER', 'CONSTRUCTION'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 3, 'Project Director', 200001, 999999999, 'PROJECT_DIRECTOR', 'CONSTRUCTION'),

-- Engineering Department (Lower thresholds, fewer levels)
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 1, 'Lead Engineer', 0, 25000, 'LEAD_ENGINEER', 'ENGINEERING'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 2, 'Engineering Manager', 25001, 999999999, 'ENGINEERING_MANAGER', 'ENGINEERING');

-- Create project-specific approval configuration
INSERT INTO customer_approval_configuration (
    customer_id, document_type, config_name, scope_type, project_code, is_template_based
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 'Highway Project Config', 'PROJECT', 'PRJ-HWY-001', false
),
(
    '550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 'Bridge Project Config', 'PROJECT', 'PRJ-BRG-002', false
);

-- Create project-specific approval levels
INSERT INTO flexible_approval_levels (
    customer_id, document_type, level_number, level_name, 
    amount_threshold_min, amount_threshold_max, approver_role,
    project_code
) VALUES 
-- Highway Project (Fast-track approvals)
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 1, 'Highway Supervisor', 0, 100000, 'HIGHWAY_SUPERVISOR', 'PRJ-HWY-001'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 2, 'Highway Manager', 100001, 999999999, 'HIGHWAY_MANAGER', 'PRJ-HWY-001'),

-- Bridge Project (Strict approvals)
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 1, 'Bridge Engineer', 0, 20000, 'BRIDGE_ENGINEER', 'PRJ-BRG-002'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 2, 'Structural Manager', 20001, 75000, 'STRUCTURAL_MANAGER', 'PRJ-BRG-002'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 3, 'Bridge Director', 75001, 999999999, 'BRIDGE_DIRECTOR', 'PRJ-BRG-002');

-- Enhanced approval path function with department and project support
CREATE OR REPLACE FUNCTION get_enhanced_approval_path(
    p_customer_id UUID,
    p_document_type VARCHAR(50),
    p_amount DECIMAL(15,2),
    p_department_code VARCHAR(20) DEFAULT NULL,
    p_project_code VARCHAR(20) DEFAULT NULL,
    p_plant_code VARCHAR(10) DEFAULT NULL
)
RETURNS TABLE(
    level_number INTEGER,
    level_name VARCHAR(100),
    approver_role VARCHAR(50),
    is_required BOOLEAN,
    approval_type VARCHAR(20),
    scope_type VARCHAR(20)
) AS $$
BEGIN
    -- Priority order: Project > Department > Global
    RETURN QUERY
    SELECT 
        fal.level_number,
        fal.level_name,
        fal.approver_role,
        fal.is_required,
        fal.approval_type,
        CASE 
            WHEN fal.project_code IS NOT NULL THEN 'PROJECT'
            WHEN fal.department_code IS NOT NULL THEN 'DEPARTMENT'
            ELSE 'GLOBAL'
        END as scope_type
    FROM flexible_approval_levels fal
    WHERE fal.customer_id = p_customer_id
    AND fal.document_type = p_document_type
    AND fal.is_active = true
    AND p_amount >= fal.amount_threshold_min
    AND p_amount <= fal.amount_threshold_max
    AND (
        -- Project-specific match (highest priority)
        (p_project_code IS NOT NULL AND fal.project_code = p_project_code)
        OR
        -- Department-specific match (medium priority)
        (p_project_code IS NULL AND p_department_code IS NOT NULL AND fal.department_code = p_department_code)
        OR
        -- Global match (lowest priority)
        (p_project_code IS NULL AND p_department_code IS NULL AND fal.project_code IS NULL AND fal.department_code IS NULL)
    )
    ORDER BY fal.level_number;
END;
$$ LANGUAGE plpgsql;

-- Test enhanced approval paths
SELECT 'ENHANCED APPROVAL PATH TESTS:' as info;

-- Test Construction Department approval
SELECT 'Construction Department ($75,000):' as test_case;
SELECT * FROM get_enhanced_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'MATERIAL_REQ',
    75000,
    'CONSTRUCTION'
);

-- Test Engineering Department approval
SELECT 'Engineering Department ($30,000):' as test_case;
SELECT * FROM get_enhanced_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'MATERIAL_REQ',
    30000,
    'ENGINEERING'
);

-- Test Highway Project approval
SELECT 'Highway Project ($150,000):' as test_case;
SELECT * FROM get_enhanced_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'MATERIAL_REQ',
    150000,
    NULL,
    'PRJ-HWY-001'
);

-- Test Bridge Project approval
SELECT 'Bridge Project ($50,000):' as test_case;
SELECT * FROM get_enhanced_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'MATERIAL_REQ',
    50000,
    NULL,
    'PRJ-BRG-002'
);

SELECT 'ENHANCED APPROVAL CONFIGURATION COMPLETED' as result;