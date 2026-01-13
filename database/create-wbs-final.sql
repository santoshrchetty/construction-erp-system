-- CREATE WBS MANAGEMENT SCHEMA - FINAL VERSION
-- Works with existing vendors table structure

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
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
  planned_start_date DATE,
  duration_days INTEGER DEFAULT 1,
  progress_percentage INTEGER DEFAULT 0,
  budget_amount DECIMAL(15,2) DEFAULT 0,
  vendor_id UUID REFERENCES vendors(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
  status VARCHAR(20) NOT NULL DEFAULT 'not_started',
  priority VARCHAR(20) NOT NULL DEFAULT 'medium',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- 4. UPDATE TILE MAPPING
-- ========================================

UPDATE tiles 
SET construction_action = 'WBSBuilder'
WHERE title = 'WBS Management';

-- ========================================
-- 5. ADD SAMPLE VENDORS (using existing structure)
-- ========================================

INSERT INTO vendors (vendor_code, vendor_name, is_active) 
SELECT 'V001', 'ABC Construction Ltd', true
WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE vendor_code = 'V001');

INSERT INTO vendors (vendor_code, vendor_name, is_active) 
SELECT 'V002', 'XYZ Electrical Services', true
WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE vendor_code = 'V002');

INSERT INTO vendors (vendor_code, vendor_name, is_active) 
SELECT 'V003', 'DEF Plumbing Co', true
WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE vendor_code = 'V003');

SELECT 'WBS SCHEMA CREATED SUCCESSFULLY' as status;