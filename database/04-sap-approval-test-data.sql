-- SAP-Aligned Approval Engine - Test Data & Verification
-- Run this after 03-sap-approval-workflows.sql

-- 1. VERIFICATION QUERIES
-- Check workflow definitions
SELECT 
    wd.workflow_code,
    wd.workflow_name,
    wd.object_type,
    COUNT(ws.id) as step_count
FROM workflow_definitions wd
LEFT JOIN workflow_steps ws ON wd.id = ws.workflow_id
WHERE wd.is_active = true
GROUP BY wd.id, wd.workflow_code, wd.workflow_name, wd.object_type
ORDER BY wd.workflow_code;

-- Check workflow steps with agents
SELECT 
    wd.workflow_code,
    ws.step_sequence,
    ws.step_code,
    ws.step_name,
    ws.completion_rule,
    ws.min_approvals,
    COUNT(sa.id) as agent_count
FROM workflow_definitions wd
JOIN workflow_steps ws ON wd.id = ws.workflow_id
LEFT JOIN step_agents sa ON ws.id = sa.workflow_step_id
WHERE wd.is_active = true
GROUP BY wd.id, wd.workflow_code, ws.id, ws.step_sequence, ws.step_code, ws.step_name, ws.completion_rule, ws.min_approvals
ORDER BY wd.workflow_code, ws.step_sequence;

-- Check agent rules
SELECT 
    rule_code,
    rule_name,
    rule_type,
    resolution_logic,
    description
FROM agent_rules
WHERE is_active = true
ORDER BY rule_type, rule_code;

-- Check organizational hierarchy
SELECT 
    employee_id,
    employee_name,
    manager_id,
    department_code,
    plant_code,
    position_title
FROM org_hierarchy
WHERE is_active = true
ORDER BY department_code, position_title;

-- Check role assignments
SELECT 
    oh.employee_name,
    oh.position_title,
    ra.role_code,
    ra.scope_type,
    ra.scope_value
FROM role_assignments ra
JOIN org_hierarchy oh ON ra.employee_id = oh.employee_id
WHERE ra.is_active = true AND oh.is_active = true
ORDER BY oh.employee_name, ra.role_code;

-- 2. SAMPLE TEST DATA - Create test workflow instances
-- Test PR Standard workflow
INSERT INTO workflow_instances (
    workflow_id,
    object_type,
    object_id,
    requester_id,
    context_data,
    status
) VALUES (
    (SELECT id FROM workflow_definitions WHERE workflow_code = 'PR_STANDARD'),
    'PR',
    'PR-2024-001',
    'EMP015',  -- Pooja Reddy (Site Supervisor)
    '{
        "amount": 15000,
        "material_type": "STANDARD",
        "department_code": "OPERATIONS",
        "plant_code": "PLT_MUM",
        "company_code": "C001",
        "purchasing_group": "PG_CONSTRUCTION"
    }'::jsonb,
    'ACTIVE'
);

-- Test PR Emergency workflow
INSERT INTO workflow_instances (
    workflow_id,
    object_type,
    object_id,
    requester_id,
    context_data,
    status
) VALUES (
    (SELECT id FROM workflow_definitions WHERE workflow_code = 'PR_EMERGENCY'),
    'PR',
    'PR-2024-002',
    'EMP016',  -- Arjun Pillai (Site Supervisor)
    '{
        "amount": 5000,
        "material_type": "EMERGENCY",
        "department_code": "OPERATIONS",
        "plant_code": "PLT_DEL",
        "company_code": "C001"
    }'::jsonb,
    'ACTIVE'
);

-- Test PO Standard workflow
INSERT INTO workflow_instances (
    workflow_id,
    object_type,
    object_id,
    requester_id,
    context_data,
    status
) VALUES (
    (SELECT id FROM workflow_definitions WHERE workflow_code = 'PO_STANDARD'),
    'PO',
    'PO-2024-001',
    'EMP014',  -- Sanjay Jain (Senior Buyer)
    '{
        "amount": 75000,
        "purchasing_group": "PG_CONSTRUCTION",
        "plant_code": "PLT_MUM",
        "company_code": "C001"
    }'::jsonb,
    'ACTIVE'
);

-- Test Technical Document workflow
INSERT INTO workflow_instances (
    workflow_id,
    object_type,
    object_id,
    requester_id,
    context_data,
    status
) VALUES (
    (SELECT id FROM workflow_definitions WHERE workflow_code = 'DOC_TECHNICAL'),
    'DOCUMENT',
    'DOC-2024-001',
    'EMP008',  -- Deepak Rao (Structural Engineer)
    '{
        "document_type": "TECHNICAL",
        "discipline": "STRUCTURAL",
        "plant_code": "PLT_MUM",
        "company_code": "C001"
    }'::jsonb,
    'ACTIVE'
);

-- 3. VERIFICATION QUERIES FOR TEST DATA
-- Check created workflow instances
SELECT 
    wi.object_type,
    wi.object_id,
    oh.employee_name as requester_name,
    wd.workflow_name,
    wi.current_step_sequence,
    wi.status,
    wi.created_at
FROM workflow_instances wi
JOIN workflow_definitions wd ON wi.workflow_id = wd.id
JOIN org_hierarchy oh ON wi.requester_id = oh.employee_id
ORDER BY wi.created_at DESC;

-- 4. SAMPLE STEP INSTANCES (Simulating workflow execution)
-- Create step instances for PR-2024-001 (Manager Approval step)
WITH pr_instance AS (
    SELECT wi.id as instance_id, ws.id as step_id
    FROM workflow_instances wi
    JOIN workflow_definitions wd ON wi.workflow_id = wd.id
    JOIN workflow_steps ws ON wd.id = ws.workflow_id
    WHERE wi.object_id = 'PR-2024-001' AND ws.step_sequence = 1
)
INSERT INTO step_instances (
    workflow_instance_id,
    workflow_step_id,
    step_sequence,
    assigned_agent_id,
    assigned_agent_name,
    assigned_agent_role,
    status,
    timeout_at
)
SELECT 
    pr_instance.instance_id,
    pr_instance.step_id,
    1,
    'EMP006',  -- Ravi Mehta (Plant Manager - Manager of EMP015)
    'Ravi Mehta',
    'Plant Manager - Mumbai',
    'PENDING',
    CURRENT_TIMESTAMP + INTERVAL '48 hours'
FROM pr_instance;

-- 5. USEFUL MONITORING QUERIES
-- Active workflow instances summary
SELECT 
    wd.workflow_code,
    wd.workflow_name,
    COUNT(*) as active_instances,
    AVG(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - wi.created_at))/3600) as avg_age_hours
FROM workflow_instances wi
JOIN workflow_definitions wd ON wi.workflow_id = wd.id
WHERE wi.status = 'ACTIVE'
GROUP BY wd.id, wd.workflow_code, wd.workflow_name
ORDER BY active_instances DESC;

-- Pending approvals by agent
SELECT 
    si.assigned_agent_name,
    si.assigned_agent_role,
    COUNT(*) as pending_approvals,
    MIN(si.created_at) as oldest_pending
FROM step_instances si
WHERE si.status = 'PENDING'
GROUP BY si.assigned_agent_id, si.assigned_agent_name, si.assigned_agent_role
ORDER BY pending_approvals DESC;

-- Workflow performance metrics
SELECT 
    wd.workflow_code,
    COUNT(*) as total_completed,
    AVG(EXTRACT(EPOCH FROM (wi.completed_at - wi.created_at))/3600) as avg_completion_hours,
    MIN(EXTRACT(EPOCH FROM (wi.completed_at - wi.created_at))/3600) as min_completion_hours,
    MAX(EXTRACT(EPOCH FROM (wi.completed_at - wi.created_at))/3600) as max_completion_hours
FROM workflow_instances wi
JOIN workflow_definitions wd ON wi.workflow_id = wd.id
WHERE wi.status = 'COMPLETED' AND wi.completed_at IS NOT NULL
GROUP BY wd.id, wd.workflow_code
ORDER BY avg_completion_hours;