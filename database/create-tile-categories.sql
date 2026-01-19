-- Create tile_categories table for category ordering
CREATE TABLE IF NOT EXISTS tile_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_name VARCHAR(100) UNIQUE NOT NULL,
  category_order INTEGER NOT NULL,
  icon VARCHAR(50),
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert categories in functional sequence
INSERT INTO tile_categories (category_name, category_order, icon, description) VALUES
('Configuration', 1, '🔧', 'System configuration and organizational setup'),
('Administration', 2, '⚙️', 'User, role, and authorization management'),
('Finance', 3, '💰', 'Financial accounting and controlling'),
('Materials', 4, '📦', 'Material master data management'),
('Procurement', 5, '🛒', 'Purchase requisitions and orders'),
('Warehouse', 6, '🏪', 'Inventory and warehouse operations'),
('Project Management', 7, '📋', 'Project planning and execution'),
('Quality', 8, '✅', 'Quality control and inspections'),
('Safety', 9, '🛡️', 'Safety management and compliance'),
('Human Resources', 10, '👥', 'Employee and HR management'),
('Reporting', 11, '📊', 'Reports and analytics')
ON CONFLICT (category_name) DO UPDATE SET
  category_order = EXCLUDED.category_order,
  icon = EXCLUDED.icon,
  description = EXCLUDED.description;

-- Verify
SELECT * FROM tile_categories ORDER BY category_order;
