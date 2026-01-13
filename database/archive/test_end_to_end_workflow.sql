-- End-to-End Approval Workflow Test with Smart Routing
-- Tests complete workflow from request creation to final approval

-- Test 1: Global Approval Workflow ($15,000 office equipment)
INSERT INTO material_requests (
    request_number, request_type, status, priority, requested_by, 
    total_amount, currency_code, plant_code, created_by
) VALUES (
    'MR-GLOBAL-001', 'MATERIAL_REQ', 'SUBMITTED', 'MEDIUM', 
    '550e8400-e29b-41d4-a716-446655440001', 15000.00, 'USD', 'B001',
    '550e8400-e29b-41d4-a716-446655440001'
);

-- Create approval execution using smart routing
INSERT INTO approval_executions (
    request_id, config_id, current_level, status, total_levels, execution_path
)
SELECT 
    mr.id,
    cac.id,
    1,
    'PENDING',
    (SELECT COUNT(*) FROM get_smart_approval_path(
        '550e8400-e29b-41d4-a716-446655440001'::UUID, 'MATERIAL_REQ', 15000.00
    )),
    jsonb_build_object('routing', 'GLOBAL', 'amount', 15000)
FROM material_requests mr
JOIN customer_approval_configuration cac ON cac.customer_id = '550e8400-e29b-41d4-a716-446655440001'
WHERE mr.request_number = 'MR-GLOBAL-001' AND cac.document_type = 'MATERIAL_REQ';

-- Test 2: Department Approval Workflow ($75,000 construction materials)
INSERT INTO material_requests (
    request_number, request_type, status, priority, requested_by, 
    total_amount, currency_code, plant_code, created_by
) VALUES (
    'MR-DEPT-001', 'MATERIAL_REQ', 'SUBMITTED', 'HIGH', 
    '550e8400-e29b-41d4-a716-446655440001', 75000.00, 'USD', 'B001',
    '550e8400-e29b-41d4-a716-446655440001'
);

-- Test 3: Project Approval Workflow ($300,000 critical project)
INSERT INTO material_requests (
    request_number, request_type, status, priority, requested_by, 
    total_amount, currency_code, plant_code, project_code, created_by
) VALUES (
    'MR-PROJECT-001', 'MATERIAL_REQ', 'SUBMITTED', 'URGENT', 
    '550e8400-e29b-41d4-a716-446655440001', 300000.00, 'USD', 'B001', 'CRITICAL-INFRA-001',
    '550e8400-e29b-41d4-a716-446655440001'
);

-- Verify smart routing works for all scenarios
SELECT 'SMART ROUTING VERIFICATION:' as info;

SELECT 
    mr.request_number,
    mr.total_amount,
    'N/A' as department,
    mr.project_code,
    path.level_name,
    path.approver_role,
    path.scope_type,
    path.routing_reason
FROM material_requests mr
CROSS JOIN LATERAL get_smart_approval_path(
    '550e8400-e29b-41d4-a716-446655440001'::UUID,
    'MATERIAL_REQ',
    mr.total_amount,
    CASE 
        WHEN mr.request_number = 'MR-DEPT-001' THEN 'CONSTRUCTION'
        WHEN mr.request_number = 'MR-PROJECT-001' THEN 'CONSTRUCTION'
        ELSE NULL
    END,
    mr.project_code
) path
WHERE mr.request_number IN ('MR-GLOBAL-001', 'MR-DEPT-001', 'MR-PROJECT-001')
ORDER BY mr.request_number, path.level_number;

-- Test approval actions for global workflow
INSERT INTO approval_actions (
    execution_id, level_number, approver_id, approver_role, action, comments
)
SELECT 
    ae.id, 1, '550e8400-e29b-41d4-a716-446655440001'::UUID, 'DEPT_MANAGER', 'APPROVED', 'Standard approval'
FROM approval_executions ae
JOIN material_requests mr ON ae.request_id = mr.id
WHERE mr.request_number = 'MR-GLOBAL-001';

-- Update to next level
UPDATE approval_executions 
SET current_level = 2, status = 'IN_PROGRESS'
WHERE request_id = (SELECT id FROM material_requests WHERE request_number = 'MR-GLOBAL-001');

-- Final approval
INSERT INTO approval_actions (
    execution_id, level_number, approver_id, approver_role, action, comments
)
SELECT 
    ae.id, 2, '550e8400-e29b-41d4-a716-446655440002'::UUID, 'FINANCE_MANAGER', 'APPROVED', 'Budget approved'
FROM approval_executions ae
JOIN material_requests mr ON ae.request_id = mr.id
WHERE mr.request_number = 'MR-GLOBAL-001';

-- Complete workflow
UPDATE approval_executions 
SET status = 'COMPLETED', completed_at = NOW()
WHERE request_id = (SELECT id FROM material_requests WHERE request_number = 'MR-GLOBAL-001');

UPDATE material_requests 
SET status = 'APPROVED'
WHERE request_number = 'MR-GLOBAL-001';

-- Final verification
SELECT 'WORKFLOW COMPLETION STATUS:' as info;

SELECT 
    mr.request_number,
    mr.total_amount,
    mr.status as request_status,
    ae.status as approval_status,
    ae.current_level,
    ae.total_levels,
    COUNT(aa.id) as actions_taken
FROM material_requests mr
LEFT JOIN approval_executions ae ON mr.id = ae.request_id
LEFT JOIN approval_actions aa ON ae.id = aa.execution_id
WHERE mr.request_number LIKE 'MR-%001'
GROUP BY mr.id, mr.request_number, mr.total_amount, mr.status, ae.status, ae.current_level, ae.total_levels
ORDER BY mr.request_number;

SELECT 'END-TO-END WORKFLOW TEST COMPLETED' as result;