-- =====================================================
-- CONSTRUCTION MANAGEMENT SAAS - UNIFIED SCHEMA
-- Single Source of Truth for All Database Tables
-- =====================================================
-- Version: 1.0
-- Last Updated: 2024
-- Description: Complete database schema for construction management system
--              with SAP-style organizational structure and RBAC

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- ENUMS AND CUSTOM TYPES
-- =====================================================

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
CREATE TYPE user_role AS ENUM ('admin', 'manager', 'engineer', 'procurement', 'storekeeper', 'finance', 'hr', 'employee');

-- =====================================================
-- ORGANIZATIONAL STRUCTURE (SAP-STYLE)
-- =====================================================

-- Company Codes (Legal Entities)
CREATE TABLE company_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR(4) UNIQUE NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    legal_entity_name VARCHAR(255) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    country VARCHAR(2) DEFAULT 'US',
    address TEXT,
    tax_number VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Purchasing Organizations
CREATE TABLE purchasing_organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    porg_code VARCHAR(4) UNIQUE NOT NULL,
    porg_name VARCHAR(255) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Plants (Project Sites)
CREATE TABLE plants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    plant_code VARCHAR(4) UNIQUE NOT NULL,
    plant_name VARCHAR(255) NOT NULL,
    plant_type VARCHAR(20) DEFAULT 'PROJECT',
    address TEXT,
    project_id UUID,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Storage Locations
CREATE TABLE storage_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id UUID NOT NULL REFERENCES plants(id),
    sloc_code VARCHAR(4) NOT NULL,
    sloc_name VARCHAR(255) NOT NULL,
    location_type VARCHAR(20) DEFAULT 'WAREHOUSE',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(plant_id, sloc_code)
);

-- Cost Centers
CREATE TABLE cost_centers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    cost_center_code VARCHAR(10) UNIQUE NOT NULL,
    cost_center_name VARCHAR(255) NOT NULL,
    cost_center_category VARCHAR(20) DEFAULT 'PRODUCTION',
    responsible_person VARCHAR(255),
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- USER MANAGEMENT & SECURITY
-- =====================================================

-- Roles
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    role_id UUID REFERENCES roles(id),
    company_code_id UUID REFERENCES company_codes(id),
    is_active BOOLEAN DEFAULT true,
    has_authorization BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Roles (Many-to-Many)
CREATE TABLE user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    assigned_by UUID REFERENCES users(id),
    UNIQUE(user_id, role_id)
);

-- Authorization Objects (SAP-style)
CREATE TABLE authorization_objects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    object_name VARCHAR(10) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    module VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Authorization Fields
CREATE TABLE authorization_fields (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_object_id UUID NOT NULL REFERENCES authorization_objects(id) ON DELETE CASCADE,
    field_name VARCHAR(10) NOT NULL,
    field_description TEXT,
    field_values TEXT[] NOT NULL,
    is_required BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(auth_object_id, field_name)
);

-- Role Authorization Objects
CREATE TABLE role_authorization_objects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    auth_object_id UUID NOT NULL REFERENCES authorization_objects(id) ON DELETE CASCADE,
    field_values JSONB NOT NULL,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(role_id, auth_object_id)
);

-- Tiles
CREATE TABLE tiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(100) NOT NULL,
    subtitle VARCHAR(200),
    icon VARCHAR(50) NOT NULL,
    color VARCHAR(20) DEFAULT 'blue',
    route VARCHAR(200) NOT NULL,
    category VARCHAR(50) NOT NULL,
    roles TEXT[] NOT NULL,
    sequence_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- PROJECT MANAGEMENT
-- =====================================================

-- Projects
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
    project_manager_id UUID REFERENCES users(id),
    location TEXT,
    company_code_id UUID REFERENCES company_codes(id),
    purchasing_org_id UUID REFERENCES purchasing_organizations(id),
    plant_id UUID REFERENCES plants(id),
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
    responsible_user_id UUID REFERENCES users(id),
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, code)
);

-- Activities
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
    vendor_id UUID,
    responsible_user_id UUID REFERENCES users(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, code)
);

-- Tasks
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
    assigned_to UUID REFERENCES users(id),
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity Dependencies
CREATE TABLE activity_dependencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    predecessor_activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    successor_activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    dependency_type dependency_type NOT NULL DEFAULT 'finish_to_start',
    lag_days INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(predecessor_activity_id, successor_activity_id)
);

-- =====================================================
-- FINANCIAL MANAGEMENT
-- =====================================================

-- Chart of Accounts
CREATE TABLE chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR(4) NOT NULL,
    coa_code VARCHAR(10) NOT NULL,
    account_code VARCHAR(10) UNIQUE NOT NULL,
    account_name VARCHAR(255) NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    cost_element_category VARCHAR(2),
    cost_category VARCHAR(20),
    balance_sheet_account BOOLEAN DEFAULT false,
    cost_relevant BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(company_code, account_code)
);

-- Financial Documents
CREATE TABLE financial_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_number VARCHAR(50) UNIQUE NOT NULL,
    document_type VARCHAR(10) NOT NULL,
    company_code VARCHAR(4) NOT NULL,
    posting_date DATE NOT NULL,
    document_date DATE NOT NULL,
    reference_document VARCHAR(100),
    header_text TEXT,
    total_amount DECIMAL(15,2) DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'USD',
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Journal Entries
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES financial_documents(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    account_code VARCHAR(10) NOT NULL REFERENCES chart_of_accounts(account_code),
    debit_amount DECIMAL(15,2) DEFAULT 0,
    credit_amount DECIMAL(15,2) DEFAULT 0,
    cost_center VARCHAR(10),
    project_code VARCHAR(50),
    wbs_element VARCHAR(50),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(document_id, line_number)
);

-- =====================================================
-- PROCUREMENT & VENDOR MANAGEMENT
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
    specializations TEXT[],
    rating DECIMAL(3,2) DEFAULT 0,
    company_code_id UUID REFERENCES company_codes(id),
    is_inter_company BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subcontractors
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
    purchasing_org_id UUID REFERENCES purchasing_organizations(id),
    created_by UUID NOT NULL REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
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
    description TEXT NOT NULL,
    specification TEXT,
    quantity DECIMAL(15,4) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    unit_rate DECIMAL(15,2) NOT NULL,
    line_total DECIMAL(15,2) GENERATED ALWAYS AS (quantity * unit_rate) STORED,
    received_quantity DECIMAL(15,4) DEFAULT 0,
    pending_quantity DECIMAL(15,4) GENERATED ALWAYS AS (quantity - received_quantity) STORED,
    delivery_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(po_id, line_number)
);

-- =====================================================
-- INVENTORY MANAGEMENT
-- =====================================================

-- Stores/Warehouses
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    location TEXT,
    store_keeper_id UUID REFERENCES users(id),
    storage_location_id UUID REFERENCES storage_locations(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, code)
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

-- Goods Receipt Notes
CREATE TABLE goods_receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    po_id UUID NOT NULL REFERENCES purchase_orders(id),
    store_id UUID NOT NULL REFERENCES stores(id),
    grn_number VARCHAR(50) UNIQUE NOT NULL,
    vendor_id UUID NOT NULL REFERENCES vendors(id),
    receipt_date DATE NOT NULL,
    received_by UUID NOT NULL REFERENCES users(id),
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

-- Stock Movements
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id),
    stock_item_id UUID NOT NULL REFERENCES stock_items(id),
    movement_type movement_type NOT NULL,
    reference_number VARCHAR(100) NOT NULL,
    reference_type VARCHAR(50) NOT NULL,
    reference_id UUID,
    quantity DECIMAL(15,4) NOT NULL,
    unit_cost DECIMAL(15,2) NOT NULL,
    total_cost DECIMAL(15,2) GENERATED ALWAYS AS (quantity * unit_cost) STORED,
    movement_date DATE NOT NULL,
    created_by UUID NOT NULL REFERENCES users(id),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TIME MANAGEMENT
-- =====================================================

-- Timesheets
CREATE TABLE timesheets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    week_ending_date DATE NOT NULL,
    status timesheet_status NOT NULL DEFAULT 'draft',
    total_hours DECIMAL(8,2) DEFAULT 0,
    total_overtime_hours DECIMAL(8,2) DEFAULT 0,
    submitted_date TIMESTAMP WITH TIME ZONE,
    approved_by UUID REFERENCES users(id),
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
    entry_date DATE NOT NULL,
    entry_type entry_type NOT NULL DEFAULT 'regular',
    hours DECIMAL(8,2) NOT NULL,
    description TEXT,
    billable BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- COSTING & BOQ
-- =====================================================

-- Cost Objects
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
    reference_type VARCHAR(50),
    reference_id UUID,
    description TEXT,
    created_by UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- BOQ Categories
CREATE TABLE boq_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) NOT NULL,
    description TEXT,
    parent_category_id UUID REFERENCES boq_categories(id),
    sequence_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
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
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Organizational indexes
CREATE INDEX idx_plants_company_code ON plants(company_code_id);
CREATE INDEX idx_storage_locations_plant ON storage_locations(plant_id);
CREATE INDEX idx_cost_centers_company ON cost_centers(company_code_id);

-- User management indexes
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_users_company ON users(company_code_id);
CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);
CREATE INDEX idx_role_auth_objects_role ON role_authorization_objects(role_id);
CREATE INDEX idx_role_auth_objects_auth ON role_authorization_objects(auth_object_id);

-- Project management indexes
CREATE INDEX idx_projects_company_code ON projects(company_code_id);
CREATE INDEX idx_wbs_nodes_project ON wbs_nodes(project_id);
CREATE INDEX idx_wbs_nodes_parent ON wbs_nodes(parent_id);
CREATE INDEX idx_activities_project ON activities(project_id);
CREATE INDEX idx_activities_wbs ON activities(wbs_node_id);
CREATE INDEX idx_tasks_project ON tasks(project_id);
CREATE INDEX idx_tasks_activity ON tasks(activity_id);

-- Financial indexes
CREATE INDEX idx_chart_of_accounts_company ON chart_of_accounts(company_code);
CREATE INDEX idx_chart_of_accounts_type ON chart_of_accounts(account_type);
CREATE INDEX idx_financial_documents_date ON financial_documents(posting_date);
CREATE INDEX idx_journal_entries_account ON journal_entries(account_code);
CREATE INDEX idx_journal_entries_project ON journal_entries(project_code);

-- Procurement indexes
CREATE INDEX idx_vendors_company ON vendors(company_code_id);
CREATE INDEX idx_purchase_orders_project ON purchase_orders(project_id);
CREATE INDEX idx_purchase_orders_vendor ON purchase_orders(vendor_id);
CREATE INDEX idx_po_lines_po ON po_lines(po_id);

-- Inventory indexes
CREATE INDEX idx_stores_project ON stores(project_id);
CREATE INDEX idx_stock_balances_store ON stock_balances(store_id);
CREATE INDEX idx_stock_movements_store_item ON stock_movements(store_id, stock_item_id);
CREATE INDEX idx_goods_receipts_project ON goods_receipts(project_id);

-- Time management indexes
CREATE INDEX idx_timesheets_user_project ON timesheets(user_id, project_id);
CREATE INDEX idx_timesheet_entries_timesheet ON timesheet_entries(timesheet_id);

-- Costing indexes
CREATE INDEX idx_cost_objects_project ON cost_objects(project_id);
CREATE INDEX idx_actual_costs_project ON actual_costs(project_id);
CREATE INDEX idx_actual_costs_cost_object ON actual_costs(cost_object_id);

-- =====================================================
-- TRIGGERS AND FUNCTIONS
-- =====================================================

-- Update timestamps function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply timestamp triggers
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_wbs_nodes_updated_at BEFORE UPDATE ON wbs_nodes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_activities_updated_at BEFORE UPDATE ON activities FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update PO received quantities
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

-- Update stock balances
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

-- Authorization check function
CREATE OR REPLACE FUNCTION check_user_authorization(
    user_id UUID,
    auth_object TEXT,
    check_fields JSONB
) RETURNS BOOLEAN AS $$
DECLARE
    auth_record RECORD;
    field_key TEXT;
    field_values TEXT[];
    check_value TEXT;
BEGIN
    -- Get user's authorization through role
    SELECT rao.field_values INTO auth_record
    FROM users u
    JOIN user_roles ur ON u.id = ur.user_id
    JOIN role_authorization_objects rao ON ur.role_id = rao.role_id
    JOIN authorization_objects ao ON rao.auth_object_id = ao.id
    WHERE u.id = user_id 
      AND ao.object_name = auth_object
      AND rao.is_active = true
      AND ao.is_active = true;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Check each field
    FOR field_key IN SELECT jsonb_object_keys(check_fields)
    LOOP
        SELECT ARRAY(SELECT jsonb_array_elements_text(auth_record.field_values->field_key)) INTO field_values;
        SELECT jsonb_extract_path_text(check_fields, field_key) INTO check_value;
        
        IF NOT ('*' = ANY(field_values) OR check_value = ANY(field_values)) THEN
            RETURN FALSE;
        END IF;
    END LOOP;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- VIEWS FOR REPORTING
-- =====================================================

-- Project Line Items (CJI3 equivalent)
CREATE OR REPLACE VIEW project_line_items AS
SELECT 
    je.id,
    je.document_id,
    fd.document_number,
    fd.document_type,
    fd.posting_date,
    EXTRACT(YEAR FROM fd.posting_date) as period_year,
    EXTRACT(MONTH FROM fd.posting_date) as period_month,
    je.account_code as cost_element_code,
    coa.account_name as cost_element_name,
    coa.cost_category,
    je.project_code,
    je.wbs_element,
    je.cost_center,
    CASE 
        WHEN je.debit_amount > 0 THEN je.debit_amount 
        ELSE -je.credit_amount 
    END as amount,
    je.description,
    fd.reference_document,
    fd.created_by,
    je.created_at
FROM journal_entries je
JOIN financial_documents fd ON je.document_id = fd.id
JOIN chart_of_accounts coa ON je.account_code = coa.account_code
WHERE coa.cost_relevant = true 
  AND je.project_code IS NOT NULL;

-- User Authorization Summary
CREATE OR REPLACE VIEW user_authorization_summary AS
SELECT 
    u.id as user_id,
    u.email,
    u.name,
    r.name as role_name,
    ao.object_name,
    ao.description as auth_description,
    rao.field_values,
    rao.is_active
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
JOIN role_authorization_objects rao ON r.id = rao.role_id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE u.is_active = true 
  AND r.is_active = true 
  AND rao.is_active = true 
  AND ao.is_active = true;

-- =====================================================
-- COMMENTS AND DOCUMENTATION
-- =====================================================

COMMENT ON SCHEMA public IS 'Construction Management SaaS - Unified Database Schema';
COMMENT ON TABLE company_codes IS 'Legal entities/companies in the system';
COMMENT ON TABLE projects IS 'Construction projects with SAP organizational assignments';
COMMENT ON TABLE wbs_nodes IS 'Work Breakdown Structure hierarchy';
COMMENT ON TABLE activities IS 'Schedulable work units with dependencies';
COMMENT ON TABLE tasks IS 'Progress tracking items under activities';
COMMENT ON TABLE authorization_objects IS 'SAP-style authorization objects for granular permissions';
COMMENT ON TABLE chart_of_accounts IS 'Multi-company chart of accounts with cost elements';
COMMENT ON TABLE purchase_orders IS 'Procurement documents with approval workflow';
COMMENT ON TABLE stock_movements IS 'All inventory movements with full traceability';
COMMENT ON TABLE timesheets IS 'Employee time tracking with approval workflow';

-- Schema creation completed
SELECT 'Unified Construction Management Schema Created Successfully!' as status;