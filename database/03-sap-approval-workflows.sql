-- SAP-Aligned Approval Engine - Workflow Definitions
-- Run this after 02-sap-approval-master-data.sql

-- 1. INSERT WORKFLOW DEFINITIONS
INSERT INTO workflow_definitions (workflow_code, workflow_name, object_type, description) VALUES
('PR_STANDARD', 'Standard Purchase Requisition', 'PR', 'Standard PR approval workflow'),
('PR_EMERGENCY', 'Emergency Purchase Requisition', 'PR', 'Emergency PR with reduced steps'),
('PO_STANDARD', 'Standard Purchase Order', 'PO', 'Standard PO approval workflow'),
('PO_EMERGENCY', 'Emergency Purchase Order', 'PO', 'Emergency PO with reduced steps'),
('DOC_TECHNICAL', 'Technical Document Review', 'DOCUMENT', 'Technical document approval workflow');

-- 2. INSERT WORKFLOW STEPS FOR PR_STANDARD
WITH pr_workflow AS (SELECT id FROM workflow_definitions WHERE workflow_code = 'PR_STANDARD')
INSERT INTO workflow_steps (workflow_id, step_sequence, step_code, step_name, step_type, agent_rule, completion_rule, min_approvals, activation_condition, timeout_hours) 
SELECT 
    pr_workflow.id,
    step_sequence,
    step_code,
    step_name,
    step_type,
    agent_rule,
    completion_rule,
    min_approvals,
    activation_condition::jsonb,
    timeout_hours
FROM pr_workflow, (VALUES
    (1, 'MGR_APPROVAL', 'Manager Approval', 'APPROVAL', 'MANAGER_OF_REQUESTER', 'ALL', 1, NULL, 48),
    (2, 'FINANCE_REVIEW', 'Finance Review', 'APPROVAL', 'MULTI_AGENT', 'ALL', 2, '{"amount_gt": 10000}', 72),
    (3, 'SAFETY_REVIEW', 'Safety Review', 'APPROVAL', 'ROLE_SAFETY_OFFICER', 'ALL', 1, '{"material_type": "HAZMAT"}', 48),
    (4, 'TECH_REVIEW', 'Technical Review', 'APPROVAL', 'MULTI_AGENT', 'ANY', 1, '{"material_type": "TECHNICAL"}', 72),
    (5, 'DEPT_APPROVAL', 'Department Head Approval', 'APPROVAL', 'DEPT_HEAD_OF_REQUESTER', 'ALL', 1, '{"amount_gt": 50000}', 48)
) AS steps(step_sequence, step_code, step_name, step_type, agent_rule, completion_rule, min_approvals, activation_condition, timeout_hours);

-- 3. INSERT STEP AGENTS FOR FINANCE_REVIEW (Parallel Agents)
WITH finance_step AS (
    SELECT ws.id 
    FROM workflow_steps ws 
    JOIN workflow_definitions wd ON ws.workflow_id = wd.id 
    WHERE wd.workflow_code = 'PR_STANDARD' AND ws.step_code = 'FINANCE_REVIEW'
)
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

-- 4. INSERT STEP AGENTS FOR TECHNICAL_REVIEW (Parallel Agents - ANY rule)
WITH tech_step AS (
    SELECT ws.id 
    FROM workflow_steps ws 
    JOIN workflow_definitions wd ON ws.workflow_id = wd.id 
    WHERE wd.workflow_code = 'PR_STANDARD' AND ws.step_code = 'TECH_REVIEW'
)
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

-- 5. INSERT WORKFLOW STEPS FOR PR_EMERGENCY (Simplified)
WITH pr_emergency AS (SELECT id FROM workflow_definitions WHERE workflow_code = 'PR_EMERGENCY')
INSERT INTO workflow_steps (workflow_id, step_sequence, step_code, step_name, step_type, agent_rule, completion_rule, min_approvals, timeout_hours) 
SELECT 
    pr_emergency.id,
    step_sequence,
    step_code,
    step_name,
    step_type,
    agent_rule,
    completion_rule,
    min_approvals,
    timeout_hours
FROM pr_emergency, (VALUES
    (1, 'MGR_APPROVAL', 'Manager Approval', 'APPROVAL', 'MANAGER_OF_REQUESTER', 'ALL', 1, 24),
    (2, 'FIN_APPROVAL', 'Finance Approval', 'APPROVAL', 'ROLE_FINANCE_MANAGER', 'ALL', 1, 24)
) AS steps(step_sequence, step_code, step_name, step_type, agent_rule, completion_rule, min_approvals, timeout_hours);

-- 6. INSERT WORKFLOW STEPS FOR PO_STANDARD
WITH po_workflow AS (SELECT id FROM workflow_definitions WHERE workflow_code = 'PO_STANDARD')
INSERT INTO workflow_steps (workflow_id, step_sequence, step_code, step_name, step_type, agent_rule, completion_rule, min_approvals, activation_condition, timeout_hours) 
SELECT 
    po_workflow.id,
    step_sequence,
    step_code,
    step_name,
    step_type,
    agent_rule,
    completion_rule,
    min_approvals,
    activation_condition::jsonb,
    timeout_hours
FROM po_workflow, (VALUES
    (1, 'BUYER_APPROVAL', 'Buyer Approval', 'APPROVAL', 'PURCHASING_GROUP_BUYER', 'ALL', 1, NULL, 48),
    (2, 'FINANCE_REVIEW', 'Finance Review', 'APPROVAL', 'ROLE_FINANCE_MANAGER', 'ALL', 1, '{"amount_gt": 25000}', 48),
    (3, 'PLANT_APPROVAL', 'Plant Manager Approval', 'APPROVAL', 'ROLE_PLANT_MANAGER', 'ALL', 1, '{"amount_gt": 100000}', 48)
) AS steps(step_sequence, step_code, step_name, step_type, agent_rule, completion_rule, min_approvals, activation_condition, timeout_hours);

-- 7. INSERT WORKFLOW STEPS FOR DOC_TECHNICAL
WITH doc_workflow AS (SELECT id FROM workflow_definitions WHERE workflow_code = 'DOC_TECHNICAL')
INSERT INTO workflow_steps (workflow_id, step_sequence, step_code, step_name, step_type, agent_rule, completion_rule, min_approvals, timeout_hours) 
SELECT 
    doc_workflow.id,
    step_sequence,
    step_code,
    step_name,
    step_type,
    agent_rule,
    completion_rule,
    min_approvals,
    timeout_hours
FROM doc_workflow, (VALUES
    (1, 'TECH_REVIEW', 'Technical Review', 'REVIEW', 'MULTI_AGENT', 'MIN_N', 2, 72),
    (2, 'MGR_APPROVAL', 'Manager Approval', 'APPROVAL', 'MANAGER_OF_REQUESTER', 'ALL', 1, 48)
) AS steps(step_sequence, step_code, step_name, step_type, agent_rule, completion_rule, min_approvals, timeout_hours);

-- 8. INSERT STEP AGENTS FOR DOC_TECHNICAL REVIEW (MIN_N rule)
WITH doc_tech_step AS (
    SELECT ws.id 
    FROM workflow_steps ws 
    JOIN workflow_definitions wd ON ws.workflow_id = wd.id 
    WHERE wd.workflow_code = 'DOC_TECHNICAL' AND ws.step_code = 'TECH_REVIEW'
)
INSERT INTO step_agents (workflow_step_id, agent_rule, agent_sequence, is_required)
SELECT 
    doc_tech_step.id,
    agent_rule,
    agent_sequence,
    is_required
FROM doc_tech_step, (VALUES
    ('ROLE_STRUCTURAL_ENGINEER', 1, true),
    ('ROLE_ELECTRICAL_ENGINEER', 2, true),
    ('ROLE_MECHANICAL_ENGINEER', 3, true),
    ('ROLE_SAFETY_OFFICER', 4, false)
) AS agents(agent_rule, agent_sequence, is_required);

-- 9. INSERT START CONDITIONS FOR PR_STANDARD
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

-- 10. INSERT START CONDITIONS FOR PR_EMERGENCY
WITH pr_emergency AS (SELECT id FROM workflow_definitions WHERE workflow_code = 'PR_EMERGENCY')
INSERT INTO workflow_start_conditions (workflow_id, condition_type, condition_operator, condition_value, priority)
SELECT 
    pr_emergency.id,
    condition_type,
    condition_operator,
    condition_value::jsonb,
    priority
FROM pr_emergency, (VALUES
    ('OBJECT_TYPE', 'EQUALS', '"PR"', 50),
    ('DOCUMENT_TYPE', 'EQUALS', '"EMERGENCY"', 100)
) AS conditions(condition_type, condition_operator, condition_value, priority);

-- 11. INSERT START CONDITIONS FOR PO_STANDARD
WITH po_workflow AS (SELECT id FROM workflow_definitions WHERE workflow_code = 'PO_STANDARD')
INSERT INTO workflow_start_conditions (workflow_id, condition_type, condition_operator, condition_value, priority)
SELECT 
    po_workflow.id,
    condition_type,
    condition_operator,
    condition_value::jsonb,
    priority
FROM po_workflow, (VALUES
    ('OBJECT_TYPE', 'EQUALS', '"PO"', 100),
    ('DOCUMENT_TYPE', 'EQUALS', '"STANDARD"', 200)
) AS conditions(condition_type, condition_operator, condition_value, priority);

-- 12. INSERT START CONDITIONS FOR DOC_TECHNICAL
WITH doc_workflow AS (SELECT id FROM workflow_definitions WHERE workflow_code = 'DOC_TECHNICAL')
INSERT INTO workflow_start_conditions (workflow_id, condition_type, condition_operator, condition_value, priority)
SELECT 
    doc_workflow.id,
    condition_type,
    condition_operator,
    condition_value::jsonb,
    priority
FROM doc_workflow, (VALUES
    ('OBJECT_TYPE', 'EQUALS', '"DOCUMENT"', 100),
    ('DOCUMENT_TYPE', 'EQUALS', '"TECHNICAL"', 200)
) AS conditions(condition_type, condition_operator, condition_value, priority);