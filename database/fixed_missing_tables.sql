-- Fixed Missing Tables Setup
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. ROLES
CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permissions JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. USERS (Required by the app)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    role_id UUID REFERENCES roles(id),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. EMPLOYEES
CREATE TABLE IF NOT EXISTS employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(20),
    job_title VARCHAR(100),
    department VARCHAR(100),
    hire_date DATE NOT NULL,
    employment_type VARCHAR(20) DEFAULT 'permanent',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. DAILY TIMESHEETS
CREATE TABLE IF NOT EXISTS daily_timesheets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timesheet_date DATE NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    task_id UUID REFERENCES tasks(id),
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    vendor_id UUID REFERENCES vendors(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'draft',
    total_regular_hours DECIMAL(8,2) DEFAULT 0,
    total_overtime_hours DECIMAL(8,2) DEFAULT 0,
    total_cost DECIMAL(15,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT check_worker_type CHECK (
        (employee_id IS NOT NULL AND vendor_id IS NULL) OR 
        (employee_id IS NULL AND vendor_id IS NOT NULL)
    )
);

-- 5. PROJECT BILLING
CREATE TABLE IF NOT EXISTS project_billing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    billing_date DATE NOT NULL,
    billing_amount DECIMAL(15,2) NOT NULL,
    billing_type VARCHAR(20) DEFAULT 'progress',
    description TEXT,
    invoice_number VARCHAR(50),
    status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- INDEXES
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);
CREATE INDEX IF NOT EXISTS idx_daily_timesheets_project_date ON daily_timesheets(project_id, timesheet_date);
CREATE INDEX IF NOT EXISTS idx_daily_timesheets_employee ON daily_timesheets(employee_id);

-- DEFAULT ROLES
INSERT INTO roles (name, description, permissions) VALUES
('Admin', 'System Administrator', '{"all": true}'),
('Manager', 'Project Manager', '{"projects": ["read", "write"]}'),
('Engineer', 'Site Engineer', '{"tasks": ["read", "write"]}'),
('Employee', 'General Employee', '{"timesheets": ["read", "write"]}')
ON CONFLICT (name) DO NOTHING;

-- Sync existing auth users to users table
INSERT INTO users (id, email, role_id, created_at)
SELECT 
    au.id,
    au.email,
    (SELECT id FROM roles WHERE name = 'Employee' LIMIT 1) as role_id,
    au.created_at
FROM auth.users au
WHERE au.id NOT IN (SELECT id FROM users WHERE id IS NOT NULL)
ON CONFLICT (id) DO NOTHING;

-- Create trigger to auto-sync new auth users
CREATE OR REPLACE FUNCTION sync_auth_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, role_id, created_at)
    VALUES (
        NEW.id,
        NEW.email,
        (SELECT id FROM roles WHERE name = 'Employee' LIMIT 1),
        NEW.created_at
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER sync_auth_user_trigger
    AFTER INSERT OR UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION sync_auth_user();

SELECT 'Users synced successfully!' as status;