-- SAP-Aligned Approval Engine Schema
-- Step-driven workflow model with clear separation of concerns

-- 1. WORKFLOW DEFINITIONS (Static Step Order)
CREATE TABLE workflow_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_code VARCHAR(20) NOT NULL,           -- PR_STANDARD, PO_EMERGENCY, etc.
    workflow_name VARCHAR(100) NOT NULL,
    object_type VARCHAR(20) NOT NULL,             -- PR, PO, DOCUMENT, HR
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(workflow_code)
);

-- 2. WORKFLOW STEPS (Explicit Step Sequence)
CREATE TABLE workflow_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID NOT NULL REFERENCES workflow_definitions(id),
    step_sequence INTEGER NOT NULL,               -- 1, 2, 3, 4...
    step_code VARCHAR(20) NOT NULL,               -- MANAGER_APPROVAL, FINANCE_REVIEW
    step_name VARCHAR(100) NOT NULL,
    step_type VARCHAR(20) NOT NULL,               -- APPROVAL, REVIEW, ACKNOWLEDGE
    agent_rule VARCHAR(50) NOT NULL,              -- MANAGER_OF_REQUESTER, ROLE_FINANCE_MANAGER
    activation_condition JSONB,                   -- {"amount_gt": 10000, "material_type": "HAZMAT"}
    is_parallel BOOLEAN DEFAULT false,            -- Can run parallel with next step
    timeout_hours INTEGER DEFAULT 72,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(workflow_id, step_sequence)
);

-- 3. WORKFLOW START CONDITIONS (Policy = When to Apply)
CREATE TABLE workflow_start_conditions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID NOT NULL REFERENCES workflow_definitions(id),
    condition_type VARCHAR(20) NOT NULL,          -- OBJECT_TYPE, AMOUNT_RANGE, DEPARTMENT
    condition_operator VARCHAR(10) NOT NULL,      -- EQUALS, GT, LT, IN, CONTAINS
    condition_value JSONB NOT NULL,               -- "PR" or {"min": 1000, "max": 50000}
    priority INTEGER DEFAULT 100,                 -- Lower = higher priority
    is_active BOOLEAN DEFAULT true
);

-- 4. AGENT DETERMINATION RULES (Reusable Rules)
CREATE TABLE agent_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_code VARCHAR(50) NOT NULL UNIQUE,       -- MANAGER_OF_REQUESTER, ROLE_FINANCE_MANAGER
    rule_name VARCHAR(100) NOT NULL,
    rule_type VARCHAR(20) NOT NULL,               -- HIERARCHY, ROLE, RESPONSIBILITY, FUNCTIONAL
    resolution_logic JSONB NOT NULL,              -- {"type": "manager", "levels": 1}
    fallback_rule VARCHAR(50),                    -- Fallback if primary fails
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

-- 5. WORKFLOW INSTANCES (Runtime Execution)
CREATE TABLE workflow_instances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID NOT NULL REFERENCES workflow_definitions(id),
    object_type VARCHAR(20) NOT NULL,
    object_id VARCHAR(100) NOT NULL,              -- PR number, PO number, etc.
    requester_id VARCHAR(50) NOT NULL,
    current_step_sequence INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'ACTIVE',          -- ACTIVE, COMPLETED, CANCELLED, ERROR
    context_data JSONB,                           -- Request context for agent resolution
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    INDEX(object_type, object_id),
    INDEX(status, created_at)
);

-- 6. STEP INSTANCES (Individual Step Execution)
CREATE TABLE step_instances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_instance_id UUID NOT NULL REFERENCES workflow_instances(id),
    workflow_step_id UUID NOT NULL REFERENCES workflow_steps(id),
    step_sequence INTEGER NOT NULL,
    assigned_agent_id VARCHAR(50),               -- Resolved at runtime
    assigned_agent_name VARCHAR(200),            -- Snapshot for audit
    assigned_agent_role VARCHAR(100),            -- Snapshot for audit
    status VARCHAR(20) DEFAULT 'PENDING',        -- PENDING, APPROVED, REJECTED, SKIPPED, TIMEOUT
    decision VARCHAR(20),                        -- APPROVE, REJECT, RETURN
    comments TEXT,
    decided_at TIMESTAMP,
    timeout_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX(workflow_instance_id, step_sequence),
    INDEX(assigned_agent_id, status)
);

-- 7. ORGANIZATIONAL DATA (For Agent Resolution Only)
CREATE TABLE org_hierarchy (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id VARCHAR(50) NOT NULL UNIQUE,
    employee_name VARCHAR(200) NOT NULL,
    manager_id VARCHAR(50),                       -- Reports to
    department_code VARCHAR(20),
    plant_code VARCHAR(20),
    company_code VARCHAR(10),
    position_title VARCHAR(100),
    email VARCHAR(200),
    is_active BOOLEAN DEFAULT true,
    INDEX(manager_id),
    INDEX(department_code, plant_code)
);

-- 8. ROLE ASSIGNMENTS (For Role-Based Agent Rules)
CREATE TABLE role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id VARCHAR(50) NOT NULL,
    role_code VARCHAR(50) NOT NULL,              -- FINANCE_MANAGER, SAFETY_OFFICER
    scope_type VARCHAR(20),                      -- COMPANY, PLANT, DEPARTMENT
    scope_value VARCHAR(50),                     -- C001, PLT_MUM, DEPT_FIN
    is_active BOOLEAN DEFAULT true,
    UNIQUE(employee_id, role_code, scope_type, scope_value),
    INDEX(role_code, scope_type, scope_value)
);

-- 9. RESPONSIBILITY ASSIGNMENTS (For Purchasing Groups, etc.)
CREATE TABLE responsibility_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id VARCHAR(50) NOT NULL,
    responsibility_type VARCHAR(20) NOT NULL,    -- PURCHASING_GROUP, MATERIAL_GROUP
    responsibility_value VARCHAR(50) NOT NULL,   -- PG_STEEL, MAT_ELECTRICAL
    approval_limit DECIMAL(15,2),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(employee_id, responsibility_type, responsibility_value),
    INDEX(responsibility_type, responsibility_value)
);

-- Insert Standard Agent Rules
INSERT INTO agent_rules (rule_code, rule_name, rule_type, resolution_logic, description) VALUES
('MANAGER_OF_REQUESTER', 'Direct Manager of Requester', 'HIERARCHY', '{"type": "manager", "levels": 1}', 'Finds immediate manager'),
('DEPT_HEAD_OF_REQUESTER', 'Department Head of Requester', 'HIERARCHY', '{"type": "department_head"}', 'Finds department head'),
('ROLE_FINANCE_MANAGER', 'Finance Manager', 'ROLE', '{"role": "FINANCE_MANAGER", "scope_match": ["company_code"]}', 'Finance manager for same company'),
('ROLE_SAFETY_OFFICER', 'Safety Officer', 'ROLE', '{"role": "SAFETY_OFFICER", "scope_match": ["plant_code"]}', 'Safety officer for same plant'),
('PURCHASING_GROUP_BUYER', 'Purchasing Group Buyer', 'RESPONSIBILITY', '{"type": "PURCHASING_GROUP", "match_field": "purchasing_group"}', 'Buyer for purchasing group'),
('ROLE_PLANT_MANAGER', 'Plant Manager', 'ROLE', '{"role": "PLANT_MANAGER", "scope_match": ["plant_code"]}', 'Plant manager for same plant');

-- Insert Sample Workflow Definition
INSERT INTO workflow_definitions (workflow_code, workflow_name, object_type, description) VALUES
('PR_STANDARD', 'Standard Purchase Requisition', 'PR', 'Standard PR approval workflow'),
('PO_STANDARD', 'Standard Purchase Order', 'PO', 'Standard PO approval workflow'),
('PO_EMERGENCY', 'Emergency Purchase Order', 'PO', 'Emergency PO with reduced steps');

-- Insert Sample Workflow Steps for PR_STANDARD
WITH pr_workflow AS (SELECT id FROM workflow_definitions WHERE workflow_code = 'PR_STANDARD')
INSERT INTO workflow_steps (workflow_id, step_sequence, step_code, step_name, step_type, agent_rule, activation_condition) 
SELECT 
    pr_workflow.id,
    step_sequence,
    step_code,
    step_name,
    step_type,
    agent_rule,
    activation_condition::jsonb
FROM pr_workflow, (VALUES
    (1, 'MANAGER_APPROVAL', 'Manager Approval', 'APPROVAL', 'MANAGER_OF_REQUESTER', NULL),
    (2, 'FINANCE_REVIEW', 'Finance Review', 'APPROVAL', 'ROLE_FINANCE_MANAGER', '{"amount_gt": 10000}'),
    (3, 'SAFETY_REVIEW', 'Safety Review', 'APPROVAL', 'ROLE_SAFETY_OFFICER', '{"material_type": "HAZMAT"}'),
    (4, 'DEPT_HEAD_APPROVAL', 'Department Head Approval', 'APPROVAL', 'DEPT_HEAD_OF_REQUESTER', '{"amount_gt": 50000}')
) AS steps(step_sequence, step_code, step_name, step_type, agent_rule, activation_condition);

-- Insert Start Conditions for PR_STANDARD
WITH pr_workflow AS (SELECT id FROM workflow_definitions WHERE workflow_code = 'PR_STANDARD')
INSERT INTO workflow_start_conditions (workflow_id, condition_type, condition_operator, condition_value, priority)
SELECT 
    pr_workflow.id,
    condition_type,
    condition_operator,
    condition_value::jsonb,
    priority
FROM pr_workflow, (VALUES
    ('OBJECT_TYPE', 'EQUALS', '"PR"', 100),
    ('DOCUMENT_TYPE', 'EQUALS', '"STANDARD"', 200)
) AS conditions(condition_type, condition_operator, condition_value, priority);