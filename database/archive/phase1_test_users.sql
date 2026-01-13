-- Phase 1: Create Test Users for Construction Roles
-- =================================================

-- Create test users for different construction roles
INSERT INTO users (id, email, first_name, last_name, role_id, employee_code, department, is_active) 
SELECT 
  gen_random_uuid(),
  'siteengineer@nttdemo.com',
  'Site',
  'Engineer',
  r.id,
  'SE001',
  'Engineering',
  true
FROM roles r WHERE r.name = 'Site Engineer'
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (id, email, first_name, last_name, role_id, employee_code, department, is_active) 
SELECT 
  gen_random_uuid(),
  'projectmanager@nttdemo.com',
  'Project',
  'Manager',
  r.id,
  'PM001',
  'Project Management',
  true
FROM roles r WHERE r.name = 'Project Manager'
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (id, email, first_name, last_name, role_id, employee_code, department, is_active) 
SELECT 
  gen_random_uuid(),
  'procurement@nttdemo.com',
  'Procurement',
  'Manager',
  r.id,
  'PR001',
  'Procurement',
  true
FROM roles r WHERE r.name = 'Procurement Mgr'
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (id, email, first_name, last_name, role_id, employee_code, department, is_active) 
SELECT 
  gen_random_uuid(),
  'storekeeper@nttdemo.com',
  'Store',
  'Keeper',
  r.id,
  'SK001',
  'Warehouse',
  true
FROM roles r WHERE r.name = 'Store Keeper'
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (id, email, first_name, last_name, role_id, employee_code, department, is_active) 
SELECT 
  gen_random_uuid(),
  'financemanager@nttdemo.com',
  'Finance',
  'Manager',
  r.id,
  'FM001',
  'Finance',
  true
FROM roles r WHERE r.name = 'Finance Manager'
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (id, email, first_name, last_name, role_id, employee_code, department, is_active) 
SELECT 
  gen_random_uuid(),
  'qualitymanager@nttdemo.com',
  'Quality',
  'Manager',
  r.id,
  'QM001',
  'Quality Assurance',
  true
FROM roles r WHERE r.name = 'Quality Manager'
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (id, email, first_name, last_name, role_id, employee_code, department, is_active) 
SELECT 
  gen_random_uuid(),
  'safetyofficer@nttdemo.com',
  'Safety',
  'Officer',
  r.id,
  'SO001',
  'Safety',
  true
FROM roles r WHERE r.name = 'Safety Officer'
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (id, email, first_name, last_name, role_id, employee_code, department, is_active) 
SELECT 
  gen_random_uuid(),
  'planningengineer@nttdemo.com',
  'Planning',
  'Engineer',
  r.id,
  'PE001',
  'Planning',
  true
FROM roles r WHERE r.name = 'Planning Engr'
ON CONFLICT (email) DO NOTHING;

-- Verify created users
SELECT 'CONSTRUCTION ROLE USERS' as status, 
       u.email, 
       u.first_name || ' ' || u.last_name as full_name,
       r.name as role_name,
       u.employee_code,
       u.department,
       u.is_active
FROM users u
JOIN roles r ON u.role_id = r.id
WHERE u.email LIKE '%@nttdemo.com'
AND r.name IN ('Site Engineer', 'Project Manager', 'Procurement Mgr', 'Store Keeper', 'Finance Manager', 'Quality Manager', 'Safety Officer', 'Planning Engr')
ORDER BY r.name;