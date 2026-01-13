-- RBAC and Fiori-style Tiles for Construction Management
-- =====================================================

-- User Roles
CREATE TYPE user_role AS ENUM ('admin', 'project_manager', 'site_engineer', 'foreman', 'worker', 'procurement', 'finance');

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    role user_role NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tile definitions
CREATE TABLE tiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(100) NOT NULL,
    subtitle VARCHAR(200),
    icon VARCHAR(50) NOT NULL,
    color VARCHAR(20) DEFAULT 'blue',
    route VARCHAR(200) NOT NULL,
    roles user_role[] NOT NULL,
    sequence_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true
);

-- Insert Fiori-style tiles
INSERT INTO tiles (title, subtitle, icon, color, route, roles, sequence_order) VALUES
('Projects', 'Manage construction projects', 'building', 'blue', '/projects', '{admin,project_manager}', 1),
('Activities', 'Track project activities', 'tasks', 'green', '/activities', '{admin,project_manager,site_engineer}', 2),
('Purchase Orders', 'Procurement management', 'shopping-cart', 'orange', '/purchase-orders', '{admin,procurement}', 3),
('Timesheets', 'Time tracking', 'clock', 'purple', '/timesheets', '{admin,project_manager,site_engineer,foreman,worker}', 4),
('Inventory', 'Stock management', 'warehouse', 'teal', '/inventory', '{admin,procurement}', 5),
('Reports', 'Project analytics', 'chart-bar', 'red', '/reports', '{admin,project_manager,finance}', 6);

-- User project assignments
CREATE TABLE user_projects (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    role user_role NOT NULL,
    PRIMARY KEY (user_id, project_id)
);

-- Sample users
INSERT INTO users (email, name, role) VALUES
('admin@construction.com', 'System Admin', 'admin'),
('pm@construction.com', 'Project Manager', 'project_manager'),
('engineer@construction.com', 'Site Engineer', 'site_engineer');