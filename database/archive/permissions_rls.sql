-- =====================================================
-- ROLE-BASED PERMISSION SYSTEM FOR CONSTRUCTION MANAGEMENT
-- =====================================================

-- Create role_permissions table
CREATE TABLE IF NOT EXISTS role_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name TEXT NOT NULL,
    module_name TEXT NOT NULL,
    permission_name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(role_name, module_name, permission_name)
);

-- Insert permission matrix
INSERT INTO role_permissions (role_name, module_name, permission_name) VALUES
-- Admin permissions (full access)
('Admin', 'projects', 'create'), ('Admin', 'projects', 'edit'), ('Admin', 'projects', 'delete'), ('Admin', 'projects', 'view'), ('Admin', 'projects', 'approve'),
('Admin', 'wbs', 'create'), ('Admin', 'wbs', 'edit'), ('Admin', 'wbs', 'delete'), ('Admin', 'wbs', 'view'),
('Admin', 'boq', 'create'), ('Admin', 'boq', 'edit'), ('Admin', 'boq', 'delete'), ('Admin', 'boq', 'view'),
('Admin', 'tasks', 'create'), ('Admin', 'tasks', 'edit'), ('Admin', 'tasks', 'delete'), ('Admin', 'tasks', 'view'),
('Admin', 'timesheets', 'create'), ('Admin', 'timesheets', 'edit'), ('Admin', 'timesheets', 'delete'), ('Admin', 'timesheets', 'view'), ('Admin', 'timesheets', 'approve'),
('Admin', 'procurement', 'create'), ('Admin', 'procurement', 'edit'), ('Admin', 'procurement', 'delete'), ('Admin', 'procurement', 'view'), ('Admin', 'procurement', 'approve'),
('Admin', 'purchase_orders', 'create'), ('Admin', 'purchase_orders', 'edit'), ('Admin', 'purchase_orders', 'delete'), ('Admin', 'purchase_orders', 'view'), ('Admin', 'purchase_orders', 'approve'),
('Admin', 'goods_receipts', 'create'), ('Admin', 'goods_receipts', 'edit'), ('Admin', 'goods_receipts', 'delete'), ('Admin', 'goods_receipts', 'view'),
('Admin', 'stores', 'create'), ('Admin', 'stores', 'edit'), ('Admin', 'stores', 'delete'), ('Admin', 'stores', 'view'),
('Admin', 'vendors', 'create'), ('Admin', 'vendors', 'edit'), ('Admin', 'vendors', 'delete'), ('Admin', 'vendors', 'view'),
('Admin', 'employees', 'create'), ('Admin', 'employees', 'edit'), ('Admin', 'employees', 'delete'), ('Admin', 'employees', 'view'),

-- Manager permissions
('Manager', 'projects', 'create'), ('Manager', 'projects', 'edit'), ('Manager', 'projects', 'view'),
('Manager', 'wbs', 'create'), ('Manager', 'wbs', 'edit'), ('Manager', 'wbs', 'view'),
('Manager', 'boq', 'create'), ('Manager', 'boq', 'edit'), ('Manager', 'boq', 'view'),
('Manager', 'tasks', 'create'), ('Manager', 'tasks', 'edit'), ('Manager', 'tasks', 'view'),
('Manager', 'timesheets', 'view'), ('Manager', 'timesheets', 'approve'),
('Manager', 'procurement', 'view'), ('Manager', 'procurement', 'approve'),
('Manager', 'purchase_orders', 'view'), ('Manager', 'purchase_orders', 'approve'),

-- Procurement permissions
('Procurement', 'projects', 'view'),
('Procurement', 'boq', 'view'),
('Procurement', 'procurement', 'create'), ('Procurement', 'procurement', 'edit'), ('Procurement', 'procurement', 'view'), ('Procurement', 'procurement', 'submit'),
('Procurement', 'purchase_orders', 'create'), ('Procurement', 'purchase_orders', 'edit'), ('Procurement', 'purchase_orders', 'view'), ('Procurement', 'purchase_orders', 'submit'),
('Procurement', 'vendors', 'create'), ('Procurement', 'vendors', 'edit'), ('Procurement', 'vendors', 'view'),
('Procurement', 'stores', 'view'),

-- Storekeeper permissions
('Storekeeper', 'projects', 'view'),
('Storekeeper', 'purchase_orders', 'view'),
('Storekeeper', 'goods_receipts', 'create'), ('Storekeeper', 'goods_receipts', 'edit'), ('Storekeeper', 'goods_receipts', 'view'),
('Storekeeper', 'stores', 'create'), ('Storekeeper', 'stores', 'edit'), ('Storekeeper', 'stores', 'view'),
('Storekeeper', 'vendors', 'view'),

-- Engineer permissions
('Engineer', 'projects', 'view'),
('Engineer', 'wbs', 'view'),
('Engineer', 'boq', 'view'),
('Engineer', 'tasks', 'edit'), ('Engineer', 'tasks', 'view'),
('Engineer', 'procurement', 'create'), ('Engineer', 'procurement', 'view'),
('Engineer', 'stores', 'view'),

-- Finance permissions
('Finance', 'projects', 'view'),
('Finance', 'boq', 'view'),
('Finance', 'purchase_orders', 'view'), ('Finance', 'purchase_orders', 'approve'),

-- HR permissions
('HR', 'projects', 'view'),
('HR', 'timesheets', 'view'), ('HR', 'timesheets', 'approve'),
('HR', 'employees', 'create'), ('HR', 'employees', 'edit'), ('HR', 'employees', 'view'),

-- Employee permissions
('Employee', 'projects', 'view'),
('Employee', 'tasks', 'view'),
('Employee', 'timesheets', 'create'), ('Employee', 'timesheets', 'edit'), ('Employee', 'timesheets', 'view'), ('Employee', 'timesheets', 'submit')

ON CONFLICT (role_name, module_name, permission_name) DO NOTHING;

-- Helper function to get user role
CREATE OR REPLACE FUNCTION get_user_role(user_id UUID)
RETURNS TEXT AS $$
BEGIN
    RETURN (
        SELECT r.name 
        FROM users u 
        JOIN roles r ON u.role_id = r.id 
        WHERE u.id = user_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to check permissions
CREATE OR REPLACE FUNCTION has_permission(user_role TEXT, module_name TEXT, permission_name TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM role_permissions 
        WHERE role_name = user_role 
        AND module_name = module_name 
        AND permission_name = permission_name
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create audit log table
CREATE TABLE IF NOT EXISTS permission_audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    action TEXT NOT NULL,
    module_name TEXT NOT NULL,
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit trigger function
CREATE OR REPLACE FUNCTION audit_permission_changes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO permission_audit_log (user_id, action, module_name, record_id, old_values, new_values)
    VALUES (
        auth.uid(),
        TG_OP,
        TG_TABLE_NAME,
        COALESCE(NEW.id, OLD.id),
        CASE WHEN TG_OP = 'DELETE' THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END
    );
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE wbs_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE boq_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE timesheets ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE goods_receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;

-- Projects policies
CREATE POLICY "projects_select" ON projects FOR SELECT
USING (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'projects', 'view')
);

CREATE POLICY "projects_insert" ON projects FOR INSERT
WITH CHECK (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'projects', 'create')
);

CREATE POLICY "projects_update" ON projects FOR UPDATE
USING (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'projects', 'edit')
);

CREATE POLICY "projects_delete" ON projects FOR DELETE
USING (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'projects', 'delete')
);

-- Timesheets policies (special rules for own records)
CREATE POLICY "timesheets_select" ON timesheets FOR SELECT
USING (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'timesheets', 'view') OR
    user_id = auth.uid()
);

CREATE POLICY "timesheets_insert" ON timesheets FOR INSERT
WITH CHECK (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'timesheets', 'create') OR
    (user_id = auth.uid() AND has_permission(get_user_role(auth.uid()), 'timesheets', 'create'))
);

CREATE POLICY "timesheets_update" ON timesheets FOR UPDATE
USING (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'timesheets', 'approve') OR
    (user_id = auth.uid() AND status = 'draft' AND has_permission(get_user_role(auth.uid()), 'timesheets', 'edit'))
);

-- Purchase Orders policies
CREATE POLICY "purchase_orders_select" ON purchase_orders FOR SELECT
USING (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'purchase_orders', 'view')
);

CREATE POLICY "purchase_orders_insert" ON purchase_orders FOR INSERT
WITH CHECK (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'purchase_orders', 'create')
);

CREATE POLICY "purchase_orders_update" ON purchase_orders FOR UPDATE
USING (
    get_user_role(auth.uid()) = 'Admin' OR
    (status IN ('submitted', 'pending_approval') AND has_permission(get_user_role(auth.uid()), 'purchase_orders', 'approve')) OR
    (status = 'draft' AND has_permission(get_user_role(auth.uid()), 'purchase_orders', 'edit'))
);

-- Goods Receipts policies
CREATE POLICY "goods_receipts_select" ON goods_receipts FOR SELECT
USING (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'goods_receipts', 'view')
);

CREATE POLICY "goods_receipts_insert" ON goods_receipts FOR INSERT
WITH CHECK (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'goods_receipts', 'create')
);

CREATE POLICY "goods_receipts_update" ON goods_receipts FOR UPDATE
USING (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'goods_receipts', 'edit')
);

-- Stock Movements policies
CREATE POLICY "stock_movements_select" ON stock_movements FOR SELECT
USING (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'stores', 'view')
);

CREATE POLICY "stock_movements_insert" ON stock_movements FOR INSERT
WITH CHECK (
    get_user_role(auth.uid()) = 'Admin' OR
    has_permission(get_user_role(auth.uid()), 'stores', 'create')
);

-- Add audit triggers to key tables
CREATE TRIGGER projects_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON projects
    FOR EACH ROW EXECUTE FUNCTION audit_permission_changes();

CREATE TRIGGER timesheets_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON timesheets
    FOR EACH ROW EXECUTE FUNCTION audit_permission_changes();

CREATE TRIGGER purchase_orders_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON purchase_orders
    FOR EACH ROW EXECUTE FUNCTION audit_permission_changes();