-- Test Approval Workflow - Complete End-to-End Testing
-- Run after all approval system scripts are executed

-- 1. Test Material Request Creation and Approval Flow
INSERT INTO material_requests (
    request_number, plant_code, department, requested_by, 
    total_amount, currency_code, request_date, status
) VALUES 
('MR-2024-001', 'B001', 'CONSTRUCTION', 'john.doe@company.com', 15000.00, 'USD', NOW(), 'PENDING');

-- 2. Test Approval Path Calculation
SELECT 'TESTING APPROVAL PATH CALCULATION' as test_step;

WITH test_request AS (
    SELECT id, total_amount, plant_code, department 
    FROM material_requests 
    WHERE request_number = 'MR-2024-001'
),
approval_path AS (
    SELECT 
        fal.level_number,
        fal.role_name,
        fal.min_amount,
        fal.max_amount,
        fal.is_required
    FROM flexible_approval_levels fal
    JOIN customer_approval_configuration cac ON fal.config_id = cac.id
    JOIN test_request tr ON cac.plant_code = tr.plant_code
    WHERE fal.document_type = 'MR'
      AND tr.total_amount >= fal.min_amount 
      AND (fal.max_amount IS NULL OR tr.total_amount <= fal.max_amount)
    ORDER BY fal.level_number
)
SELECT * FROM approval_path;

-- 3. Create Approval Execution Records
INSERT INTO approval_executions (
    request_id, request_type, current_level, total_levels, status
)
SELECT 
    mr.id,
    'MR',
    1,
    (SELECT COUNT(*) FROM flexible_approval_levels fal
     JOIN customer_approval_configuration cac ON fal.config_id = cac.id
     WHERE cac.plant_code = 'B001' AND fal.document_type = 'MR'
       AND mr.total_amount >= fal.min_amount),
    'IN_PROGRESS'
FROM material_requests mr
WHERE mr.request_number = 'MR-2024-001';

-- 4. Test First Level Approval
INSERT INTO approval_actions (
    execution_id, level_number, approver_role, approver_email,
    action, comments, action_date
)
SELECT 
    ae.id,
    1,
    'SUPERVISOR',
    'supervisor@company.com',
    'APPROVED',
    'Approved for construction materials',
    NOW()
FROM approval_executions ae
JOIN material_requests mr ON ae.request_id = mr.id
WHERE mr.request_number = 'MR-2024-001';

-- 5. Update Execution to Next Level
UPDATE approval_executions 
SET current_level = 2, updated_at = NOW()
WHERE request_id = (SELECT id FROM material_requests WHERE request_number = 'MR-2024-001');

-- 6. Test Second Level Approval
INSERT INTO approval_actions (
    execution_id, level_number, approver_role, approver_email,
    action, comments, action_date
)
SELECT 
    ae.id,
    2,
    'MANAGER',
    'manager@company.com',
    'APPROVED',
    'Budget approved for Q1 construction',
    NOW()
FROM approval_executions ae
JOIN material_requests mr ON ae.request_id = mr.id
WHERE mr.request_number = 'MR-2024-001';

-- 7. Complete Approval Process
UPDATE approval_executions 
SET status = 'COMPLETED', completed_at = NOW()
WHERE request_id = (SELECT id FROM material_requests WHERE request_number = 'MR-2024-001');

UPDATE material_requests 
SET status = 'APPROVED', approved_date = NOW()
WHERE request_number = 'MR-2024-001';

-- 8. Test Emergency Override Scenario
INSERT INTO material_requests (
    request_number, plant_code, department, requested_by, 
    total_amount, currency_code, request_date, status, is_emergency
) VALUES 
('MR-2024-002', 'B001', 'MAINTENANCE', 'emergency@company.com', 25000.00, 'USD', NOW(), 'PENDING', true);

-- Emergency override approval
INSERT INTO approval_executions (
    request_id, request_type, current_level, total_levels, status
)
SELECT 
    mr.id, 'MR', 999, 999, 'EMERGENCY_OVERRIDE'
FROM material_requests mr
WHERE mr.request_number = 'MR-2024-002';

INSERT INTO approval_actions (
    execution_id, level_number, approver_role, approver_email,
    action, comments, action_date
)
SELECT 
    ae.id, 999, 'EMERGENCY_APPROVER', 'ceo@company.com',
    'EMERGENCY_APPROVED', 'Critical equipment failure - immediate approval', NOW()
FROM approval_executions ae
JOIN material_requests mr ON ae.request_id = mr.id
WHERE mr.request_number = 'MR-2024-002';

-- 9. Test Delegation Scenario
INSERT INTO approval_delegations (
    delegator_email, delegate_email, role_name, 
    start_date, end_date, reason, is_active
) VALUES 
('manager@company.com', 'deputy.manager@company.com', 'MANAGER',
 NOW(), NOW() + INTERVAL '7 days', 'Vacation delegation', true);

-- 10. Verification Queries
SELECT 'WORKFLOW TEST RESULTS' as section;

-- Show completed approval flow
SELECT 
    mr.request_number,
    mr.total_amount,
    mr.status as request_status,
    ae.status as approval_status,
    ae.current_level,
    ae.total_levels
FROM material_requests mr
JOIN approval_executions ae ON mr.id = ae.request_id
WHERE mr.request_number IN ('MR-2024-001', 'MR-2024-002');

-- Show approval actions taken
SELECT 
    mr.request_number,
    aa.level_number,
    aa.approver_role,
    aa.action,
    aa.comments,
    aa.action_date
FROM material_requests mr
JOIN approval_executions ae ON mr.id = ae.request_id
JOIN approval_actions aa ON ae.id = aa.execution_id
ORDER BY mr.request_number, aa.level_number;

-- Show active delegations
SELECT * FROM approval_delegations WHERE is_active = true;

SELECT 'APPROVAL WORKFLOW TESTING COMPLETED' as result;