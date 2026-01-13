-- Detailed Approval Workflow Configuration
-- Shows how approval routing works based on business rules

-- 1. Enhanced approval workflows with detailed rules
INSERT INTO approval_workflows (
  workflow_name, 
  request_type, 
  company_code, 
  material_category, 
  amount_threshold,
  level_1_approver_role, 
  level_1_amount_limit,
  level_2_approver_role, 
  level_2_amount_limit,
  level_3_approver_role, 
  level_3_amount_limit
) VALUES
-- Material Requests (Low Value)
('Standard Material Request', 'MATERIAL_REQ', 'C001', NULL, 0, 'SUPERVISOR', 5000, 'MANAGER', 25000, 'DIRECTOR', 100000),

-- Material Reservations (Project-Based)
('Project Material Reservation', 'RESERVATION', 'C001', NULL, 0, 'PROJECT_MANAGER', 15000, 'OPERATIONS_MANAGER', 50000, 'GENERAL_MANAGER', 200000),

-- Purchase Requisitions (Procurement)
('Standard Purchase Requisition', 'PURCHASE_REQ', 'C001', NULL, 1000, 'PROCUREMENT_OFFICER', 10000, 'PROCUREMENT_MANAGER', 50000, 'CFO', 500000),

-- High-Value Construction Materials
('Construction Materials - High Value', 'PURCHASE_REQ', 'C001', 'CONSTRUCTION', 25000, 'SITE_ENGINEER', 50000, 'PROJECT_MANAGER', 100000, 'OPERATIONS_DIRECTOR', 1000000),

-- Emergency Requests (Fast Track)
('Emergency Material Request', 'MATERIAL_REQ', 'C001', NULL, 0, 'DUTY_MANAGER', 10000, 'OPERATIONS_MANAGER', 50000, NULL, NULL),

-- Capital Equipment (Special Approval)
('Capital Equipment Purchase', 'PURCHASE_REQ', 'C001', 'EQUIPMENT', 50000, 'TECHNICAL_MANAGER', 100000, 'GENERAL_MANAGER', 500000, 'BOARD_APPROVAL', 999999999);

-- 2. Workflow routing logic examples
SELECT 'WORKFLOW ROUTING EXAMPLES:' as info;

-- Example 1: $3,000 Material Request
SELECT 
  'Example 1: $3,000 Material Request' as scenario,
  workflow_name,
  level_1_approver_role as "First Approver",
  CASE 
    WHEN 3000 <= level_1_amount_limit THEN 'APPROVED AT LEVEL 1'
    WHEN 3000 <= level_2_amount_limit THEN 'REQUIRES LEVEL 2: ' || level_2_approver_role
    ELSE 'REQUIRES LEVEL 3: ' || level_3_approver_role
  END as "Approval Decision"
FROM approval_workflows 
WHERE request_type = 'MATERIAL_REQ' 
  AND company_code = 'C001' 
  AND material_category IS NULL
  AND 3000 >= amount_threshold
ORDER BY amount_threshold DESC 
LIMIT 1;

-- Example 2: $75,000 Construction Material PR
SELECT 
  'Example 2: $75,000 Construction Material PR' as scenario,
  workflow_name,
  level_1_approver_role as "First Approver",
  CASE 
    WHEN 75000 <= level_1_amount_limit THEN 'APPROVED AT LEVEL 1'
    WHEN 75000 <= level_2_amount_limit THEN 'REQUIRES LEVEL 2: ' || level_2_approver_role
    ELSE 'REQUIRES LEVEL 3: ' || level_3_approver_role
  END as "Approval Decision"
FROM approval_workflows 
WHERE request_type = 'PURCHASE_REQ' 
  AND company_code = 'C001' 
  AND (material_category = 'CONSTRUCTION' OR material_category IS NULL)
  AND 75000 >= amount_threshold
ORDER BY material_category DESC NULLS LAST, amount_threshold DESC 
LIMIT 1;

-- 3. Approval workflow states and transitions
SELECT 'APPROVAL WORKFLOW STATES:' as info;

-- Workflow state transitions
CREATE TABLE IF NOT EXISTS workflow_states (
  state_code VARCHAR(20) PRIMARY KEY,
  state_name VARCHAR(100) NOT NULL,
  description TEXT,
  is_final_state BOOLEAN DEFAULT false
);

INSERT INTO workflow_states (state_code, state_name, description, is_final_state) VALUES
('DRAFT', 'Draft', 'Request being prepared by requestor', false),
('SUBMITTED', 'Submitted', 'Request submitted for approval', false),
('LEVEL_1_PENDING', 'Level 1 Pending', 'Waiting for first level approval', false),
('LEVEL_1_APPROVED', 'Level 1 Approved', 'Approved by first level, may need higher approval', false),
('LEVEL_2_PENDING', 'Level 2 Pending', 'Waiting for second level approval', false),
('LEVEL_2_APPROVED', 'Level 2 Approved', 'Approved by second level, may need final approval', false),
('LEVEL_3_PENDING', 'Level 3 Pending', 'Waiting for final level approval', false),
('FULLY_APPROVED', 'Fully Approved', 'All required approvals completed', true),
('REJECTED', 'Rejected', 'Request rejected at any level', true),
('CANCELLED', 'Cancelled', 'Request cancelled by requestor', true),
('CONVERTED', 'Converted', 'Material request converted to PR/PO', true);

-- 4. Approval delegation rules
CREATE TABLE IF NOT EXISTS approval_delegations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  delegator_role VARCHAR(50) NOT NULL,
  delegate_role VARCHAR(50) NOT NULL,
  company_code VARCHAR(31) NOT NULL,
  effective_from DATE NOT NULL,
  effective_to DATE,
  max_amount DECIMAL(15,2),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Sample delegations
INSERT INTO approval_delegations (delegator_role, delegate_role, company_code, effective_from, effective_to, max_amount) VALUES
('MANAGER', 'ASSISTANT_MANAGER', 'C001', '2024-01-01', '2024-12-31', 25000),
('DIRECTOR', 'MANAGER', 'C001', '2024-01-01', '2024-12-31', 100000);

-- 5. Approval workflow execution logic
SELECT 'APPROVAL EXECUTION LOGIC:' as info;

-- Function to determine next approver
CREATE OR REPLACE FUNCTION get_next_approver(
  p_request_type VARCHAR(20),
  p_company_code VARCHAR(31),
  p_material_category VARCHAR(50),
  p_total_amount DECIMAL(15,2),
  p_current_level INTEGER DEFAULT 1
) RETURNS TABLE (
  approver_role VARCHAR(50),
  amount_limit DECIMAL(15,2),
  workflow_name VARCHAR(100)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    CASE 
      WHEN p_current_level = 1 THEN aw.level_1_approver_role
      WHEN p_current_level = 2 THEN aw.level_2_approver_role
      WHEN p_current_level = 3 THEN aw.level_3_approver_role
    END as approver_role,
    CASE 
      WHEN p_current_level = 1 THEN aw.level_1_amount_limit
      WHEN p_current_level = 2 THEN aw.level_2_amount_limit
      WHEN p_current_level = 3 THEN aw.level_3_amount_limit
    END as amount_limit,
    aw.workflow_name
  FROM approval_workflows aw
  WHERE aw.request_type = p_request_type
    AND aw.company_code = p_company_code
    AND (aw.material_category = p_material_category OR aw.material_category IS NULL)
    AND p_total_amount >= aw.amount_threshold
    AND aw.is_active = true
  ORDER BY 
    CASE WHEN aw.material_category IS NOT NULL THEN 1 ELSE 2 END,
    aw.amount_threshold DESC
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Test the function
SELECT 'NEXT APPROVER EXAMPLES:' as info;

-- Test 1: $15,000 Material Request
SELECT 
  '$15,000 Material Request - Level 1:' as test,
  approver_role,
  amount_limit,
  workflow_name
FROM get_next_approver('MATERIAL_REQ', 'C001', NULL, 15000, 1);

-- Test 2: Same request needs Level 2?
SELECT 
  '$15,000 Material Request - Level 2:' as test,
  approver_role,
  amount_limit,
  workflow_name
FROM get_next_approver('MATERIAL_REQ', 'C001', NULL, 15000, 2);

COMMENT ON FUNCTION get_next_approver IS 'Determines the next approver based on request type, amount, and current approval level';
COMMENT ON TABLE approval_workflows IS 'Configurable approval workflows with multi-level approval chains';
COMMENT ON TABLE workflow_states IS 'Defines all possible states in the approval workflow';
COMMENT ON TABLE approval_delegations IS 'Temporary delegation of approval authority between roles';