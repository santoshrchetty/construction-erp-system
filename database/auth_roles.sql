-- Authentication and Roles System
-- =====================================================

-- Roles table
CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permissions JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role_id UUID REFERENCES roles(id),
    employee_code VARCHAR(20) UNIQUE,
    department VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default roles
INSERT INTO roles (name, description, permissions) VALUES
('Admin', 'System Administrator', '{"all": true}'),
('Manager', 'Project Manager', '{"projects": ["read", "write"], "reports": ["read"], "users": ["read"]}'),
('Procurement', 'Procurement Officer', '{"procurement": ["read", "write"], "vendors": ["read", "write"], "purchase_orders": ["read", "write"]}'),
('Storekeeper', 'Store Manager', '{"stores": ["read", "write"], "inventory": ["read", "write"], "goods_receipt": ["read", "write"]}'),
('Engineer', 'Site Engineer', '{"projects": ["read"], "tasks": ["read", "write"], "progress": ["read", "write"]}'),
('Finance', 'Finance Officer', '{"costing": ["read", "write"], "billing": ["read", "write"], "reports": ["read"]}'),
('HR', 'Human Resources', '{"employees": ["read", "write"], "timesheets": ["read"], "users": ["read", "write"]}'),
('Employee', 'General Employee', '{"timesheets": ["read", "write"], "tasks": ["read"]}')
ON CONFLICT (name) DO NOTHING;

-- RLS Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE wbs_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE cost_objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_timesheets ENABLE ROW LEVEL SECURITY;

-- Helper function to get user role
CREATE OR REPLACE FUNCTION get_user_role(user_id UUID)
RETURNS TEXT AS $$
DECLARE
    role_name TEXT;
BEGIN
    SELECT r.name INTO role_name
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE u.id = user_id;
    
    RETURN COALESCE(role_name, 'Employee');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to check permissions
CREATE OR REPLACE FUNCTION has_permission(user_id UUID, resource TEXT, action TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    user_permissions JSONB;
    role_name TEXT;
BEGIN
    SELECT r.permissions, r.name INTO user_permissions, role_name
    FROM users u
    JOIN roles r ON u.role_id = r.id
    WHERE u.id = user_id;
    
    -- Admin has all permissions
    IF role_name = 'Admin' OR user_permissions ? 'all' THEN
        RETURN true;
    END IF;
    
    -- Check specific resource permissions
    RETURN user_permissions -> resource ? action;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Users policies
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Admins and HR can view all users" ON users
    FOR SELECT USING (
        get_user_role(auth.uid()) IN ('Admin', 'HR')
    );

CREATE POLICY "Admins and HR can update users" ON users
    FOR UPDATE USING (
        get_user_role(auth.uid()) IN ('Admin', 'HR')
    );

-- Projects policies
CREATE POLICY "All authenticated users can view projects" ON projects
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Managers and Admins can manage projects" ON projects
    FOR ALL USING (
        get_user_role(auth.uid()) IN ('Admin', 'Manager')
    );

-- Tasks policies
CREATE POLICY "All authenticated users can view tasks" ON tasks
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Engineers, Managers, and Admins can update tasks" ON tasks
    FOR UPDATE USING (
        get_user_role(auth.uid()) IN ('Admin', 'Manager', 'Engineer')
    );

-- Purchase Orders policies
CREATE POLICY "Procurement and Admins can manage purchase orders" ON purchase_orders
    FOR ALL USING (
        get_user_role(auth.uid()) IN ('Admin', 'Procurement', 'Manager')
    );

CREATE POLICY "Others can view purchase orders" ON purchase_orders
    FOR SELECT USING (auth.role() = 'authenticated');

-- Stores policies
CREATE POLICY "Storekeepers and Admins can manage stores" ON stores
    FOR ALL USING (
        get_user_role(auth.uid()) IN ('Admin', 'Storekeeper')
    );

CREATE POLICY "Others can view stores" ON stores
    FOR SELECT USING (auth.role() = 'authenticated');

-- Timesheets policies
CREATE POLICY "Users can manage their own timesheets" ON daily_timesheets
    FOR ALL USING (
        auth.uid() = employee_id OR 
        get_user_role(auth.uid()) IN ('Admin', 'Manager', 'HR')
    );

-- Cost objects policies
CREATE POLICY "Finance, Managers, and Admins can manage cost objects" ON cost_objects
    FOR ALL USING (
        get_user_role(auth.uid()) IN ('Admin', 'Manager', 'Finance')
    );

CREATE POLICY "Others can view cost objects" ON cost_objects
    FOR SELECT USING (auth.role() = 'authenticated');

-- Function to create user profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    default_role_id UUID;
BEGIN
    -- Get default Employee role
    SELECT id INTO default_role_id FROM roles WHERE name = 'Employee' LIMIT 1;
    
    INSERT INTO users (id, email, role_id)
    VALUES (NEW.id, NEW.email, default_role_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user profile on auth signup
CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();