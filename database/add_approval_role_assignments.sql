-- Role Assignments for Flexible Approval System
-- Assign authorization objects to appropriate roles

-- Admin role gets all configuration and analytics access
INSERT INTO role_authorization_objects (role_id, auth_object_id, field_values) VALUES
-- Admin gets all approval configuration access
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'AD_APPR_CFG'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'AD_APPR_TPL'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'AD_CUST_APPR'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'AD_APPR_RPT'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'CF_DOC_TYPES'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'CF_APPR_ROLES'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'CF_THRESHOLDS'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'CF_NOTIFICATIONS'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'IN_ERP_SYNC'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'IN_MOBILE_APPR'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Admin'), (SELECT id FROM authorization_objects WHERE object_name = 'EM_OVERRIDE'), '{"ACTVT": ["01", "02", "03"]}'),

-- Manager role gets approval and reporting access
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_REQ_UNIFIED'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_REQ_APPROVE'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_REQ_STATUS'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_APPR_DELEG'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_PR_FLEXIBLE'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_PO_FLEXIBLE'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_PROC_APPR'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_VEND_APPR'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'RP_APPR_PERF'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'RP_PEND_APPR'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'RP_APPR_AUDIT'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'RP_DELEGATIONS'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'EM_APPROVALS'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'EM_BULK_APPR'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Manager'), (SELECT id FROM authorization_objects WHERE object_name = 'EM_OVERRIDE'), '{"ACTVT": ["01", "02", "03"]}'),

-- Engineer role gets request creation and tracking access
((SELECT id FROM roles WHERE name = 'Engineer'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_REQ_UNIFIED'), '{"ACTVT": ["01", "02"]}'),
((SELECT id FROM roles WHERE name = 'Engineer'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_REQ_STATUS'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Engineer'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_PR_FLEXIBLE'), '{"ACTVT": ["01", "02"]}'),
((SELECT id FROM roles WHERE name = 'Engineer'), (SELECT id FROM authorization_objects WHERE object_name = 'UT_PEND_APPR'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Engineer'), (SELECT id FROM authorization_objects WHERE object_name = 'UT_APPR_HIST'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Engineer'), (SELECT id FROM authorization_objects WHERE object_name = 'UT_DELEGATIONS'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Engineer'), (SELECT id FROM authorization_objects WHERE object_name = 'UT_REQ_STATUS'), '{"ACTVT": ["03"]}'),

-- Storekeeper role gets material request and approval access
((SELECT id FROM roles WHERE name = 'Storekeeper'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_REQ_UNIFIED'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Storekeeper'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_REQ_APPROVE'), '{"ACTVT": ["01", "02", "03"]}'),
((SELECT id FROM roles WHERE name = 'Storekeeper'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_REQ_STATUS'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Storekeeper'), (SELECT id FROM authorization_objects WHERE object_name = 'UT_PEND_APPR'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Storekeeper'), (SELECT id FROM authorization_objects WHERE object_name = 'UT_APPR_HIST'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Storekeeper'), (SELECT id FROM authorization_objects WHERE object_name = 'UT_REQ_STATUS'), '{"ACTVT": ["03"]}'),

-- Employee role gets basic request access
((SELECT id FROM roles WHERE name = 'Employee'), (SELECT id FROM authorization_objects WHERE object_name = 'MM_REQ_UNIFIED'), '{"ACTVT": ["01"]}'),
((SELECT id FROM roles WHERE name = 'Employee'), (SELECT id FROM authorization_objects WHERE object_name = 'UT_REQ_STATUS'), '{"ACTVT": ["03"]}'),
((SELECT id FROM roles WHERE name = 'Employee'), (SELECT id FROM authorization_objects WHERE object_name = 'UT_APPR_HIST'), '{"ACTVT": ["03"]}')

ON CONFLICT (role_id, auth_object_id) DO UPDATE SET
  field_values = EXCLUDED.field_values;

-- Verify role assignments
SELECT 'ROLE ASSIGNMENTS SUMMARY:' as info;
SELECT 
  r.name as role_name,
  COUNT(*) as total_permissions,
  COUNT(CASE WHEN ao.object_name LIKE 'AD_%' THEN 1 END) as admin_permissions,
  COUNT(CASE WHEN ao.object_name LIKE 'MM_%' THEN 1 END) as materials_permissions,
  COUNT(CASE WHEN ao.object_name LIKE 'CF_%' THEN 1 END) as config_permissions,
  COUNT(CASE WHEN ao.object_name LIKE 'RP_%' THEN 1 END) as report_permissions,
  COUNT(CASE WHEN ao.object_name LIKE 'UT_%' THEN 1 END) as user_permissions,
  COUNT(CASE WHEN ao.object_name LIKE 'EM_%' THEN 1 END) as emergency_permissions
FROM role_authorization_objects rao
JOIN roles r ON rao.role_id = r.id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE ao.object_name IN (
  'AD_APPR_CFG', 'AD_APPR_TPL', 'AD_CUST_APPR', 'AD_APPR_RPT',
  'MM_REQ_UNIFIED', 'MM_REQ_APPROVE', 'MM_REQ_STATUS', 'MM_APPR_DELEG',
  'MM_PR_FLEXIBLE', 'MM_PO_FLEXIBLE', 'MM_PROC_APPR', 'MM_VEND_APPR',
  'CF_DOC_TYPES', 'CF_APPR_ROLES', 'CF_THRESHOLDS', 'CF_NOTIFICATIONS',
  'RP_APPR_PERF', 'RP_PEND_APPR', 'RP_APPR_AUDIT', 'RP_DELEGATIONS',
  'UT_PEND_APPR', 'UT_APPR_HIST', 'UT_DELEGATIONS', 'UT_REQ_STATUS',
  'EM_APPROVALS', 'EM_OVERRIDE', 'EM_BULK_APPR',
  'IN_ERP_SYNC', 'IN_MOBILE_APPR'
)
AND rao.is_active = true
GROUP BY r.name
ORDER BY total_permissions DESC;