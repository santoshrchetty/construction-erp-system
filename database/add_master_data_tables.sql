-- Add missing master data tables for agent resolution
-- These tables are needed by FlexibleApprovalService

-- 1. Organizational Hierarchy (For HIERARCHY rule)
CREATE TABLE IF NOT EXISTS org_hierarchy (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  employee_id UUID NOT NULL REFERENCES auth.users(id),
  employee_name VARCHAR(200) NOT NULL,
  position_title VARCHAR(200),
  manager_id UUID REFERENCES auth.users(id),
  department_code VARCHAR(50),
  plant_code VARCHAR(50),
  approval_limit DECIMAL(15,2),
  is_active BOOLEAN DEFAULT true,
  tenant_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Role Assignments (For ROLE rule)
CREATE TABLE IF NOT EXISTS role_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  role_code VARCHAR(50) NOT NULL,
  employee_id UUID NOT NULL REFERENCES auth.users(id),
  scope_type VARCHAR(50), -- 'PLANT', 'DEPARTMENT', 'GLOBAL'
  scope_value VARCHAR(50), -- Plant code, Department code, or NULL for global
  is_active BOOLEAN DEFAULT true,
  tenant_id UUID NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_org_hierarchy_manager ON org_hierarchy(manager_id);
CREATE INDEX IF NOT EXISTS idx_org_hierarchy_employee ON org_hierarchy(employee_id, is_active);
CREATE INDEX IF NOT EXISTS idx_role_assignments_employee ON role_assignments(employee_id, is_active);
CREATE INDEX IF NOT EXISTS idx_role_assignments_role ON role_assignments(role_code, is_active);

-- Verify all 8 workflow tables exist
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size('public.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'agent_rules',
    'step_agents',
    'step_instances',
    'workflow_definitions',
    'workflow_instances',
    'workflow_steps',
    'org_hierarchy',
    'role_assignments'
  )
ORDER BY tablename;

-- Expected: 8 tables total
