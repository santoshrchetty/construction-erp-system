-- SAP-Aligned Approval Engine - Complete Setup
-- Run this file to create the complete approval engine

-- 1. DROP EXISTING TABLES (if they exist)
DROP TABLE IF EXISTS step_instances CASCADE;
DROP TABLE IF EXISTS step_completion_status CASCADE;
DROP TABLE IF EXISTS step_agents CASCADE;
DROP TABLE IF EXISTS workflow_instances CASCADE;
DROP TABLE IF EXISTS workflow_steps CASCADE;
DROP TABLE IF EXISTS workflow_start_conditions CASCADE;
DROP TABLE IF EXISTS workflow_definitions CASCADE;
DROP TABLE IF EXISTS agent_rules CASCADE;
DROP TABLE IF EXISTS responsibility_assignments CASCADE;
DROP TABLE IF EXISTS role_assignments CASCADE;
DROP TABLE IF EXISTS org_hierarchy CASCADE;

-- 2. WORKFLOW DEFINITIONS (Static Step Order)
CREATE TABLE workflow_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_code VARCHAR(20) NOT NULL,
    workflow_name VARCHAR(100) NOT NULL,
    object_type VARCHAR(20) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(workflow_code)
);

-- 3. WORKFLOW STEPS (Explicit Step Sequence)
CREATE TABLE workflow_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID NOT NULL REFERENCES workflow_definitions(id),
    step_sequence INTEGER NOT NULL,
    step_code VARCHAR(20) NOT NULL,
    step_name VARCHAR(100) NOT NULL,
    step_type VARCHAR(20) NOT NULL CHECK (step_type IN ('APPROVAL', 'REVIEW', 'ACKNOWLEDGE', 'NOTIFICATION')),
    agent_rule VARCHAR(50) NOT NULL,
    completion_rule VARCHAR(20) DEFAULT 'ALL' CHECK (completion_rule IN ('ALL', 'ANY', 'MIN_N')),
    min_approvals INTEGER DEFAULT 1,
    activation_condition JSONB,
    timeout_hours INTEGER DEFAULT 72,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(workflow_id, step_sequence)
);

-- 4. STEP AGENTS (Multiple Agents per Step)
CREATE TABLE step_agents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_step_id UUID NOT NULL REFERENCES workflow_steps(id),
    agent_rule VARCHAR(50) NOT NULL,
    agent_sequence INTEGER DEFAULT 1,
    is_required BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(workflow_step_id, agent_rule)
);

-- 5. WORKFLOW START CONDITIONS (Policy = When to Apply)
CREATE TABLE workflow_start_conditions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID NOT NULL REFERENCES workflow_definitions(id),
    condition_type VARCHAR(20) NOT NULL,
    condition_operator VARCHAR(10) NOT NULL,
    condition_value JSONB NOT NULL,
    priority INTEGER DEFAULT 100,
    is_active BOOLEAN DEFAULT true
);

-- 6. AGENT DETERMINATION RULES (Reusable Rules)
CREATE TABLE agent_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rule_code VARCHAR(50) NOT NULL UNIQUE,
    rule_name VARCHAR(100) NOT NULL,
    rule_type VARCHAR(20) NOT NULL,
    resolution_logic JSONB NOT NULL,
    fallback_rule VARCHAR(50),
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

-- 7. WORKFLOW INSTANCES (Runtime Execution)
CREATE TABLE workflow_instances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID NOT NULL REFERENCES workflow_definitions(id),
    object_type VARCHAR(20) NOT NULL,
    object_id VARCHAR(100) NOT NULL,
    requester_id VARCHAR(50) NOT NULL,
    current_step_sequence INTEGER DEFAULT 1,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'COMPLETED', 'CANCELLED', 'ERROR', 'REJECTED', 'RETURNED')),
    context_data JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- 8. STEP INSTANCES (Individual Step Execution)
CREATE TABLE step_instances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_instance_id UUID NOT NULL REFERENCES workflow_instances(id),
    workflow_step_id UUID NOT NULL REFERENCES workflow_steps(id),
    step_agent_id UUID REFERENCES step_agents(id),
    step_sequence INTEGER NOT NULL,
    assigned_agent_id VARCHAR(50),
    assigned_agent_name VARCHAR(200),
    assigned_agent_role VARCHAR(100),
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'SKIPPED', 'TIMEOUT', 'ESCALATED', 'CANCELLED')),
    decision VARCHAR(20),
    comments TEXT,
    decided_at TIMESTAMP,
    timeout_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_step_completed BOOLEAN DEFAULT false
);

-- 9. STEP COMPLETION TRACKING
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

-- 10. ORGANIZATIONAL DATA (For Agent Resolution Only)
CREATE TABLE org_hierarchy (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id VARCHAR(50) NOT NULL UNIQUE,
    employee_name VARCHAR(200) NOT NULL,
    manager_id VARCHAR(50),
    department_code VARCHAR(20),
    plant_code VARCHAR(20),
    company_code VARCHAR(10),
    position_title VARCHAR(100),
    email VARCHAR(200),
    is_active BOOLEAN DEFAULT true
);

-- 11. ROLE ASSIGNMENTS (For Role-Based Agent Rules)
CREATE TABLE role_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id VARCHAR(50) NOT NULL,
    role_code VARCHAR(50) NOT NULL,
    scope_type VARCHAR(20),
    scope_value VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(employee_id, role_code, scope_type, scope_value)
);

-- 12. RESPONSIBILITY ASSIGNMENTS (For Purchasing Groups, etc.)
CREATE TABLE responsibility_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id VARCHAR(50) NOT NULL,
    responsibility_type VARCHAR(20) NOT NULL,
    responsibility_value VARCHAR(50) NOT NULL,
    approval_limit DECIMAL(15,2),
    is_active BOOLEAN DEFAULT true,
    UNIQUE(employee_id, responsibility_type, responsibility_value)
);

-- 13. DROP EXISTING INDEXES (if they exist)
DROP INDEX IF EXISTS idx_workflow_instances_object;
DROP INDEX IF EXISTS idx_workflow_instances_active;
DROP INDEX IF EXISTS idx_step_instances_pending;
DROP INDEX IF EXISTS idx_step_instances_workflow;
DROP INDEX IF EXISTS idx_step_agents_workflow_step;
DROP INDEX IF EXISTS idx_step_completion_pending;
DROP INDEX IF EXISTS idx_org_hierarchy_manager;
DROP INDEX IF EXISTS idx_org_hierarchy_dept_plant;
DROP INDEX IF EXISTS idx_role_assignments_role;
DROP INDEX IF EXISTS idx_responsibility_assignments;

-- 14. CREATE INDEXES
CREATE INDEX idx_workflow_instances_object ON workflow_instances(object_type, object_id);
CREATE INDEX idx_workflow_instances_active ON workflow_instances(status, created_at) WHERE status = 'ACTIVE';
CREATE INDEX idx_step_instances_pending ON step_instances(assigned_agent_id, status) WHERE status = 'PENDING';
CREATE INDEX idx_step_instances_workflow ON step_instances(workflow_instance_id, step_sequence);
CREATE INDEX idx_step_agents_workflow_step ON step_agents(workflow_step_id);
CREATE INDEX idx_step_completion_pending ON step_completion_status(workflow_instance_id, is_completed) WHERE is_completed = false;
CREATE INDEX idx_org_hierarchy_manager ON org_hierarchy(manager_id);
CREATE INDEX idx_org_hierarchy_dept_plant ON org_hierarchy(department_code, plant_code);
CREATE INDEX idx_role_assignments_role ON role_assignments(role_code, scope_type, scope_value);
CREATE INDEX idx_responsibility_assignments ON responsibility_assignments(responsibility_type, responsibility_value);

-- 15. CREATE DATABASE FUNCTION FOR STEP STATUS COUNTS
DROP FUNCTION IF EXISTS get_step_status_counts(UUID, UUID);
CREATE OR REPLACE FUNCTION get_step_status_counts(
    p_workflow_instance_id UUID,
    p_workflow_step_id UUID
)
RETURNS TABLE(
    approved_count INTEGER,
    rejected_count INTEGER,
    pending_count INTEGER,
    total_agents INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) FILTER (WHERE status = 'APPROVED')::INTEGER as approved_count,
        COUNT(*) FILTER (WHERE status = 'REJECTED')::INTEGER as rejected_count,
        COUNT(*) FILTER (WHERE status = 'PENDING')::INTEGER as pending_count,
        COUNT(*)::INTEGER as total_agents
    FROM step_instances 
    WHERE workflow_instance_id = p_workflow_instance_id 
    AND workflow_step_id = p_workflow_step_id;
END;
$$ LANGUAGE plpgsql;