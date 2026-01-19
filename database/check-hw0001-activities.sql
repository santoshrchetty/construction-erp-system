-- Check if project HW-0001 exists
SELECT id, code, name FROM projects WHERE code = 'HW-0001';

-- Check activities for project HW-0001
SELECT 
  a.id,
  a.code,
  a.name,
  a.planned_start_date,
  a.planned_end_date
FROM activities a
JOIN projects p ON a.project_id = p.id
WHERE p.code = 'HW-0001'
ORDER BY a.code
LIMIT 5;

-- Check if we have materials in the system
SELECT id, material_code, material_name, base_uom, standard_price 
FROM materials 
LIMIT 5;

-- Check table structures for resource planning
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name LIKE '%activity%'
ORDER BY table_name;
