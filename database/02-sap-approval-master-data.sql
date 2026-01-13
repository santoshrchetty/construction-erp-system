-- SAP-Aligned Approval Engine - Master Data Setup
-- Run this after 01-sap-approval-schema.sql

-- 1. INSERT STANDARD AGENT RULES
INSERT INTO agent_rules (rule_code, rule_name, rule_type, resolution_logic, description) VALUES
('MANAGER_OF_REQUESTER', 'Direct Manager of Requester', 'HIERARCHY', '{"type": "manager", "levels": 1}', 'Finds immediate manager'),
('DEPT_HEAD_OF_REQUESTER', 'Department Head of Requester', 'HIERARCHY', '{"type": "department_head"}', 'Finds department head'),
('ROLE_FINANCE_MANAGER', 'Finance Manager', 'ROLE', '{"role": "FINANCE_MANAGER", "scope_match": ["company_code"]}', 'Finance manager for same company'),
('ROLE_FINANCE_CONTROLLER', 'Finance Controller', 'ROLE', '{"role": "FINANCE_CONTROLLER", "scope_match": ["company_code"]}', 'Finance controller for same company'),
('ROLE_CFO', 'Chief Financial Officer', 'ROLE', '{"role": "CFO", "scope_match": ["company_code"]}', 'CFO for same company'),
('ROLE_SAFETY_OFFICER', 'Safety Officer', 'ROLE', '{"role": "SAFETY_OFFICER", "scope_match": ["plant_code"]}', 'Safety officer for same plant'),
('ROLE_PLANT_MANAGER', 'Plant Manager', 'ROLE', '{"role": "PLANT_MANAGER", "scope_match": ["plant_code"]}', 'Plant manager for same plant'),
('ROLE_STRUCTURAL_ENGINEER', 'Structural Engineer', 'ROLE', '{"role": "STRUCTURAL_ENGINEER", "scope_match": ["plant_code"]}', 'Structural engineer for same plant'),
('ROLE_ELECTRICAL_ENGINEER', 'Electrical Engineer', 'ROLE', '{"role": "ELECTRICAL_ENGINEER", "scope_match": ["plant_code"]}', 'Electrical engineer for same plant'),
('ROLE_MECHANICAL_ENGINEER', 'Mechanical Engineer', 'ROLE', '{"role": "MECHANICAL_ENGINEER", "scope_match": ["plant_code"]}', 'Mechanical engineer for same plant'),
('PURCHASING_GROUP_BUYER', 'Purchasing Group Buyer', 'RESPONSIBILITY', '{"type": "PURCHASING_GROUP", "match_field": "purchasing_group"}', 'Buyer for purchasing group')
ON CONFLICT (rule_code) DO NOTHING;

-- 2. INSERT SAMPLE ORGANIZATIONAL HIERARCHY
INSERT INTO org_hierarchy (employee_id, employee_name, manager_id, department_code, plant_code, company_code, position_title, email) VALUES
-- C-Level
('EMP001', 'Rajesh Kumar', NULL, 'EXEC', 'HQ', 'C001', 'CEO', 'rajesh.kumar@company.com'),
('EMP002', 'Priya Sharma', 'EMP001', 'FINANCE', 'HQ', 'C001', 'CFO', 'priya.sharma@company.com'),
('EMP003', 'Amit Singh', 'EMP001', 'OPERATIONS', 'HQ', 'C001', 'COO', 'amit.singh@company.com'),

-- Finance Team
('EMP004', 'Sunita Patel', 'EMP002', 'FINANCE', 'HQ', 'C001', 'Finance Manager', 'sunita.patel@company.com'),
('EMP005', 'Vikram Gupta', 'EMP004', 'FINANCE', 'HQ', 'C001', 'Finance Controller', 'vikram.gupta@company.com'),

-- Plant Managers
('EMP006', 'Ravi Mehta', 'EMP003', 'OPERATIONS', 'PLT_MUM', 'C001', 'Plant Manager - Mumbai', 'ravi.mehta@company.com'),
('EMP007', 'Kavita Joshi', 'EMP003', 'OPERATIONS', 'PLT_DEL', 'C001', 'Plant Manager - Delhi', 'kavita.joshi@company.com'),

-- Engineering Team
('EMP008', 'Deepak Rao', 'EMP006', 'ENGINEERING', 'PLT_MUM', 'C001', 'Structural Engineer', 'deepak.rao@company.com'),
('EMP009', 'Neha Agarwal', 'EMP006', 'ENGINEERING', 'PLT_MUM', 'C001', 'Electrical Engineer', 'neha.agarwal@company.com'),
('EMP010', 'Suresh Nair', 'EMP006', 'ENGINEERING', 'PLT_MUM', 'C001', 'Mechanical Engineer', 'suresh.nair@company.com'),

-- Safety Team
('EMP011', 'Anita Desai', 'EMP006', 'SAFETY', 'PLT_MUM', 'C001', 'Safety Officer', 'anita.desai@company.com'),
('EMP012', 'Manoj Tiwari', 'EMP007', 'SAFETY', 'PLT_DEL', 'C001', 'Safety Officer', 'manoj.tiwari@company.com'),

-- Procurement Team
('EMP013', 'Rohit Verma', 'EMP003', 'PROCUREMENT', 'HQ', 'C001', 'Procurement Manager', 'rohit.verma@company.com'),
('EMP014', 'Sanjay Jain', 'EMP013', 'PROCUREMENT', 'HQ', 'C001', 'Senior Buyer', 'sanjay.jain@company.com'),

-- Regular Employees
('EMP015', 'Pooja Reddy', 'EMP006', 'OPERATIONS', 'PLT_MUM', 'C001', 'Site Supervisor', 'pooja.reddy@company.com'),
('EMP016', 'Arjun Pillai', 'EMP007', 'OPERATIONS', 'PLT_DEL', 'C001', 'Site Supervisor', 'arjun.pillai@company.com')
ON CONFLICT (employee_id) DO NOTHING;

-- 3. INSERT ROLE ASSIGNMENTS
INSERT INTO role_assignments (employee_id, role_code, scope_type, scope_value) VALUES
-- Finance Roles
('EMP002', 'CFO', 'COMPANY', 'C001'),
('EMP004', 'FINANCE_MANAGER', 'COMPANY', 'C001'),
('EMP005', 'FINANCE_CONTROLLER', 'COMPANY', 'C001'),

-- Plant Management Roles
('EMP006', 'PLANT_MANAGER', 'PLANT', 'PLT_MUM'),
('EMP007', 'PLANT_MANAGER', 'PLANT', 'PLT_DEL'),

-- Engineering Roles
('EMP008', 'STRUCTURAL_ENGINEER', 'PLANT', 'PLT_MUM'),
('EMP009', 'ELECTRICAL_ENGINEER', 'PLANT', 'PLT_MUM'),
('EMP010', 'MECHANICAL_ENGINEER', 'PLANT', 'PLT_MUM'),

-- Safety Roles
('EMP011', 'SAFETY_OFFICER', 'PLANT', 'PLT_MUM'),
('EMP012', 'SAFETY_OFFICER', 'PLANT', 'PLT_DEL'),

-- Department Head Roles
('EMP002', 'DEPT_HEAD', 'DEPARTMENT', 'FINANCE'),
('EMP003', 'DEPT_HEAD', 'DEPARTMENT', 'OPERATIONS'),
('EMP013', 'DEPT_HEAD', 'DEPARTMENT', 'PROCUREMENT')
ON CONFLICT (employee_id, role_code, scope_type, scope_value) DO NOTHING;

-- 4. INSERT RESPONSIBILITY ASSIGNMENTS
INSERT INTO responsibility_assignments (employee_id, responsibility_type, responsibility_value, approval_limit) VALUES
-- Purchasing Groups
('EMP013', 'PURCHASING_GROUP', 'PG_CONSTRUCTION', 500000.00),
('EMP014', 'PURCHASING_GROUP', 'PG_CONSTRUCTION', 100000.00),
('EMP014', 'PURCHASING_GROUP', 'PG_ELECTRICAL', 50000.00),
('EMP014', 'PURCHASING_GROUP', 'PG_MECHANICAL', 50000.00),

-- Material Groups
('EMP008', 'MATERIAL_GROUP', 'MAT_STRUCTURAL', 200000.00),
('EMP009', 'MATERIAL_GROUP', 'MAT_ELECTRICAL', 100000.00),
('EMP010', 'MATERIAL_GROUP', 'MAT_MECHANICAL', 100000.00),
('EMP011', 'MATERIAL_GROUP', 'MAT_SAFETY', 25000.00)
ON CONFLICT (employee_id, responsibility_type, responsibility_value) DO NOTHING;