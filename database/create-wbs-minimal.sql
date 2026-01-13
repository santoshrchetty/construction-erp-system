-- CREATE WBS MANAGEMENT SCHEMA - MINIMAL VERSION
-- Check existing vendors table first

-- ========================================
-- 1. ADD MISSING COLUMNS TO VENDORS
-- ========================================

ALTER TABLE vendors ADD COLUMN IF NOT EXISTS code VARCHAR(50);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS name VARCHAR(255);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'active';

-- ========================================
-- 2. WBS NODES TABLE
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
-- 3. ACTIVITIES TABLE
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
-- 4. TASKS TABLE
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
-- 5. UPDATE TILE MAPPING
-- ========================================

UPDATE tiles 
SET construction_action = 'WBSBuilder'
WHERE title = 'WBS Management';

-- ========================================
-- 6. ADD SAMPLE VENDORS (SKIP IF FAILS)
-- ========================================

INSERT INTO vendors (code, name, status) 
SELECT 'V001', 'ABC Construction Ltd', 'active'
WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE code = 'V001');

INSERT INTO vendors (code, name, status) 
SELECT 'V002', 'XYZ Electrical Services', 'active'
WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE code = 'V002');

INSERT INTO vendors (code, name, status) 
SELECT 'V003', 'DEF Plumbing Co', 'active'
WHERE NOT EXISTS (SELECT 1 FROM vendors WHERE code = 'V003');

SELECT 'WBS SCHEMA CREATED' as status;