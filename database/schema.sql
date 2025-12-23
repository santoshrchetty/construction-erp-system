-- Construction Management SaaS - Supabase Postgres Schema
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types/enums
CREATE TYPE project_status AS ENUM ('planning', 'active', 'on_hold', 'completed', 'cancelled');
CREATE TYPE project_type AS ENUM ('residential', 'commercial', 'infrastructure', 'industrial');
CREATE TYPE wbs_node_type AS ENUM ('project', 'phase', 'deliverable', 'work_package');
CREATE TYPE task_status AS ENUM ('not_started', 'in_progress', 'on_hold', 'completed', 'cancelled');
CREATE TYPE task_priority AS ENUM ('low', 'medium', 'high', 'critical');
CREATE TYPE dependency_type AS ENUM ('finish_to_start', 'start_to_start', 'finish_to_finish', 'start_to_finish');
CREATE TYPE timesheet_status AS ENUM ('draft', 'submitted', 'approved', 'rejected');
CREATE TYPE entry_type AS ENUM ('regular', 'overtime', 'holiday', 'sick_leave', 'vacation');
CREATE TYPE vendor_status AS ENUM ('active', 'inactive', 'blacklisted');
CREATE TYPE po_status AS ENUM ('draft', 'pending_approval', 'approved', 'sent', 'acknowledged', 'partially_received', 'fully_received', 'cancelled');
CREATE TYPE po_type AS ENUM ('standard', 'blanket', 'contract', 'emergency');
CREATE TYPE receipt_status AS ENUM ('pending', 'received', 'partially_received', 'rejected', 'returned');
CREATE TYPE quality_status AS ENUM ('pending', 'passed', 'failed', 'conditional');
CREATE TYPE movement_type AS ENUM ('receipt', 'issue', 'return', 'transfer', 'adjustment', 'write_off');
CREATE TYPE cost_type AS ENUM ('labor', 'material', 'equipment', 'subcontractor', 'overhead', 'other');
CREATE TYPE cost_status AS ENUM ('planned', 'committed', 'actual', 'accrued');

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Projects table
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    project_type project_type NOT NULL,
    status project_status NOT NULL DEFAULT 'planning',
    start_date DATE NOT NULL,
    planned_end_date DATE NOT NULL,
    actual_end_date DATE,
    budget DECIMAL(15,2) NOT NULL,
    client_id UUID,
    project_manager_id UUID,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Work Breakdown Structure
CREATE TABLE wbs_nodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES wbs_nodes(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    node_type wbs_node_type NOT NULL,
    level INTEGER NOT NULL,
    sequence_order INTEGER NOT NULL,
    budget_allocation DECIMAL(15,2) DEFAULT 0,
    planned_hours DECIMAL(10,2) DEFAULT 0,
    responsible_user_id UUID,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, code)
);

-- Activities (Schedulable units with dependencies - Primavera model)
CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    wbs_node_id UUID NOT NULL REFERENCES wbs_nodes(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    activity_type VARCHAR(20) DEFAULT 'INTERNAL',
    priority VARCHAR(20) DEFAULT 'medium',
    status VARCHAR(20) DEFAULT 'not_started',
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    duration_days INTEGER DEFAULT 1,
    actual_duration_days INTEGER DEFAULT 0,
    planned_hours DECIMAL(10,2) DEFAULT 0,
    budget_amount DECIMAL(15,2) DEFAULT 0,
    progress_percentage DECIMAL(5,2) DEFAULT 0,
    predecessor_activities UUID[] DEFAULT '{}',
    dependency_type dependency_type DEFAULT 'finish_to_start',
    lag_days INTEGER DEFAULT 0,
    requires_po BOOLEAN DEFAULT false,
    rate DECIMAL(15,2) DEFAULT 0,
    quantity DECIMAL(15,4) DEFAULT 0,
    direct_labor_cost DECIMAL(15,2) DEFAULT 0,
    direct_material_cost DECIMAL(15,2) DEFAULT 0,
    direct_equipment_cost DECIMAL(15,2) DEFAULT 0,
    direct_subcontract_cost DECIMAL(15,2) DEFAULT 0,
    direct_expense_cost DECIMAL(15,2) DEFAULT 0,
    vendor_id UUID REFERENCES vendors(id),
    responsible_user_id UUID,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, code)
);

-- Tasks (Progress tracking items only - no scheduling)
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    wbs_node_id UUID REFERENCES wbs_nodes(id) ON DELETE SET NULL,
    activity_id UUID REFERENCES activities(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status task_status NOT NULL DEFAULT 'not_started',
    priority task_priority NOT NULL DEFAULT 'medium',
    progress_percentage DECIMAL(5,2) DEFAULT 0,
    checklist_item BOOLEAN DEFAULT false,
    daily_logs TEXT DEFAULT '',
    qa_notes TEXT DEFAULT '',
    safety_notes TEXT DEFAULT '',
    assigned_to UUID,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity Dependencies (Activities handle scheduling and dependencies)
CREATE TABLE activity_dependencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    predecessor_activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    successor_activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    dependency_type dependency_type NOT NULL DEFAULT 'finish_to_start',
    lag_days INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(predecessor_activity_id, successor_activity_id)
);

-- Cost Objects (central cost tracking)
CREATE TABLE cost_objects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    wbs_node_id UUID REFERENCES wbs_nodes(id) ON DELETE SET NULL,
    activity_id UUID REFERENCES activities(id) ON DELETE SET NULL,
    task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    cost_type cost_type NOT NULL,
    budget_amount DECIMAL(15,2) DEFAULT 0,
    actual_amount DECIMAL(15,2) DEFAULT 0,
    committed_amount DECIMAL(15,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, code)
);

-- =====================================================
-- BOQ TABLES
-- =====================================================

-- BOQ Categories
CREATE TABLE boq_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    description TEXT,
    parent_category_id UUID REFERENCES boq_categories(id),
    sequence_order INTEGER DEFAULT 0,
    UNIQUE(project_id, code)
);

-- BOQ Items
CREATE TABLE boq_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    wbs_node_id UUID REFERENCES wbs_nodes(id) ON DELETE SET NULL,
    category_id UUID NOT NULL REFERENCES boq_categories(id),
    item_code VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    specification TEXT,
    unit VARCHAR(20) NOT NULL,
    quantity DECIMAL(15,4) NOT NULL,
    rate DECIMAL(15,2) NOT NULL,
    amount DECIMAL(15,2) GENERATED ALWAYS AS (quantity * rate) STORED,
    is_provisional BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, item_code)
);

-- =====================================================
-- TIMESHEET TABLES
-- =====================================================

-- Timesheets
CREATE TABLE timesheets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    week_ending_date DATE NOT NULL,
    status timesheet_status NOT NULL DEFAULT 'draft',
    total_hours DECIMAL(8,2) DEFAULT 0,
    total_overtime_hours DECIMAL(8,2) DEFAULT 0,
    submitted_date TIMESTAMP WITH TIME ZONE,
    approved_by UUID,
    approved_date TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, project_id, week_ending_date)
);

-- Timesheet Entries
CREATE TABLE timesheet_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timesheet_id UUID NOT NULL REFERENCES timesheets(id) ON DELETE CASCADE,
    task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
    activity_id UUID REFERENCES activities(id) ON DELETE SET NULL,
    cost_object_id UUID REFERENCES cost_objects(id) ON DELETE SET NULL,
    entry_date DATE NOT NULL,
    entry_type entry_type NOT NULL DEFAULT 'regular',
    hours DECIMAL(8,2) NOT NULL,
    description TEXT,
    billable BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- VENDOR & PROCUREMENT TABLES
-- =====================================================

-- Vendors
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    tax_id VARCHAR(50),
    status vendor_status NOT NULL DEFAULT 'active',
    credit_limit DECIMAL(15,2) DEFAULT 0,
    payment_terms VARCHAR(100),
    specializations TEXT[], -- Array of specializations
    rating DECIMAL(3,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subcontractors (extends vendors)
CREATE TABLE subcontractors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    license_number VARCHAR(100),
    license_expiry DATE,
    insurance_policy VARCHAR(100),
    insurance_expiry DATE,
    safety_rating DECIMAL(3,2),
    performance_bond_required BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Purchase Orders
CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    po_number VARCHAR(50) UNIQUE NOT NULL,
    vendor_id UUID NOT NULL REFERENCES vendors(id),
    po_type po_type NOT NULL DEFAULT 'standard',
    status po_status NOT NULL DEFAULT 'draft',
    issue_date DATE NOT NULL,
    delivery_date DATE NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    grand_total DECIMAL(15,2) GENERATED ALWAYS AS (total_amount + tax_amount) STORED,
    payment_terms VARCHAR(100),
    delivery_terms TEXT,
    created_by UUID NOT NULL,
    approved_by UUID,
    approved_date TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Purchase Order Lines
CREATE TABLE po_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    boq_item_id UUID REFERENCES boq_items(id),
    description TEXT NOT NULL,
    specification TEXT,
    quantity DECIMAL(15,4) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    unit_rate DECIMAL(15,2) NOT NULL,
    line_total DECIMAL(15,2) GENERATED ALWAYS AS (quantity * unit_rate) STORED,
    received_quantity DECIMAL(15,4) DEFAULT 0,
    pending_quantity DECIMAL(15,4) GENERATED ALWAYS AS (quantity - received_quantity) STORED,
    delivery_date DATE,
    UNIQUE(po_id, line_number)
);

-- =====================================================
-- GOODS RECEIPT & INVENTORY TABLES
-- =====================================================

-- Stores/Warehouses
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    location TEXT,
    store_keeper_id UUID,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, code)
);

-- Goods Receipt Notes (GRN)
CREATE TABLE goods_receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    po_id UUID NOT NULL REFERENCES purchase_orders(id),
    store_id UUID NOT NULL REFERENCES stores(id),
    grn_number VARCHAR(50) UNIQUE NOT NULL,
    vendor_id UUID NOT NULL REFERENCES vendors(id),
    receipt_date DATE NOT NULL,
    received_by UUID NOT NULL,
    status receipt_status NOT NULL DEFAULT 'pending',
    delivery_note_number VARCHAR(100),
    vehicle_number VARCHAR(50),
    driver_name VARCHAR(255),
    total_received_value DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Goods Receipt Lines
CREATE TABLE grn_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    grn_id UUID NOT NULL REFERENCES goods_receipts(id) ON DELETE CASCADE,
    po_line_id UUID NOT NULL REFERENCES po_lines(id),
    ordered_quantity DECIMAL(15,4) NOT NULL,
    received_quantity DECIMAL(15,4) NOT NULL,
    accepted_quantity DECIMAL(15,4) NOT NULL,
    rejected_quantity DECIMAL(15,4) DEFAULT 0,
    unit_rate DECIMAL(15,2) NOT NULL,
    line_value DECIMAL(15,2) GENERATED ALWAYS AS (accepted_quantity * unit_rate) STORED,
    quality_status quality_status NOT NULL DEFAULT 'pending',
    batch_number VARCHAR(100),
    expiry_date DATE,
    notes TEXT
);

-- Stock Items Master
CREATE TABLE stock_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100),
    unit VARCHAR(20) NOT NULL,
    reorder_level DECIMAL(15,4) DEFAULT 0,
    maximum_level DECIMAL(15,4) DEFAULT 0,
    minimum_level DECIMAL(15,4) DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Stock Balances
CREATE TABLE stock_balances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id),
    stock_item_id UUID NOT NULL REFERENCES stock_items(id),
    current_quantity DECIMAL(15,4) DEFAULT 0,
    reserved_quantity DECIMAL(15,4) DEFAULT 0,
    available_quantity DECIMAL(15,4) GENERATED ALWAYS AS (current_quantity - reserved_quantity) STORED,
    average_cost DECIMAL(15,2) DEFAULT 0,
    total_value DECIMAL(15,2) GENERATED ALWAYS AS (current_quantity * average_cost) STORED,
    last_movement_date TIMESTAMP WITH TIME ZONE,
    UNIQUE(store_id, stock_item_id)
);

-- Stock Movements
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id),
    stock_item_id UUID NOT NULL REFERENCES stock_items(id),
    movement_type movement_type NOT NULL,
    reference_number VARCHAR(100) NOT NULL,
    reference_type VARCHAR(50) NOT NULL, -- 'GRN', 'ISSUE', 'TRANSFER', etc.
    reference_id UUID, -- Points to GRN, Issue, etc.
    quantity DECIMAL(15,4) NOT NULL,
    unit_cost DECIMAL(15,2) NOT NULL,
    total_cost DECIMAL(15,2) GENERATED ALWAYS AS (quantity * unit_cost) STORED,
    movement_date DATE NOT NULL,
    created_by UUID NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- COSTING TABLES
-- =====================================================

-- Actual Costs
CREATE TABLE actual_costs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    cost_object_id UUID NOT NULL REFERENCES cost_objects(id),
    wbs_node_id UUID REFERENCES wbs_nodes(id),
    activity_id UUID REFERENCES activities(id),
    task_id UUID REFERENCES tasks(id),
    cost_type cost_type NOT NULL,
    cost_status cost_status NOT NULL DEFAULT 'actual',
    amount DECIMAL(15,2) NOT NULL,
    cost_date DATE NOT NULL,
    reference_number VARCHAR(100),
    reference_type VARCHAR(50), -- 'TIMESHEET', 'PO', 'INVOICE', 'GRN'
    reference_id UUID,
    description TEXT,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Primary relationship indexes
CREATE INDEX idx_wbs_nodes_project_id ON wbs_nodes(project_id);
CREATE INDEX idx_wbs_nodes_parent_id ON wbs_nodes(parent_id);
CREATE INDEX idx_activities_project_id ON activities(project_id);
CREATE INDEX idx_activities_wbs_node_id ON activities(wbs_node_id);
CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_activity_id ON tasks(activity_id);
CREATE INDEX idx_activity_dependencies_predecessor ON activity_dependencies(predecessor_activity_id);
CREATE INDEX idx_activity_dependencies_successor ON activity_dependencies(successor_activity_id);
CREATE INDEX idx_cost_objects_project_id ON cost_objects(project_id);

-- BOQ indexes
CREATE INDEX idx_boq_items_project_id ON boq_items(project_id);
CREATE INDEX idx_boq_items_wbs_node_id ON boq_items(wbs_node_id);

-- Timesheet indexes
CREATE INDEX idx_timesheets_user_project ON timesheets(user_id, project_id);
CREATE INDEX idx_timesheet_entries_task_id ON timesheet_entries(task_id);
CREATE INDEX idx_timesheet_entries_cost_object_id ON timesheet_entries(cost_object_id);

-- Procurement indexes
CREATE INDEX idx_purchase_orders_project_id ON purchase_orders(project_id);
CREATE INDEX idx_purchase_orders_vendor_id ON purchase_orders(vendor_id);
CREATE INDEX idx_po_lines_po_id ON po_lines(po_id);

-- Inventory indexes
CREATE INDEX idx_goods_receipts_project_id ON goods_receipts(project_id);
CREATE INDEX idx_goods_receipts_po_id ON goods_receipts(po_id);
CREATE INDEX idx_stock_movements_store_item ON stock_movements(store_id, stock_item_id);
CREATE INDEX idx_stock_movements_date ON stock_movements(movement_date);

-- Costing indexes
CREATE INDEX idx_actual_costs_project_id ON actual_costs(project_id);
CREATE INDEX idx_actual_costs_cost_object_id ON actual_costs(cost_object_id);
CREATE INDEX idx_actual_costs_date ON actual_costs(cost_date);

-- =====================================================
-- TRIGGERS FOR AUTOMATIC UPDATES
-- =====================================================

-- Update timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply to relevant tables
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_wbs_nodes_updated_at BEFORE UPDATE ON wbs_nodes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_activities_updated_at BEFORE UPDATE ON activities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update PO line received quantities when GRN is created
CREATE OR REPLACE FUNCTION update_po_received_quantity()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE po_lines 
    SET received_quantity = received_quantity + NEW.accepted_quantity
    WHERE id = NEW.po_line_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_po_received_qty AFTER INSERT ON grn_lines FOR EACH ROW EXECUTE FUNCTION update_po_received_quantity();

-- Update stock balances on movements
CREATE OR REPLACE FUNCTION update_stock_balance()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO stock_balances (store_id, stock_item_id, current_quantity, average_cost, last_movement_date)
    VALUES (NEW.store_id, NEW.stock_item_id, 
            CASE WHEN NEW.movement_type IN ('receipt', 'return') THEN NEW.quantity ELSE -NEW.quantity END,
            NEW.unit_cost, NEW.movement_date)
    ON CONFLICT (store_id, stock_item_id) 
    DO UPDATE SET 
        current_quantity = stock_balances.current_quantity + 
            CASE WHEN NEW.movement_type IN ('receipt', 'return') THEN NEW.quantity ELSE -NEW.quantity END,
        last_movement_date = NEW.movement_date;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_stock_balance_trigger AFTER INSERT ON stock_movements FOR EACH ROW EXECUTE FUNCTION update_stock_balance();