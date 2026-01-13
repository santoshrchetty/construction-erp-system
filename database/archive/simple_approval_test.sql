-- Minimal Approval Workflow Test
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Clean up ALL existing data for this customer (complete cleanup)
DELETE FROM approval_actions WHERE execution_id IN (
  SELECT ae.id FROM approval_executions ae
  JOIN customer_approval_configuration cac ON ae.config_id = cac.id
  WHERE cac.customer_id = '550e8400-e29b-41d4-a716-446655440001'
);

DELETE FROM approval_executions WHERE config_id IN (
  SELECT id FROM customer_approval_configuration 
  WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
);

DELETE FROM material_requests WHERE requested_by = '550e8400-e29b-41d4-a716-446655440001';

DELETE FROM flexible_approval_levels 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001';

DELETE FROM customer_approval_configuration 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001';

-- Create approval configuration
INSERT INTO customer_approval_configuration (
    customer_id, document_type, config_name, is_template_based
) VALUES (
    '550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 'Test Config', false
);

-- Create approval levels
INSERT INTO flexible_approval_levels (
    customer_id, document_type, level_number, level_name, 
    amount_threshold_min, amount_threshold_max, approver_role
) VALUES 
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 1, 'Supervisor', 0, 999999999, 'SUPERVISOR'),
('550e8400-e29b-41d4-a716-446655440001', 'MATERIAL_REQ', 2, 'Manager', 0, 999999999, 'MANAGER');

-- Create test request
INSERT INTO material_requests (
    request_number, request_type, status, requested_by, 
    total_amount, created_by
) VALUES (
    'MR-TEST-001', 'MATERIAL_REQ', 'SUBMITTED', 
    '550e8400-e29b-41d4-a716-446655440001', 15000.00,
    '550e8400-e29b-41d4-a716-446655440001'
);

-- Create execution
INSERT INTO approval_executions (
    request_id, config_id, current_level, status, total_levels, execution_path
)
SELECT 
    mr.id, cac.id, 1, 'PENDING', 2, '{}'
FROM material_requests mr, customer_approval_configuration cac
WHERE mr.request_number = 'MR-TEST-001' 
AND cac.customer_id = '550e8400-e29b-41d4-a716-446655440001';

-- First approval
INSERT INTO approval_actions (
    execution_id, level_number, approver_id, approver_role, action, comments
)
SELECT 
    ae.id, 1, '550e8400-e29b-41d4-a716-446655440001'::UUID, 'SUPERVISOR', 'APPROVED', 'OK'
FROM approval_executions ae
JOIN material_requests mr ON ae.request_id = mr.id
WHERE mr.request_number = 'MR-TEST-001';

-- Update level
UPDATE approval_executions 
SET current_level = 2, status = 'IN_PROGRESS'
WHERE request_id = (SELECT id FROM material_requests WHERE request_number = 'MR-TEST-001');

-- Final approval
INSERT INTO approval_actions (
    execution_id, level_number, approver_id, approver_role, action, comments
)
SELECT 
    ae.id, 2, '550e8400-e29b-41d4-a716-446655440002'::UUID, 'MANAGER', 'APPROVED', 'Final OK'
FROM approval_executions ae
JOIN material_requests mr ON ae.request_id = mr.id
WHERE mr.request_number = 'MR-TEST-001';

-- Complete
UPDATE approval_executions 
SET status = 'COMPLETED', completed_at = NOW()
WHERE request_id = (SELECT id FROM material_requests WHERE request_number = 'MR-TEST-001');

UPDATE material_requests 
SET status = 'APPROVED'
WHERE request_number = 'MR-TEST-001';

-- Results
SELECT 'TEST RESULTS' as info;

SELECT 
    mr.request_number,
    mr.total_amount,
    mr.status,
    ae.current_level,
    ae.status as execution_status
FROM material_requests mr
JOIN approval_executions ae ON mr.id = ae.request_id
WHERE mr.request_number = 'MR-TEST-001';

SELECT 
    aa.level_number,
    aa.approver_role,
    aa.action,
    aa.comments
FROM material_requests mr
JOIN approval_executions ae ON mr.id = ae.request_id
JOIN approval_actions aa ON ae.id = aa.execution_id
WHERE mr.request_number = 'MR-TEST-001'
ORDER BY aa.level_number;

SELECT 'WORKFLOW TEST COMPLETED' as result;