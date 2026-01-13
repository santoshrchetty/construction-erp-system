-- Create tiles table for proper Layer 4 implementation
CREATE TABLE IF NOT EXISTS tiles (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  subtitle TEXT,
  icon VARCHAR(100),
  module_code VARCHAR(20),
  construction_action VARCHAR(100),
  route VARCHAR(255),
  tile_category VARCHAR(100),
  auth_object VARCHAR(100),
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert existing tiles data
INSERT INTO tiles (id, title, subtitle, icon, module_code, construction_action, route, tile_category, auth_object, sort_order) VALUES
(1, 'GL Account Posting', 'Post journal entries to general ledger', 'dollar-sign', 'FI', 'gl_posting', '/finance/gl-posting', 'Finance', 'FI_GL_POST', 1),
(2, 'Trial Balance', 'Generate trial balance report', 'bar-chart-3', 'FI', 'trial_balance', '/finance/trial-balance', 'Finance', 'FI_GL_DISP', 2),
(3, 'Chart of Accounts', 'Manage chart of accounts', 'file-text', 'FI', 'chart_of_accounts', '/finance/chart-accounts', 'Finance', 'FI_COA_DISP', 3),
(16, 'Inventory Stock Levels', 'View current material stock levels and status', 'package', 'MM', 'stock-overview', '/materials/stock', 'Materials', 'MM_STK_OVERVIEW', 16),
(17, 'Create Material Master', 'Create new material master records', 'plus-circle', 'MM', 'create-material', '/materials/create', 'Materials', 'MM_MAT_CREATE', 17),
(19, 'Display Material Master', 'View material master data', 'eye', 'MM', 'material-master', '/materials/display', 'Materials', 'MM_MAT_DISPLAY', 19),
(50, 'Projects Dashboard', 'Manage construction projects', 'building', 'PS', 'project-overview', '/projects/dashboard', 'Project Management', 'PS_PRJ_REVIEW', 50),
(53, 'Activities', 'Manage project activities', 'list', 'PS', 'activities', '/projects/activities', 'Project Management', 'PS_ACT_EXECUTE', 53),
(54, 'Tasks', 'Manage project tasks', 'check-square', 'PS', 'tasks', '/projects/tasks', 'Project Management', 'PS_TSK_MANAGE', 54);

-- Add RLS policy
ALTER TABLE tiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "tiles_select_policy" ON tiles
  FOR SELECT USING (is_active = true);