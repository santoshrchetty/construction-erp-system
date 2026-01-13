-- Construction Industry Standard Approval Levels
-- Based on industry best practices and risk management

-- Clear existing workflows
DELETE FROM approval_workflows;

-- LEVEL 1: OPERATIONAL APPROVALS (Day-to-Day Operations)
-- Amount Range: $0 - $10,000
-- Approvers: Site Supervisors, Team Leads, Foremen
INSERT INTO approval_workflows (
  workflow_name, request_type, company_code, material_category, amount_threshold,
  level_1_approver_role, level_1_amount_limit,
  level_2_approver_role, level_2_amount_limit,
  level_3_approver_role, level_3_amount_limit
) VALUES
-- Small consumables and supplies
('Operational Materials', 'MATERIAL_REQ', 'C001', 'CONSUMABLES', 0, 'SITE_SUPERVISOR', 5000, 'SITE_MANAGER', 10000, NULL, NULL),
('Operational Tools', 'MATERIAL_REQ', 'C001', 'TOOLS', 0, 'FOREMAN', 3000, 'SITE_SUPERVISOR', 8000, NULL, NULL),
('Safety Equipment', 'MATERIAL_REQ', 'C001', 'SAFETY', 0, 'SAFETY_OFFICER', 5000, 'SITE_MANAGER', 15000, NULL, NULL);

-- LEVEL 2: TACTICAL APPROVALS (Project-Level Decisions)
-- Amount Range: $10,000 - $100,000
-- Approvers: Site Managers, Project Engineers, Department Heads
INSERT INTO approval_workflows (
  workflow_name, request_type, company_code, material_category, amount_threshold,
  level_1_approver_role, level_1_amount_limit,
  level_2_approver_role, level_2_amount_limit,
  level_3_approver_role, level_3_amount_limit
) VALUES
-- Construction materials
('Construction Materials - Standard', 'PURCHASE_REQ', 'C001', 'CONSTRUCTION', 5000, 'SITE_ENGINEER', 25000, 'PROJECT_MANAGER', 75000, 'OPERATIONS_MANAGER', 100000),
('Steel & Structural', 'PURCHASE_REQ', 'C001', 'STEEL', 10000, 'STRUCTURAL_ENGINEER', 50000, 'PROJECT_MANAGER', 100000, 'TECHNICAL_DIRECTOR', 250000),
('Concrete & Cement', 'PURCHASE_REQ', 'C001', 'CONCRETE', 5000, 'SITE_ENGINEER', 30000, 'PROJECT_MANAGER', 80000, 'OPERATIONS_MANAGER', 150000);

-- LEVEL 3: STRATEGIC APPROVALS (High-Value/Risk Items)
-- Amount Range: $100,000 - $500,000
-- Approvers: Operations Managers, Technical Directors, General Managers
INSERT INTO approval_workflows (
  workflow_name, request_type, company_code, material_category, amount_threshold,
  level_1_approver_role, level_1_amount_limit,
  level_2_approver_role, level_2_amount_limit,
  level_3_approver_role, level_3_amount_limit
) VALUES
-- Heavy equipment and machinery
('Equipment Purchase', 'PURCHASE_REQ', 'C001', 'EQUIPMENT', 50000, 'EQUIPMENT_MANAGER', 150000, 'OPERATIONS_MANAGER', 300000, 'GENERAL_MANAGER', 500000),
('Specialized Materials', 'PURCHASE_REQ', 'C001', 'SPECIALIZED', 25000, 'TECHNICAL_MANAGER', 100000, 'TECHNICAL_DIRECTOR', 250000, 'GENERAL_MANAGER', 500000);

-- LEVEL 4: EXECUTIVE APPROVALS (Capital Expenditure)
-- Amount Range: $500,000+
-- Approvers: C-Level Executives, Board of Directors
INSERT INTO approval_workflows (
  workflow_name, request_type, company_code, material_category, amount_threshold,
  level_1_approver_role, level_1_amount_limit,
  level_2_approver_role, level_2_amount_limit,
  level_3_approver_role, level_3_amount_limit
) VALUES
-- Capital expenditure
('Capital Equipment', 'PURCHASE_REQ', 'C001', 'CAPITAL', 100000, 'OPERATIONS_MANAGER', 500000, 'CFO', 1000000, 'CEO', 5000000),
('Major Contracts', 'PURCHASE_REQ', 'C001', 'CONTRACT', 250000, 'GENERAL_MANAGER', 1000000, 'CEO', 2500000, 'BOARD_APPROVAL', 999999999);

-- SPECIAL WORKFLOWS: Fast-Track and Emergency
INSERT INTO approval_workflows (
  workflow_name, request_type, company_code, material_category, amount_threshold,
  level_1_approver_role, level_1_amount_limit,
  level_2_approver_role, level_2_amount_limit,
  level_3_approver_role, level_3_amount_limit
) VALUES
-- Emergency requests (24/7 operations)
('Emergency Materials', 'MATERIAL_REQ', 'C001', 'EMERGENCY', 0, 'DUTY_MANAGER', 15000, 'OPERATIONS_MANAGER', 50000, 'GENERAL_MANAGER', 100000),
-- Project reservations (planning phase)
('Project Reservations', 'RESERVATION', 'C001', NULL, 0, 'PROJECT_ENGINEER', 50000, 'PROJECT_MANAGER', 200000, 'OPERATIONS_MANAGER', 500000);

-- APPROVAL LEVEL SUMMARY
SELECT 'CONSTRUCTION INDUSTRY APPROVAL LEVELS:' as info;

SELECT 
  'LEVEL 1 - OPERATIONAL ($0-$10K)' as approval_level,
  'Site Supervisors, Foremen, Safety Officers' as approvers,
  'Daily consumables, tools, safety equipment' as scope;

SELECT 
  'LEVEL 2 - TACTICAL ($10K-$100K)' as approval_level,
  'Site Engineers, Project Managers, Department Heads' as approvers,
  'Construction materials, project supplies' as scope;

SELECT 
  'LEVEL 3 - STRATEGIC ($100K-$500K)' as approval_level,
  'Operations Managers, Technical Directors' as approvers,
  'Equipment, specialized materials, major purchases' as scope;

SELECT 
  'LEVEL 4 - EXECUTIVE ($500K+)' as approval_level,
  'C-Level, Board of Directors' as approvers,
  'Capital expenditure, major contracts' as scope;

-- APPROVAL THRESHOLDS BY ROLE
SELECT 'RECOMMENDED APPROVAL THRESHOLDS BY ROLE:' as info;

CREATE TABLE approval_role_limits (
  role_name VARCHAR(50) PRIMARY KEY,
  max_single_approval DECIMAL(15,2),
  max_monthly_total DECIMAL(15,2),
  description TEXT
);

INSERT INTO approval_role_limits VALUES
-- Operational Level
('FOREMAN', 5000, 25000, 'Site-level operational decisions'),
('SITE_SUPERVISOR', 10000, 50000, 'Daily site operations and safety'),
('SAFETY_OFFICER', 15000, 75000, 'Safety equipment and compliance'),

-- Tactical Level  
('SITE_ENGINEER', 25000, 150000, 'Technical materials and site engineering'),
('PROJECT_ENGINEER', 50000, 300000, 'Project-specific engineering decisions'),
('PROJECT_MANAGER', 100000, 750000, 'Full project authority within budget'),

-- Strategic Level
('EQUIPMENT_MANAGER', 150000, 1000000, 'Equipment procurement and maintenance'),
('TECHNICAL_DIRECTOR', 250000, 2000000, 'Technical and engineering oversight'),
('OPERATIONS_MANAGER', 300000, 2500000, 'Operational and strategic decisions'),

-- Executive Level
('GENERAL_MANAGER', 500000, 5000000, 'Business unit management'),
('CFO', 1000000, 10000000, 'Financial and strategic oversight'),
('CEO', 2500000, 25000000, 'Executive authority'),
('BOARD_APPROVAL', 999999999, 999999999, 'Board-level capital decisions');

-- Display the role limits
SELECT * FROM approval_role_limits ORDER BY max_single_approval;

-- INDUSTRY BENCHMARKS
SELECT 'CONSTRUCTION INDUSTRY BENCHMARKS:' as info;

SELECT 
  'Small Construction Company (<$50M revenue)' as company_size,
  '$5K / $25K / $100K / $500K' as approval_thresholds,
  '3-Level Approval (Supervisor → Manager → Director)' as structure;

SELECT 
  'Medium Construction Company ($50M-$500M revenue)' as company_size,
  '$10K / $50K / $250K / $1M' as approval_thresholds,
  '4-Level Approval (Site → Project → Operations → Executive)' as structure;

SELECT 
  'Large Construction Company (>$500M revenue)' as company_size,
  '$25K / $100K / $500K / $2.5M' as approval_thresholds,
  '5-Level Approval (Site → Project → Regional → Corporate → Board)' as structure;

COMMENT ON TABLE approval_role_limits IS 'Maximum approval limits by role to prevent unauthorized spending';
COMMENT ON TABLE approval_workflows IS 'Industry-standard approval workflows for construction companies';