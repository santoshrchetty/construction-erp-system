-- Check existing tables and their data
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' 
AND table_name IN ('persons_responsible', 'cost_centers', 'profit_centers', 'plants', 'employees', 'departments', 'locations');

-- Check what data exists in potential source tables
SELECT 'employees' as source, count(*) as count FROM employees WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'employees')
UNION ALL
SELECT 'departments' as source, count(*) as count FROM departments WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'departments')
UNION ALL
SELECT 'cost_centers' as source, count(*) as count FROM cost_centers WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'cost_centers')
UNION ALL
SELECT 'profit_centers' as source, count(*) as count FROM profit_centers WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profit_centers')
UNION ALL
SELECT 'plants' as source, count(*) as count FROM plants WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'plants');

-- Populate from existing employees table if it exists
INSERT INTO persons_responsible (person_id, first_name, last_name, email, company_code, is_active)
SELECT employee_id, first_name, last_name, email, 'C001', true 
FROM employees 
WHERE EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'employees')
ON CONFLICT DO NOTHING;

-- If no employees table, create sample data
INSERT INTO persons_responsible (person_id, first_name, last_name, email, company_code, is_active) 
SELECT * FROM (VALUES 
('PR001', 'John', 'Smith', 'john.smith@company.com', 'C001', true),
('PR002', 'Sarah', 'Johnson', 'sarah.johnson@company.com', 'C001', true),
('PR003', 'Mike', 'Davis', 'mike.davis@company.com', 'C001', true)
) AS v(person_id, first_name, last_name, email, company_code, is_active)
WHERE NOT EXISTS (SELECT 1 FROM persons_responsible WHERE company_code = 'C001')
ON CONFLICT DO NOTHING;