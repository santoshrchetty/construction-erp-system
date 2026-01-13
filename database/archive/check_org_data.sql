-- Check organizational hierarchy data
SELECT 'Organizational Hierarchy' as table_name, COUNT(*) as record_count FROM organizational_hierarchy
UNION ALL
SELECT 'Functional Approver Assignments', COUNT(*) FROM functional_approver_assignments
UNION ALL
SELECT 'Approval Delegations', COUNT(*) FROM approval_delegations;

-- Check if org data exists
SELECT * FROM organizational_hierarchy LIMIT 5;
SELECT * FROM functional_approver_assignments LIMIT 5;