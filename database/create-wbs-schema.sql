-- CREATE WBS MANAGEMENT SCHEMA
-- Complete database schema for WBS functionality

-- ========================================
-- 1. WBS NODES TABLE
-- ========================================

CREATE TABLE IF NOT EXISTS wbs_nodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  code VARCHAR(50) NOT NULL,
  name VARCHAR(255) NOT NULL,
  node_type VARCHAR(50) NOT NULL DEFAULT 'phase',
  level INTEGER NOT NULL DEFAULT 1,
  sequence_order INTEGER NOT NULL DEFAULT 1,
  parent_id UUID REFERENCES wbs_nodes(id) ON DELETE CASCADE,
  wbs_direct_cost_total DECIMAL(15,2) DEFAULT 0,
  wbs_indirect_cost_allocated DECIMAL(15,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(project_id, code)
);

-- ========================================
-- 2. ACTIVITIES TABLE
-- ========================================

CREATE TABLE IF NOT EXISTS activities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  wbs_node_id UUID NOT NULL REFERENCES wbs_nodes(id) ON DELETE CASCADE,
  code VARCHAR(50) NOT NULL,
  name VARCHAR(255) NOT NULL,
  activity_type VARCHAR(20) NOT NULL DEFAULT 'INTERNAL',
  status VARCHAR(20) NOT NULL DEFAULT 'not_started',
  priority VARCHAR(20) NOT NULL DEFAULT 'medium',
  
  -- Schedule fields
  planned_start_date DATE,
  planned_end_date DATE,
  actual_start_date DATE,
  actual_end_date DATE,
  duration_days INTEGER DEFAULT 1,
  actual_duration_days INTEGER DEFAULT 0,
  progress_percentage INTEGER DEFAULT 0,
  
  -- Budget fields
  budget_amount DECIMAL(15,2) DEFAULT 0,
  
  -- Internal activity fields
  planned_hours DECIMAL(10,2) DEFAULT 0,
  cost_rate DECIMAL(10,2) DEFAULT 0,
  
  -- External activity fields
  vendor_id UUID REFERENCES suppliers(id),
  requires_po BOOLEAN DEFAULT false,
  rate DECIMAL(10,2) DEFAULT 0,
  quantity DECIMAL(10,2) DEFAULT 0,
  
  -- Cost breakdown
  direct_labor_cost DECIMAL(15,2) DEFAULT 0,
  direct_material_cost DECIMAL(15,2) DEFAULT 0,
  direct_equipment_cost DECIMAL(15,2) DEFAULT 0,
  direct_subcontract_cost DECIMAL(15,2) DEFAULT 0,
  direct_expense_cost DECIMAL(15,2) DEFAULT 0,
  
  -- Dependencies
  predecessor_activities UUID[],
  dependency_type VARCHAR(20) DEFAULT 'finish_to_start',
  lag_days INTEGER DEFAULT 0,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(project_id, code)
);

-- ========================================
-- 3. TASKS TABLE
-- ========================================

CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'not_started',
  priority VARCHAR(20) NOT NULL DEFAULT 'medium',
  checklist_item BOOLEAN DEFAULT false,
  assigned_to UUID,
  created_by UUID,
  daily_logs TEXT,
  qa_notes TEXT,
  safety_notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 4. VENDORS TABLE (if not exists)
-- ========================================

CREATE TABLE IF NOT EXISTS vendors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 5. CREATE INDEXES
-- ========================================

CREATE INDEX IF NOT EXISTS idx_wbs_nodes_project_id ON wbs_nodes(project_id);
CREATE INDEX IF NOT EXISTS idx_wbs_nodes_parent_id ON wbs_nodes(parent_id);
CREATE INDEX IF NOT EXISTS idx_activities_project_id ON activities(project_id);
CREATE INDEX IF NOT EXISTS idx_activities_wbs_node_id ON activities(wbs_node_id);
CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_activity_id ON tasks(activity_id);

-- ========================================
-- 6. UPDATE TILE MAPPING
-- ========================================

UPDATE tiles 
SET construction_action = 'WBSBuilder'
WHERE title = 'WBS Management';

-- ========================================
-- 7. INSERT SAMPLE VENDORS
-- ========================================

INSERT INTO vendors (code, name, status) VALUES
('V001', 'ABC Construction Ltd', 'active'),
('V002', 'XYZ Electrical Services', 'active'),
('V003', 'DEF Plumbing Co', 'active')
ON CONFLICT (code) DO NOTHING;

SELECT 'WBS SCHEMA CREATED SUCCESSFULLY' as status;