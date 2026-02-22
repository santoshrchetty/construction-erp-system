-- Minimal Flexible Workflow Schema for Material Request Approval
-- SAP Fiori-style single-step-at-a-time approval

-- 1. Workflow Definitions (Templates)
CREATE TABLE IF NOT EXISTS workflow_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_code VARCHAR(50) UNIQUE NOT NULL,
  workflow_name VARCHAR(200) NOT NULL,
  object_type VARCHAR(50) NOT NULL, -- 'MATERIAL_REQUEST', 'PURCHASE_REQ', 'PURCHASE_ORDER'
  description TEXT,
  activation_conditions JSONB, -- Optional conditions for workflow selection
  is_active BOOLEAN DEFAULT true,
  tenant_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Workflow Steps (Step Definitions)
CREATE TABLE IF NOT EXISTS workflow_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_id UUID NOT NULL REFERENCES workflow_definitions(id) ON DELETE CASCADE,
  step_sequence INTEGER NOT NULL,
  step_code VARCHAR(50) NOT NULL,
  step_name VARCHAR(200) NOT NULL,
  step_type VARCHAR(20) DEFAULT 'APPROVAL', -- 'APPROVAL', 'NOTIFICATION', 'REVIEW'
  completion_rule VARCHAR(20) DEFAULT 'ANY', -- 'ALL', 'ANY', 'MIN_N'
  min_approvals INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(workflow_id, step_sequence)
);

-- 3. Agent Rules (How to find approvers)
CREATE TABLE IF NOT EXISTS agent_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rule_code VARCHAR(50) UNIQUE NOT NULL,
  rule_name VARCHAR(200) NOT NULL,
  rule_type VARCHAR(50) NOT NULL, -- 'HIERARCHY', 'ROLE', 'RESPONSIBILITY'
  resolution_logic JSONB NOT NULL, -- How to resolve agents
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Step Agents (Links steps to agent rules)
CREATE TABLE IF NOT EXISTS step_agents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_step_id UUID NOT NULL REFERENCES workflow_steps(id) ON DELETE CASCADE,
  agent_rule_code VARCHAR(50) NOT NULL REFERENCES agent_rules(rule_code),
  sequence INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Workflow Instances (Active workflows)
CREATE TABLE IF NOT EXISTS workflow_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_id UUID NOT NULL REFERENCES workflow_definitions(id),
  object_type VARCHAR(50) NOT NULL,
  object_id VARCHAR(50) NOT NULL, -- Material Request ID
  requester_id UUID NOT NULL REFERENCES auth.users(id),
  context_data JSONB, -- Request details for agent resolution
  status VARCHAR(20) DEFAULT 'ACTIVE', -- 'ACTIVE', 'COMPLETED', 'CANCELLED'
  current_step_sequence INTEGER DEFAULT 1,
  tenant_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ
);

-- 6. Step Instances (Current step assignments - SAP Fiori style)
CREATE TABLE IF NOT EXISTS step_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_instance_id UUID NOT NULL REFERENCES workflow_instances(id) ON DELETE CASCADE,
  workflow_step_id UUID NOT NULL REFERENCES workflow_steps(id),
  step_sequence INTEGER NOT NULL,
  assigned_agent_id UUID NOT NULL REFERENCES auth.users(id),
  assigned_agent_name VARCHAR(200),
  assigned_agent_role VARCHAR(100),
  status VARCHAR(20) DEFAULT 'PENDING', -- 'PENDING', 'APPROVED', 'REJECTED'
  comments TEXT,
  actioned_at TIMESTAMPTZ,
  timeout_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Organizational Hierarchy (For HIERARCHY rule)
CREATE TABLE IF NOT EXISTS org_hierarchy (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID NOT NULL REFERENCES auth.users(id),
  employee_name VARCHAR(200) NOT NULL,
  position_title VARCHAR(200),
  manager_id UUID REFERENCES auth.users(id),
  department_code VARCHAR(50),
  plant_code VARCHAR(50),
  approval_limit DECIMAL(15,2),
  is_active BOOLEAN DEFAULT true,
  tenant_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Role Assignments (For ROLE rule)
CREATE TABLE IF NOT EXISTS role_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_code VARCHAR(50) NOT NULL,
  employee_id UUID NOT NULL REFERENCES auth.users(id),
  scope_type VARCHAR(50), -- 'PLANT', 'DEPARTMENT', 'GLOBAL'
  scope_value VARCHAR(50), -- Plant code, Department code, or NULL for global
  is_active BOOLEAN DEFAULT true,
  tenant_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Responsibility Assignments (For RESPONSIBILITY rule)
CREATE TABLE IF NOT EXISTS responsibility_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  responsibility_code VARCHAR(50) NOT NULL,
  employee_id UUID NOT NULL REFERENCES auth.users(id),
  scope_type VARCHAR(50),
  scope_value VARCHAR(50),
  is_active BOOLEAN DEFAULT true,
  tenant_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_workflow_instances_object ON workflow_instances(object_type, object_id);
CREATE INDEX IF NOT EXISTS idx_workflow_instances_status ON workflow_instances(status, tenant_id);
CREATE INDEX IF NOT EXISTS idx_step_instances_agent ON step_instances(assigned_agent_id, status);
CREATE INDEX IF NOT EXISTS idx_step_instances_workflow ON step_instances(workflow_instance_id, step_sequence);
CREATE INDEX IF NOT EXISTS idx_org_hierarchy_manager ON org_hierarchy(manager_id);
CREATE INDEX IF NOT EXISTS idx_role_assignments_employee ON role_assignments(employee_id, is_active);
CREATE INDEX IF NOT EXISTS idx_responsibility_assignments_employee ON responsibility_assignments(employee_id, is_active);

-- Sample Material Request Workflow
DO $$
DECLARE
  v_tenant_id UUID;
BEGIN
  SELECT id INTO v_tenant_id FROM tenants ORDER BY created_at LIMIT 1;
  
  INSERT INTO workflow_definitions (workflow_code, workflow_name, object_type, description, tenant_id)
  VALUES (
    'MR_STANDARD',
    'Standard Material Request Approval',
    'MATERIAL_REQUEST',
    'Two-level approval: Manager then Department Head',
    v_tenant_id
  ) ON CONFLICT (workflow_code) DO NOTHING;
END $$;

-- Get workflow ID for steps
DO $$
DECLARE
  v_workflow_id UUID;
BEGIN
  SELECT id INTO v_workflow_id FROM workflow_definitions WHERE workflow_code = 'MR_STANDARD';
  
  -- Step 1: Manager Approval
  INSERT INTO workflow_steps (workflow_id, step_sequence, step_code, step_name, step_type, completion_rule, min_approvals)
  VALUES (v_workflow_id, 1, 'MGR_APPROVAL', 'Manager Approval', 'APPROVAL', 'ANY', 1)
  ON CONFLICT (workflow_id, step_sequence) DO NOTHING;
  
  -- Step 2: Department Head Approval
  INSERT INTO workflow_steps (workflow_id, step_sequence, step_code, step_name, step_type, completion_rule, min_approvals)
  VALUES (v_workflow_id, 2, 'DEPT_HEAD_APPROVAL', 'Department Head Approval', 'APPROVAL', 'ANY', 1)
  ON CONFLICT (workflow_id, step_sequence) DO NOTHING;
END $$;

-- Sample Agent Rules
INSERT INTO agent_rules (rule_code, rule_name, rule_type, resolution_logic, description)
VALUES 
  ('DIRECT_MANAGER', 'Direct Manager', 'HIERARCHY', '{"level": "manager"}', 'Resolves to requester''s direct manager'),
  ('DEPT_HEAD', 'Department Head', 'ROLE', '{"role_code": "DEPT_HEAD", "scope_filter": {"department_code": "context.department_code"}}', 'Resolves to department head'),
  ('PLANT_MANAGER', 'Plant Manager', 'ROLE', '{"role_code": "PLANT_MGR", "scope_filter": {"plant_code": "context.plant_code"}}', 'Resolves to plant manager')
ON CONFLICT (rule_code) DO NOTHING;

-- Link steps to agent rules
DO $$
DECLARE
  v_step1_id UUID;
  v_step2_id UUID;
BEGIN
  SELECT id INTO v_step1_id FROM workflow_steps WHERE step_code = 'MGR_APPROVAL' LIMIT 1;
  SELECT id INTO v_step2_id FROM workflow_steps WHERE step_code = 'DEPT_HEAD_APPROVAL' LIMIT 1;
  
  INSERT INTO step_agents (workflow_step_id, agent_rule_code, sequence)
  VALUES 
    (v_step1_id, 'DIRECT_MANAGER', 1),
    (v_step2_id, 'DEPT_HEAD', 1)
  ON CONFLICT DO NOTHING;
END $$;
