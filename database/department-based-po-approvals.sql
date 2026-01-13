-- DEPARTMENT-BASED PO APPROVAL POLICIES

-- Insert department-specific PO approval policies
INSERT INTO approval_policies (
    id, customer_id, policy_name,
    approval_object_type, approval_object_document_type,
    company_code, department_code,
    approval_strategy, approval_pattern,
    amount_thresholds, functional_domains,
    is_active
) VALUES 
-- Engineering Department
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Engineering PO Policy', 'PO', 'NB', 'C001', 'ENG',
 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"currency": "USD", "thresholds": [
   {"min": 0, "max": 25000, "authority": "ENG_SUPERVISOR"},
   {"min": 25001, "max": 100000, "authority": "ENG_MANAGER"},
   {"min": 100001, "max": 999999999, "authority": "ENG_DIRECTOR"}
 ]}',
 '{"FINANCE": {"mandatory": true, "scope": "DEPARTMENT"}}',
 true),

-- Construction Department  
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Construction PO Policy', 'PO', 'NB', 'C001', 'CONST',
 'AMOUNT_BASED', 'HIERARCHY_ONLY', 
 '{"currency": "USD", "thresholds": [
   {"min": 0, "max": 50000, "authority": "CONST_SUPERVISOR"},
   {"min": 50001, "max": 200000, "authority": "CONST_MANAGER"},
   {"min": 200001, "max": 999999999, "authority": "CONST_DIRECTOR"}
 ]}',
 '{"FINANCE": {"mandatory": true, "scope": "DEPARTMENT"}, "SAFETY": {"mandatory": true, "scope": "DEPARTMENT"}}',
 true),

-- Procurement Department
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Procurement PO Policy', 'PO', 'NB', 'C001', 'PROC',
 'AMOUNT_BASED', 'FUNCTIONAL_THEN_HIERARCHY',
 '{"currency": "USD", "thresholds": [
   {"min": 0, "max": 100000, "authority": "PROC_BUYER"},
   {"min": 100001, "max": 500000, "authority": "PROC_MANAGER"},
   {"min": 500001, "max": 999999999, "authority": "PROC_DIRECTOR"}
 ]}',
 '{"FINANCE": {"mandatory": true, "scope": "DEPARTMENT"}, "LEGAL": {"mandatory": false, "scope": "COUNTRY"}}',
 true),

-- Finance Department
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Finance PO Policy', 'PO', 'NB', 'C001', 'FIN',
 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"currency": "USD", "thresholds": [
   {"min": 0, "max": 75000, "authority": "FIN_ANALYST"},
   {"min": 75001, "max": 300000, "authority": "FIN_MANAGER"},
   {"min": 300001, "max": 999999999, "authority": "CFO"}
 ]}',
 '{"FINANCE": {"mandatory": true, "scope": "DEPARTMENT"}}',
 true);

-- Department-specific functional approvers
INSERT INTO functional_approver_assignments (
    customer_id, functional_domain, approver_user_id, approver_role,
    approval_scope, company_code, department_code, approval_limit, is_active
) VALUES
-- Engineering Department Finance Approver
('550e8400-e29b-41d4-a716-446655440001', 'FINANCE', 'eng_finance_mgr', 'ENG_FINANCE_MANAGER',
 'DEPARTMENT', 'C001', 'ENG', 100000, true),

-- Construction Department Safety Approver  
('550e8400-e29b-41d4-a716-446655440001', 'SAFETY', 'const_safety_mgr', 'CONST_SAFETY_MANAGER',
 'DEPARTMENT', 'C001', 'CONST', 999999999, true),

-- Procurement Department Legal Approver
('550e8400-e29b-41d4-a716-446655440001', 'LEGAL', 'proc_legal_counsel', 'PROC_LEGAL_COUNSEL',
 'COUNTRY', 'C001', 'PROC', 500000, true);

SELECT 'DEPARTMENT-BASED PO APPROVALS CONFIGURED' as status;