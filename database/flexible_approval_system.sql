-- Flexible Customer-Configurable Approval System
-- Allows customers to define their own approval workflows for MR/PR/PO

-- 1. Customer approval configuration master
CREATE TABLE customer_approval_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL, -- Links to customer/tenant
  config_name VARCHAR(100) NOT NULL,
  document_type VARCHAR(20) NOT NULL CHECK (document_type IN ('MATERIAL_REQ', 'PURCHASE_REQ', 'PURCHASE_ORDER', 'RESERVATION')),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(customer_id, config_name, document_type)
);

-- 2. Flexible approval criteria (rule engine)
CREATE TABLE approval_criteria (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  config_id UUID NOT NULL REFERENCES customer_approval_config(id) ON DELETE CASCADE,
  criteria_name VARCHAR(100) NOT NULL,
  criteria_type VARCHAR(20) NOT NULL CHECK (criteria_type IN ('AMOUNT', 'CATEGORY', 'DEPARTMENT', 'PROJECT', 'VENDOR', 'URGENCY', 'CUSTOM')),
  operator VARCHAR(10) NOT NULL CHECK (operator IN ('=', '!=', '>', '>=', '<', '<=', 'IN', 'NOT_IN', 'CONTAINS', 'REGEX')),
  criteria_value TEXT NOT NULL, -- JSON for complex values
  priority INTEGER DEFAULT 1, -- Higher number = higher priority
  is_active BOOLEAN DEFAULT true
);

-- 3. Approval levels (unlimited levels)
CREATE TABLE approval_levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  config_id UUID NOT NULL REFERENCES customer_approval_config(id) ON DELETE CASCADE,
  level_number INTEGER NOT NULL,
  level_name VARCHAR(100) NOT NULL,
  approver_type VARCHAR(20) NOT NULL CHECK (approver_type IN ('ROLE', 'USER', 'DEPARTMENT', 'EXTERNAL', 'AUTO')),
  approver_identifier VARCHAR(100) NOT NULL, -- Role name, user ID, department code, etc.
  approval_method VARCHAR(20) DEFAULT 'MANUAL' CHECK (approval_method IN ('MANUAL', 'AUTO', 'DELEGATION', 'PARALLEL', 'ANY_ONE')),
  timeout_hours INTEGER DEFAULT 24, -- Auto-escalation timeout
  escalation_action VARCHAR(20) DEFAULT 'ESCALATE' CHECK (escalation_action IN ('ESCALATE', 'AUTO_APPROVE', 'REJECT', 'NOTIFY')),
  is_mandatory BOOLEAN DEFAULT true,
  conditions JSONB, -- Additional conditions for this level
  UNIQUE(config_id, level_number)
);

-- 4. Dynamic approval routing
CREATE TABLE approval_routing_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  config_id UUID NOT NULL REFERENCES customer_approval_config(id) ON DELETE CASCADE,
  rule_name VARCHAR(100) NOT NULL,
  condition_expression TEXT NOT NULL, -- SQL-like expression
  target_level INTEGER NOT NULL,
  action VARCHAR(20) NOT NULL CHECK (action IN ('ROUTE_TO', 'SKIP_TO', 'PARALLEL', 'STOP', 'AUTO_APPROVE')),
  is_active BOOLEAN DEFAULT true
);

-- 5. Customer-specific approval templates
CREATE TABLE approval_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  template_name VARCHAR(100) NOT NULL,
  template_type VARCHAR(20) NOT NULL,
  description TEXT,
  template_config JSONB NOT NULL, -- Complete approval configuration
  is_public BOOLEAN DEFAULT false, -- Can other customers use this template?
  created_by UUID NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(customer_id, template_name)
);

-- 6. Approval execution tracking
CREATE TABLE approval_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL, -- Links to material_requests
  config_id UUID NOT NULL REFERENCES customer_approval_config(id),
  current_level INTEGER NOT NULL DEFAULT 1,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'ESCALATED', 'TIMEOUT')),
  started_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  total_levels INTEGER NOT NULL,
  execution_path JSONB -- Track the actual path taken
);

-- 7. Individual approval steps
CREATE TABLE approval_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  execution_id UUID NOT NULL REFERENCES approval_executions(id) ON DELETE CASCADE,
  level_number INTEGER NOT NULL,
  approver_id UUID, -- Actual approver (user ID)
  approver_role VARCHAR(50),
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'DELEGATED', 'TIMEOUT')),
  assigned_at TIMESTAMP DEFAULT NOW(),
  responded_at TIMESTAMP,
  comments TEXT,
  timeout_at TIMESTAMP,
  delegation_to UUID -- If delegated to another user
);

-- 8. Sample customer configurations

-- Customer 1: Simple 3-level approval
INSERT INTO customer_approval_config (customer_id, config_name, document_type) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'Standard MR Approval', 'MATERIAL_REQ'),
('550e8400-e29b-41d4-a716-446655440001', 'Standard PR Approval', 'PURCHASE_REQ'),
('550e8400-e29b-41d4-a716-446655440001', 'PO Approval Workflow', 'PURCHASE_ORDER');

-- Criteria for Customer 1 (Amount-based)
INSERT INTO approval_criteria (config_id, criteria_name, criteria_type, operator, criteria_value) 
SELECT id, 'Amount Threshold', 'AMOUNT', '>=', '0' FROM customer_approval_config WHERE config_name = 'Standard MR Approval';

-- Levels for Customer 1
INSERT INTO approval_levels (config_id, level_number, level_name, approver_type, approver_identifier)
SELECT id, 1, 'Supervisor Approval', 'ROLE', 'SUPERVISOR' FROM customer_approval_config WHERE config_name = 'Standard MR Approval'
UNION ALL
SELECT id, 2, 'Manager Approval', 'ROLE', 'MANAGER' FROM customer_approval_config WHERE config_name = 'Standard MR Approval'
UNION ALL
SELECT id, 3, 'Director Approval', 'ROLE', 'DIRECTOR' FROM customer_approval_config WHERE config_name = 'Standard MR Approval';

-- Customer 2: Complex multi-criteria approval
INSERT INTO customer_approval_config (customer_id, config_name, document_type) VALUES
('550e8400-e29b-41d4-a716-446655440002', 'Complex PR Approval', 'PURCHASE_REQ');

-- Multiple criteria for Customer 2
INSERT INTO approval_criteria (config_id, criteria_name, criteria_type, operator, criteria_value, priority) 
SELECT id, 'High Value Items', 'AMOUNT', '>', '50000', 1 FROM customer_approval_config WHERE config_name = 'Complex PR Approval'
UNION ALL
SELECT id, 'Construction Materials', 'CATEGORY', 'IN', '["STEEL", "CONCRETE", "EQUIPMENT"]', 2 FROM customer_approval_config WHERE config_name = 'Complex PR Approval'
UNION ALL
SELECT id, 'Emergency Requests', 'URGENCY', '=', 'URGENT', 3 FROM customer_approval_config WHERE config_name = 'Complex PR Approval';

-- Dynamic routing rules for Customer 2
INSERT INTO approval_routing_rules (config_id, rule_name, condition_expression, target_level, action)
SELECT id, 'Emergency Fast Track', 'urgency = "URGENT" AND amount < 25000', 2, 'SKIP_TO' FROM customer_approval_config WHERE config_name = 'Complex PR Approval'
UNION ALL
SELECT id, 'High Value Route', 'amount > 100000', 4, 'ROUTE_TO' FROM customer_approval_config WHERE config_name = 'Complex PR Approval';

-- 9. Pre-built approval templates for common scenarios
INSERT INTO approval_templates (customer_id, template_name, template_type, description, template_config, is_public, created_by) VALUES
-- Simple 2-level approval
('00000000-0000-0000-0000-000000000000', 'Simple 2-Level', 'BASIC', 'Supervisor → Manager approval', 
 '{"levels": [{"level": 1, "role": "SUPERVISOR", "limit": 10000}, {"level": 2, "role": "MANAGER", "limit": 50000}]}', true, '00000000-0000-0000-0000-000000000000'),

-- Department-based approval
('00000000-0000-0000-0000-000000000000', 'Department Based', 'DEPARTMENT', 'Route based on requesting department',
 '{"routing": "department", "levels": [{"level": 1, "type": "DEPT_HEAD"}, {"level": 2, "type": "DEPT_MANAGER"}]}', true, '00000000-0000-0000-0000-000000000000'),

-- Project-based approval
('00000000-0000-0000-0000-000000000000', 'Project Based', 'PROJECT', 'Route based on project assignment',
 '{"routing": "project", "levels": [{"level": 1, "type": "PROJECT_MANAGER"}, {"level": 2, "type": "PROJECT_DIRECTOR"}]}', true, '00000000-0000-0000-0000-000000000000'),

-- Emergency fast-track
('00000000-0000-0000-0000-000000000000', 'Emergency Fast Track', 'EMERGENCY', 'Streamlined approval for urgent requests',
 '{"fast_track": true, "levels": [{"level": 1, "role": "DUTY_MANAGER", "timeout": 2}]}', true, '00000000-0000-0000-0000-000000000000');

-- 10. Configuration validation function
CREATE OR REPLACE FUNCTION validate_approval_config(p_config_id UUID)
RETURNS TABLE (
  is_valid BOOLEAN,
  validation_errors TEXT[]
) AS $$
DECLARE
  error_list TEXT[] := '{}';
  level_count INTEGER;
  criteria_count INTEGER;
BEGIN
  -- Check if levels exist
  SELECT COUNT(*) INTO level_count FROM approval_levels WHERE config_id = p_config_id;
  IF level_count = 0 THEN
    error_list := array_append(error_list, 'No approval levels defined');
  END IF;
  
  -- Check if criteria exist
  SELECT COUNT(*) INTO criteria_count FROM approval_criteria WHERE config_id = p_config_id;
  IF criteria_count = 0 THEN
    error_list := array_append(error_list, 'No approval criteria defined');
  END IF;
  
  -- Check for level sequence gaps
  IF EXISTS (
    SELECT 1 FROM approval_levels 
    WHERE config_id = p_config_id 
    GROUP BY config_id 
    HAVING MAX(level_number) != COUNT(*)
  ) THEN
    error_list := array_append(error_list, 'Level sequence has gaps');
  END IF;
  
  RETURN QUERY SELECT 
    array_length(error_list, 1) IS NULL OR array_length(error_list, 1) = 0,
    error_list;
END;
$$ LANGUAGE plpgsql;

-- 11. Indexes for performance
CREATE INDEX idx_approval_criteria_config ON approval_criteria(config_id);
CREATE INDEX idx_approval_levels_config ON approval_levels(config_id, level_number);
CREATE INDEX idx_approval_executions_request ON approval_executions(request_id);
CREATE INDEX idx_approval_steps_execution ON approval_steps(execution_id, level_number);
CREATE INDEX idx_approval_steps_approver ON approval_steps(approver_id, status);

COMMENT ON TABLE customer_approval_config IS 'Customer-specific approval workflow configurations';
COMMENT ON TABLE approval_criteria IS 'Flexible criteria for triggering different approval paths';
COMMENT ON TABLE approval_levels IS 'Unlimited approval levels with various approver types';
COMMENT ON TABLE approval_routing_rules IS 'Dynamic routing rules for complex approval scenarios';
COMMENT ON TABLE approval_templates IS 'Pre-built approval templates for quick setup';