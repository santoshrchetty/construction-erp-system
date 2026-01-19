-- Get project_id for HW-0001
SELECT id as project_id, code, name FROM projects WHERE code = 'HW-0001';

-- Get activity IDs and their project_id
SELECT a.id as activity_id, a.code, a.name, a.project_id
FROM activities a
WHERE a.code IN ('HW-0001.01-A01', 'HW-0001.01-A02', 'HW-0001.01-A03', 'HW-0001.02-A01')
ORDER BY a.code;
