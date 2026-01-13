-- SAP-Aligned Parallel Approval Schema Updates
-- Multiple agents per step with completion rules

-- 1. UPDATE WORKFLOW STEPS (Add Completion Rules)
ALTER TABLE workflow_steps ADD COLUMN completion_rule VARCHAR(20) DEFAULT 'ALL';
ALTER TABLE workflow_steps ADD COLUMN min_approvals INTEGER DEFAULT 1;
ALTER TABLE workflow_steps ADD CONSTRAINT valid_completion_rule 
    CHECK (completion_rule IN ('ALL', 'ANY', 'MIN_N'));

-- 2. STEP AGENTS (Multiple Agents per Step)
CREATE TABLE step_agents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_step_id UUID NOT NULL REFERENCES workflow_steps(id),
    agent_rule VARCHAR(50) NOT NULL,              -- ROLE_FINANCE_MANAGER, MANAGER_OF_REQUESTER
    agent_sequence INTEGER DEFAULT 1,             -- For ordering within step
    is_required BOOLEAN DEFAULT true,             -- Required vs optional approver
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(workflow_step_id, agent_rule)
);

-- 3. UPDATE STEP INSTANCES (Track Individual Agent Decisions)
ALTER TABLE step_instances ADD COLUMN step_agent_id UUID REFERENCES step_agents(id);
ALTER TABLE step_instances ADD COLUMN is_step_completed BOOLEAN DEFAULT false;

-- 4. STEP COMPLETION TRACKING
CREATE TABLE step_completion_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_instance_id UUID NOT NULL REFERENCES workflow_instances(id),
    workflow_step_id UUID NOT NULL REFERENCES workflow_steps(id),
    step_sequence INTEGER NOT NULL,
    total_agents INTEGER NOT NULL,
    approved_count INTEGER DEFAULT 0,
    rejected_count INTEGER DEFAULT 0,
    pending_count INTEGER DEFAULT 0,
    completion_rule VARCHAR(20) NOT NULL,
    min_approvals INTEGER DEFAULT 1,
    is_completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP,
    UNIQUE(workflow_instance_id, step_sequence)
);

-- 5. INSERT SAMPLE PARALLEL STEP CONFIGURATION
-- Finance Review with multiple parallel agents
WITH pr_workflow AS (SELECT id FROM workflow_definitions WHERE workflow_code = 'PR_STANDARD'),
     finance_step AS (SELECT id FROM workflow_steps WHERE workflow_id = (SELECT id FROM pr_workflow) AND step_code = 'FINANCE_REVIEW')
INSERT INTO step_agents (workflow_step_id, agent_rule, agent_sequence, is_required)
SELECT 
    finance_step.id,
    agent_rule,
    agent_sequence,
    is_required
FROM finance_step, (VALUES
    ('ROLE_FINANCE_CONTROLLER', 1, true),
    ('ROLE_FINANCE_MANAGER', 2, true),
    ('ROLE_CFO', 3, false)
) AS agents(agent_rule, agent_sequence, is_required);

-- Update finance step to require ALL approvals
UPDATE workflow_steps 
SET completion_rule = 'ALL', min_approvals = 2
WHERE step_code = 'FINANCE_REVIEW';

-- 6. TECHNICAL REVIEW with ANY completion rule
INSERT INTO workflow_steps (workflow_id, step_sequence, step_code, step_name, step_type, agent_rule, completion_rule, min_approvals, activation_condition)
SELECT 
    (SELECT id FROM workflow_definitions WHERE workflow_code = 'PR_STANDARD'),
    5,
    'TECHNICAL_REVIEW',
    'Technical Review',
    'APPROVAL',
    'MULTI_AGENT',  -- Special marker for multi-agent steps
    'ANY',          -- Any one technical approver can approve
    1,
    '{"material_type": "TECHNICAL"}'::jsonb;

-- Add technical reviewers
WITH tech_step AS (SELECT id FROM workflow_steps WHERE step_code = 'TECHNICAL_REVIEW')
INSERT INTO step_agents (workflow_step_id, agent_rule, agent_sequence, is_required)
SELECT 
    tech_step.id,
    agent_rule,
    agent_sequence,
    is_required
FROM tech_step, (VALUES
    ('ROLE_STRUCTURAL_ENGINEER', 1, true),
    ('ROLE_ELECTRICAL_ENGINEER', 2, true),
    ('ROLE_MECHANICAL_ENGINEER', 3, true)
) AS agents(agent_rule, agent_sequence, is_required);

-- 7. INDEXES FOR PERFORMANCE
CREATE INDEX idx_step_agents_workflow_step ON step_agents(workflow_step_id);
CREATE INDEX idx_step_completion_pending ON step_completion_status(workflow_instance_id, is_completed) 
    WHERE is_completed = false;
CREATE INDEX idx_step_instances_agent_status ON step_instances(step_agent_id, status, workflow_instance_id);