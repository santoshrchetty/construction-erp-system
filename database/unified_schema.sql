-- =====================================================
-- CONSTRUCTION MANAGEMENT SAAS - UNIFIED SCHEMA v3.0
-- Single Source of Truth - ALIGNED WITH SUPABASE DATABASE
-- =====================================================
-- Version: 3.0 (Current Production Schema)
-- Last Updated: 2024
-- Description: Complete database schema matching actual Supabase database
-- Status: ✅ ALIGNED - All constraints applied successfully

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
CREATE TYPE activity_type AS ENUM ('INTERNAL', 'EXTERNAL');
CREATE TYPE cost_type AS ENUM ('labor', 'material', 'equipment', 'subcontractor', 'overhead', 'other');
CREATE TYPE cost_status AS ENUM ('planned', 'committed', 'actual', 'accrued');
CREATE TYPE po_status AS ENUM ('draft', 'pending_approval', 'approved', 'sent', 'acknowledged', 'partially_received', 'fully_received', 'cancelled');
CREATE TYPE po_type AS ENUM ('standard', 'blanket', 'contract', 'emergency');
CREATE TYPE receipt_status AS ENUM ('pending', 'received', 'partially_received', 'rejected', 'returned');
CREATE TYPE quality_status AS ENUM ('pending', 'passed', 'failed', 'conditional');
CREATE TYPE movement_type AS ENUM ('receipt', 'issue', 'return', 'transfer', 'adjustment', 'write_off');
CREATE TYPE requisition_status AS ENUM ('draft', 'submitted', 'approved', 'rejected', 'cancelled');
CREATE TYPE subcontract_status AS ENUM ('draft', 'approved', 'active', 'completed', 'cancelled');
CREATE TYPE indirect_allocation_method AS ENUM ('percentage_of_direct', 'fixed_amount', 'activity_based');

-- =====================================================
-- ORGANIZATIONAL STRUCTURE
-- =====================================================

-- Company Codes
CREATE TABLE company_codes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR NOT NULL UNIQUE,
    company_name VARCHAR NOT NULL,
    legal_entity_name VARCHAR NOT NULL,
    currency VARCHAR DEFAULT 'INR',
    country VARCHAR DEFAULT 'IN',
    address TEXT,
    tax_number VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    controlling_area_code VARCHAR
);

-- Controlling Areas
CREATE TABLE controlling_areas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cocarea_code VARCHAR NOT NULL UNIQUE,
    cocarea_name VARCHAR NOT NULL,
    currency VARCHAR NOT NULL DEFAULT 'USD',
    fiscal_year_variant VARCHAR DEFAULT 'K4',
    chart_of_accounts_id UUID,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Company Controlling Areas
CREATE TABLE company_controlling_areas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    controlling_area_id UUID NOT NULL REFERENCES controlling_areas(id),
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE
);

-- Purchasing Organizations
CREATE TABLE purchasing_organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    porg_code VARCHAR NOT NULL UNIQUE,
    porg_name VARCHAR NOT NULL,
    currency VARCHAR DEFAULT 'INR',
    is_active BOOLEAN DEFAULT true
);

-- Plants
CREATE TABLE plants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    plant_code VARCHAR NOT NULL UNIQUE,
    plant_name VARCHAR NOT NULL,
    plant_type VARCHAR DEFAULT 'PROJECT',
    address TEXT,
    project_id UUID,
    is_active BOOLEAN DEFAULT true
);

-- Storage Locations
CREATE TABLE storage_locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id UUID NOT NULL REFERENCES plants(id),
    sloc_code VARCHAR NOT NULL,
    sloc_name VARCHAR NOT NULL,
    location_type VARCHAR DEFAULT 'WAREHOUSE',
    is_active BOOLEAN DEFAULT true
);

-- Profit Centers
CREATE TABLE profit_centers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    profit_center_code VARCHAR NOT NULL UNIQUE,
    profit_center_name VARCHAR NOT NULL,
    responsible_person VARCHAR,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Cost Centers
CREATE TABLE cost_centers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    company_code VARCHAR NOT NULL,
    cost_center_code VARCHAR NOT NULL,
    cost_center_name VARCHAR NOT NULL,
    cost_center_type VARCHAR DEFAULT 'STANDARD',
    responsible_person VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    profit_center_id UUID REFERENCES profit_centers(id),
    controlling_area_id UUID REFERENCES controlling_areas(id)
);

-- =====================================================
-- USER MANAGEMENT & SECURITY
-- =====================================================

-- Roles
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL UNIQUE,
    description TEXT,
    permissions JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Permissions
CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Role Permissions
CREATE TABLE role_permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id UUID NOT NULL REFERENCES roles(id),
    permission_id UUID NOT NULL REFERENCES permissions(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Users
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR NOT NULL UNIQUE,
    first_name VARCHAR,
    last_name VARCHAR,
    role_id UUID REFERENCES roles(id),
    employee_code VARCHAR UNIQUE,
    department VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT users_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);

-- Employees
CREATE TABLE employees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_code VARCHAR NOT NULL UNIQUE,
    first_name VARCHAR NOT NULL,
    last_name VARCHAR NOT NULL,
    email VARCHAR UNIQUE,
    phone VARCHAR,
    job_title VARCHAR,
    department VARCHAR,
    hire_date DATE NOT NULL,
    employment_type VARCHAR DEFAULT 'permanent',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Employee Rates
CREATE TABLE employee_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL REFERENCES employees(id),
    project_id UUID,
    rate_type VARCHAR NOT NULL DEFAULT 'regular',
    hourly_rate NUMERIC NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Authorization Objects
CREATE TABLE authorization_objects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    object_name VARCHAR NOT NULL UNIQUE,
    description TEXT NOT NULL,
    module VARCHAR NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Authorization Fields
CREATE TABLE authorization_fields (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_object_id UUID NOT NULL REFERENCES authorization_objects(id),
    field_name VARCHAR NOT NULL,
    field_description TEXT,
    field_values TEXT[] NOT NULL,
    is_required BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Authorizations
CREATE TABLE user_authorizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    auth_object_id UUID NOT NULL REFERENCES authorization_objects(id),
    field_values JSONB NOT NULL,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Role Authorization Mapping
CREATE TABLE role_authorization_mapping (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name VARCHAR NOT NULL,
    auth_object_name VARCHAR NOT NULL,
    field_values JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Authorization Audit Log
CREATE TABLE authorization_audit_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    auth_object_name TEXT NOT NULL,
    access_granted BOOLEAN NOT NULL,
    ip_address INET,
    user_agent TEXT,
    session_id TEXT,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- User Project Access
CREATE TABLE user_project_access (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    project_id UUID NOT NULL,
    access_level VARCHAR NOT NULL DEFAULT 'read',
    assigned_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_active BOOLEAN DEFAULT true,
    CONSTRAINT user_project_access_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =====================================================
-- TILES & UI
-- =====================================================

-- Tile Categories
CREATE TABLE tile_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_name VARCHAR NOT NULL UNIQUE,
    module_code VARCHAR NOT NULL,
    description TEXT,
    icon VARCHAR,
    color VARCHAR,
    sequence_order INTEGER DEFAULT 0
);

-- Tiles
CREATE TABLE tiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR NOT NULL,
    subtitle VARCHAR,
    icon VARCHAR NOT NULL,
    color VARCHAR DEFAULT 'bg-blue-500',
    route VARCHAR NOT NULL,
    roles TEXT[] NOT NULL DEFAULT '{}',
    sequence_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    auth_object VARCHAR,
    construction_action VARCHAR,
    module_code VARCHAR,
    tile_category VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tile Workflow Status
CREATE TABLE tile_workflow_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    tile_id UUID NOT NULL,
    status VARCHAR NOT NULL DEFAULT 'active',
    pending_count INTEGER DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    context_data JSONB,
    CONSTRAINT tile_workflow_status_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT tile_workflow_status_tile_id_fkey FOREIGN KEY (tile_id) REFERENCES tiles(id)
);

-- =====================================================
-- PROJECT MANAGEMENT
-- =====================================================

-- Projects
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR NOT NULL,
    code VARCHAR NOT NULL UNIQUE,
    description TEXT,
    project_type project_type NOT NULL,
    status project_status NOT NULL DEFAULT 'planning',
    start_date DATE NOT NULL,
    planned_end_date DATE NOT NULL,
    actual_end_date DATE,
    budget NUMERIC NOT NULL,
    client_id UUID,
    project_manager_id UUID,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    site_code VARCHAR,
    site_name VARCHAR,
    working_days INTEGER[] DEFAULT '{1,2,3,4,5}',
    holidays DATE[] DEFAULT '{}',
    created_by UUID,
    project_indirect_cost_plan NUMERIC DEFAULT 0,
    project_indirect_cost_actual NUMERIC DEFAULT 0,
    indirect_cost_allocation_method indirect_allocation_method DEFAULT 'percentage_of_direct',
    project_direct_cost_total NUMERIC DEFAULT 0,
    company_code_id UUID,
    purchasing_org_id UUID,
    plant_id UUID,
    profit_center_id UUID,
    CONSTRAINT projects_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id),
    CONSTRAINT projects_company_code_id_fkey FOREIGN KEY (company_code_id) REFERENCES company_codes(id),
    CONSTRAINT projects_purchasing_org_id_fkey FOREIGN KEY (purchasing_org_id) REFERENCES purchasing_organizations(id),
    CONSTRAINT projects_plant_id_fkey FOREIGN KEY (plant_id) REFERENCES plants(id),
    CONSTRAINT projects_profit_center_id_fkey FOREIGN KEY (profit_center_id) REFERENCES profit_centers(id)
);

-- WBS Nodes
CREATE TABLE wbs_nodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    parent_id UUID REFERENCES wbs_nodes(id),
    code VARCHAR NOT NULL,
    name VARCHAR NOT NULL,
    description TEXT,
    node_type wbs_node_type NOT NULL,
    level INTEGER NOT NULL,
    sequence_order INTEGER NOT NULL,
    budget_allocation NUMERIC DEFAULT 0,
    planned_hours NUMERIC DEFAULT 0,
    responsible_user_id UUID,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    wbs_direct_cost_total NUMERIC DEFAULT 0,
    wbs_indirect_cost_allocated NUMERIC DEFAULT 0,
    wbs_total_cost NUMERIC DEFAULT (wbs_direct_cost_total + wbs_indirect_cost_allocated)
);

-- Activities
CREATE TABLE activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID NOT NULL REFERENCES wbs_nodes(id),
    code VARCHAR NOT NULL,
    name VARCHAR NOT NULL,
    description TEXT,
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    planned_hours NUMERIC DEFAULT 0,
    budget_amount NUMERIC DEFAULT 0,
    responsible_user_id UUID,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    duration_days INTEGER DEFAULT 0,
    progress_percentage NUMERIC DEFAULT 0,
    status VARCHAR DEFAULT 'not_started',
    priority VARCHAR DEFAULT 'medium',
    assigned_resources TEXT[],
    predecessor_activities TEXT[],
    dependency_type VARCHAR DEFAULT 'finish_to_start',
    lag_days INTEGER DEFAULT 0,
    activity_type activity_type DEFAULT 'INTERNAL',
    cost_rate NUMERIC DEFAULT 0,
    assigned_internal_team TEXT[],
    vendor_id UUID,
    rate NUMERIC DEFAULT 0,
    quantity NUMERIC DEFAULT 0,
    requires_po BOOLEAN DEFAULT false,
    direct_labor_cost NUMERIC DEFAULT 0,
    direct_material_cost NUMERIC DEFAULT 0,
    direct_equipment_cost NUMERIC DEFAULT 0,
    direct_subcontract_cost NUMERIC DEFAULT 0,
    direct_expense_cost NUMERIC DEFAULT 0,
    direct_cost_total NUMERIC DEFAULT ((((direct_labor_cost + direct_material_cost) + direct_equipment_cost) + direct_subcontract_cost) + direct_expense_cost),
    actual_duration_days INTEGER DEFAULT 0,
    baseline_start_date DATE,
    baseline_end_date DATE,
    baseline_duration_days INTEGER
);

-- Activity Dependencies
CREATE TABLE activity_dependencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    predecessor_activity_id UUID NOT NULL REFERENCES activities(id),
    successor_activity_id UUID NOT NULL REFERENCES activities(id),
    dependency_type VARCHAR NOT NULL DEFAULT 'finish_to_start',
    lag_days INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID,
    activity_id UUID,
    name VARCHAR NOT NULL,
    description TEXT,
    status task_status NOT NULL DEFAULT 'not_started',
    priority task_priority NOT NULL DEFAULT 'medium',
    progress_percentage NUMERIC DEFAULT 0,
    assigned_to UUID,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    checklist_item BOOLEAN DEFAULT false,
    completion_date DATE,
    photos TEXT[],
    daily_logs TEXT,
    material_usage JSONB,
    qa_notes TEXT,
    safety_notes TEXT,
    CONSTRAINT tasks_wbs_node_id_fkey FOREIGN KEY (wbs_node_id) REFERENCES wbs_nodes(id),
    CONSTRAINT tasks_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES activities(id)
);

-- Service Lines
CREATE TABLE service_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id),
    line_description TEXT NOT NULL,
    quantity NUMERIC NOT NULL,
    uom VARCHAR NOT NULL,
    rate NUMERIC NOT NULL,
    amount NUMERIC DEFAULT (quantity * rate),
    actual_quantity NUMERIC DEFAULT 0,
    actual_amount NUMERIC DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Project Billing
CREATE TABLE project_billing (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    billing_date DATE NOT NULL,
    billing_amount NUMERIC NOT NULL,
    billing_type VARCHAR DEFAULT 'progress',
    description TEXT,
    invoice_number VARCHAR,
    status VARCHAR DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Project Indirect Costs
CREATE TABLE project_indirect_costs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    cost_category VARCHAR NOT NULL,
    description TEXT NOT NULL,
    planned_amount NUMERIC DEFAULT 0,
    actual_amount NUMERIC DEFAULT 0,
    expense_date DATE,
    allocation_method indirect_allocation_method DEFAULT 'percentage_of_direct',
    allocation_percentage NUMERIC DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- FINANCIAL MANAGEMENT
-- =====================================================

-- Chart of Accounts
CREATE TABLE chart_of_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    coa_code VARCHAR NOT NULL UNIQUE,
    coa_name VARCHAR NOT NULL,
    country VARCHAR,
    currency VARCHAR,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    account_code VARCHAR,
    account_name VARCHAR,
    account_type VARCHAR,
    cost_element_category VARCHAR,
    cost_category VARCHAR,
    balance_sheet_account BOOLEAN DEFAULT false,
    cost_relevant BOOLEAN DEFAULT false,
    company_code VARCHAR DEFAULT 'C001'
);

-- GL Accounts
CREATE TABLE gl_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chart_of_accounts_id UUID NOT NULL REFERENCES chart_of_accounts(id),
    account_code VARCHAR NOT NULL,
    account_name VARCHAR NOT NULL,
    account_type VARCHAR NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Financial Documents
CREATE TABLE financial_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_number VARCHAR NOT NULL UNIQUE,
    document_type VARCHAR NOT NULL,
    posting_date DATE NOT NULL,
    document_date DATE NOT NULL,
    reference_document VARCHAR,
    total_amount NUMERIC NOT NULL,
    currency VARCHAR DEFAULT 'USD',
    company_code VARCHAR DEFAULT 'C001',
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reversed_by VARCHAR,
    reversal_date DATE,
    reversal_reason TEXT,
    is_reversed BOOLEAN DEFAULT false
);

-- Journal Entries
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES financial_documents(id),
    line_item INTEGER NOT NULL,
    account_code VARCHAR NOT NULL,
    debit_amount NUMERIC DEFAULT 0,
    credit_amount NUMERIC DEFAULT 0,
    project_code VARCHAR,
    wbs_element VARCHAR,
    cost_center VARCHAR,
    description TEXT,
    reference_key VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    profit_center VARCHAR
);

-- Document Number Ranges
CREATE TABLE document_number_ranges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR NOT NULL,
    document_type VARCHAR NOT NULL,
    fiscal_year INTEGER NOT NULL,
    range_from VARCHAR NOT NULL,
    range_to VARCHAR NOT NULL,
    current_number VARCHAR NOT NULL,
    external_numbering BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ERP CONFIGURATION TABLES
-- =====================================================

-- Material Groups
CREATE TABLE material_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_code VARCHAR NOT NULL UNIQUE,
    group_name VARCHAR NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Vendor Categories
CREATE TABLE vendor_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_code VARCHAR NOT NULL UNIQUE,
    category_name VARCHAR NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Payment Terms
CREATE TABLE payment_terms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    term_code VARCHAR NOT NULL UNIQUE,
    term_name VARCHAR NOT NULL,
    net_days INTEGER NOT NULL,
    discount_days INTEGER DEFAULT 0,
    discount_percent NUMERIC DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- UOM Groups
CREATE TABLE uom_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    base_uom VARCHAR NOT NULL UNIQUE,
    uom_name VARCHAR NOT NULL,
    dimension VARCHAR,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Material Status
CREATE TABLE material_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    status_code VARCHAR NOT NULL UNIQUE,
    status_name VARCHAR NOT NULL,
    allow_procurement BOOLEAN DEFAULT true,
    allow_consumption BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Valuation Classes
CREATE TABLE valuation_classes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    class_code VARCHAR NOT NULL UNIQUE,
    class_name VARCHAR NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Movement Types
CREATE TABLE movement_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type VARCHAR NOT NULL UNIQUE,
    movement_name VARCHAR NOT NULL,
    movement_indicator VARCHAR NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Account Keys
CREATE TABLE account_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_key_code VARCHAR NOT NULL UNIQUE,
    account_key_name VARCHAR NOT NULL,
    description TEXT,
    debit_credit_indicator VARCHAR NOT NULL,
    is_active BOOLEAN DEFAULT true
);

-- Movement Type Account Keys
CREATE TABLE movement_type_account_keys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    movement_type_id UUID NOT NULL REFERENCES movement_types(id),
    account_key_id UUID NOT NULL REFERENCES account_keys(id),
    debit_credit_indicator VARCHAR NOT NULL CHECK (debit_credit_indicator IN ('D', 'C')),
    sequence_order INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    account_assignment_category VARCHAR
);

-- Account Determination (ALIGNED WITH SUPABASE)
CREATE TABLE account_determination (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code_id UUID NOT NULL REFERENCES company_codes(id),
    valuation_class_id UUID NOT NULL REFERENCES valuation_classes(id),
    account_key_id UUID NOT NULL REFERENCES account_keys(id),
    gl_account_id UUID NOT NULL REFERENCES chart_of_accounts(id),
    is_active BOOLEAN DEFAULT true,
    account_assignment_category VARCHAR,
    CONSTRAINT account_determination_unique_key UNIQUE (company_code_id, valuation_class_id, account_key_id)
);

-- Movement Type Account Mappings
CREATE TABLE movement_type_account_mappings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_code VARCHAR NOT NULL,
    movement_type VARCHAR NOT NULL,
    material_type VARCHAR DEFAULT '*',
    account_modification VARCHAR DEFAULT '001',
    debit_account VARCHAR NOT NULL,
    credit_account VARCHAR NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- MATERIALS MANAGEMENT
-- =====================================================

-- Material Types
CREATE TABLE material_types (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_type_code VARCHAR NOT NULL UNIQUE,
    material_type_name VARCHAR NOT NULL,
    description TEXT,
    inventory_managed BOOLEAN DEFAULT true,
    quantity_update BOOLEAN DEFAULT true,
    value_update BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true
);

-- Materials
CREATE TABLE materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_code VARCHAR NOT NULL UNIQUE,
    material_name VARCHAR NOT NULL,
    description TEXT,
    material_group_id UUID,
    material_status_id UUID,
    base_uom VARCHAR NOT NULL,
    material_type VARCHAR DEFAULT 'ROH',
    standard_price NUMERIC DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valuation_class_id UUID REFERENCES valuation_classes(id),
    category VARCHAR,
    CONSTRAINT materials_material_group_id_fkey FOREIGN KEY (material_group_id) REFERENCES material_groups(id),
    CONSTRAINT materials_material_status_id_fkey FOREIGN KEY (material_status_id) REFERENCES material_status(id)
);

-- Material Plant Data
CREATE TABLE material_plant_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL,
    plant_id UUID NOT NULL REFERENCES plants(id),
    reorder_level NUMERIC DEFAULT 0,
    safety_stock NUMERIC DEFAULT 0,
    maximum_stock NUMERIC DEFAULT 0,
    default_storage_location_id UUID,
    procurement_type VARCHAR DEFAULT 'F',
    standard_price NUMERIC DEFAULT 0,
    price_unit NUMERIC DEFAULT 1,
    currency VARCHAR DEFAULT 'INR',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT material_plant_data_default_storage_location_id_fkey FOREIGN KEY (default_storage_location_id) REFERENCES storage_locations(id)
);

-- Material Storage Data
CREATE TABLE material_storage_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL,
    storage_location_id UUID NOT NULL REFERENCES storage_locations(id),
    current_stock NUMERIC DEFAULT 0,
    reserved_stock NUMERIC DEFAULT 0,
    available_stock NUMERIC DEFAULT (current_stock - reserved_stock),
    last_movement_date DATE,
    bin_location VARCHAR
);

-- Material Movements
CREATE TABLE material_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID,
    movement_type VARCHAR NOT NULL,
    quantity NUMERIC NOT NULL,
    unit_price NUMERIC DEFAULT 0,
    storage_location VARCHAR DEFAULT '0001',
    reference_doc VARCHAR,
    movement_date DATE NOT NULL,
    posting_date DATE NOT NULL,
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT material_movements_material_id_fkey FOREIGN KEY (material_id) REFERENCES materials(id)
);

-- Stock Levels
CREATE TABLE stock_levels (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID,
    storage_location VARCHAR DEFAULT '0001',
    current_stock NUMERIC DEFAULT 0,
    reserved_stock NUMERIC DEFAULT 0,
    available_stock NUMERIC DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT stock_levels_material_id_fkey FOREIGN KEY (material_id) REFERENCES materials(id)
);

-- Plant Stock Thresholds
CREATE TABLE plant_stock_thresholds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plant_id UUID NOT NULL REFERENCES plants(id),
    material_category VARCHAR NOT NULL,
    low_stock_threshold NUMERIC NOT NULL,
    normal_stock_threshold NUMERIC NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- PROCUREMENT & VENDOR MANAGEMENT
-- =====================================================

-- Vendors
CREATE TABLE vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_code VARCHAR NOT NULL UNIQUE,
    vendor_name VARCHAR NOT NULL,
    vendor_category_id UUID,
    payment_terms_id UUID,
    contact_person VARCHAR,
    phone VARCHAR,
    email VARCHAR,
    address TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT vendors_vendor_category_id_fkey FOREIGN KEY (vendor_category_id) REFERENCES vendor_categories(id),
    CONSTRAINT vendors_payment_terms_id_fkey FOREIGN KEY (payment_terms_id) REFERENCES payment_terms(id)
);

-- Subcontractors
CREATE TABLE subcontractors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    vendor_id UUID NOT NULL,
    license_number VARCHAR,
    license_expiry DATE,
    insurance_policy VARCHAR,
    insurance_expiry DATE,
    safety_rating NUMERIC,
    performance_bond_required BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subcontractor Rates
CREATE TABLE subcontractor_rates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subcontractor_id UUID NOT NULL,
    project_id UUID,
    work_type VARCHAR NOT NULL,
    unit_type VARCHAR NOT NULL DEFAULT 'hour',
    unit_rate NUMERIC NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT subcontractor_rates_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id)
);

-- Purchase Requisitions
CREATE TABLE purchase_requisitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    requisition_number VARCHAR NOT NULL UNIQUE,
    requested_by UUID NOT NULL,
    department VARCHAR,
    priority INTEGER DEFAULT 3 CHECK (priority >= 1 AND priority <= 5),
    required_date DATE NOT NULL,
    justification TEXT,
    status requisition_status DEFAULT 'draft',
    approved_by UUID,
    approved_date TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    total_estimated_cost NUMERIC DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- PR Lines
CREATE TABLE pr_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pr_id UUID NOT NULL REFERENCES purchase_requisitions(id),
    line_number INTEGER NOT NULL,
    description TEXT NOT NULL,
    specification TEXT,
    quantity NUMERIC NOT NULL,
    unit VARCHAR NOT NULL,
    estimated_unit_cost NUMERIC,
    estimated_total_cost NUMERIC DEFAULT (quantity * COALESCE(estimated_unit_cost, 0)),
    cost_object_id UUID,
    urgency_level INTEGER DEFAULT 3,
    preferred_vendor_id UUID
);

-- Vendor Quotations
CREATE TABLE vendor_quotations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    pr_line_id UUID NOT NULL REFERENCES pr_lines(id),
    vendor_id UUID NOT NULL,
    quotation_number VARCHAR,
    quoted_price NUMERIC NOT NULL,
    delivery_days INTEGER,
    validity_date DATE,
    terms_conditions TEXT,
    is_selected BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Purchase Orders
CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    po_number VARCHAR NOT NULL UNIQUE,
    vendor_id UUID NOT NULL,
    po_type po_type NOT NULL DEFAULT 'standard',
    status po_status NOT NULL DEFAULT 'draft',
    issue_date DATE NOT NULL,
    delivery_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL,
    tax_amount NUMERIC DEFAULT 0,
    grand_total NUMERIC DEFAULT (total_amount + tax_amount),
    payment_terms VARCHAR,
    delivery_terms TEXT,
    created_by UUID NOT NULL,
    approved_by UUID,
    approved_date TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    purchasing_org_id UUID,
    CONSTRAINT purchase_orders_purchasing_org_id_fkey FOREIGN KEY (purchasing_org_id) REFERENCES purchasing_organizations(id)
);

-- Purchase Order Items
CREATE TABLE purchase_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_id UUID,
    item_number INTEGER NOT NULL,
    material_id UUID,
    quantity NUMERIC NOT NULL,
    unit_price NUMERIC NOT NULL,
    total_price NUMERIC NOT NULL,
    delivery_date DATE,
    received_quantity NUMERIC DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT purchase_order_items_po_id_fkey FOREIGN KEY (po_id) REFERENCES purchase_orders(id),
    CONSTRAINT purchase_order_items_material_id_fkey FOREIGN KEY (material_id) REFERENCES materials(id)
);

-- PO Lines
CREATE TABLE po_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_id UUID NOT NULL REFERENCES purchase_orders(id),
    line_number INTEGER NOT NULL,
    boq_item_id UUID,
    description TEXT NOT NULL,
    specification TEXT,
    quantity NUMERIC NOT NULL,
    unit VARCHAR NOT NULL,
    unit_rate NUMERIC NOT NULL,
    line_total NUMERIC DEFAULT (quantity * unit_rate),
    received_quantity NUMERIC DEFAULT 0,
    pending_quantity NUMERIC DEFAULT (quantity - received_quantity),
    delivery_date DATE
);

-- Subcontract Orders
CREATE TABLE subcontract_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    subcontract_number VARCHAR NOT NULL UNIQUE,
    vendor_id UUID NOT NULL,
    work_description TEXT NOT NULL,
    contract_value NUMERIC NOT NULL,
    start_date DATE NOT NULL,
    completion_date DATE NOT NULL,
    status subcontract_status DEFAULT 'draft',
    retention_percentage NUMERIC DEFAULT 5.00,
    advance_percentage NUMERIC DEFAULT 0.00,
    payment_terms TEXT,
    performance_bond_required BOOLEAN DEFAULT false,
    created_by UUID NOT NULL,
    approved_by UUID,
    approved_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subcontract Milestones
CREATE TABLE subcontract_milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subcontract_id UUID NOT NULL REFERENCES subcontract_orders(id),
    milestone_name VARCHAR NOT NULL,
    description TEXT,
    planned_completion_date DATE NOT NULL,
    actual_completion_date DATE,
    milestone_value NUMERIC NOT NULL,
    is_completed BOOLEAN DEFAULT false,
    completion_percentage NUMERIC DEFAULT 0,
    sequence_order INTEGER NOT NULL
);

-- =====================================================
-- INVENTORY MANAGEMENT
-- =====================================================

-- Stores
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    name VARCHAR NOT NULL,
    code VARCHAR NOT NULL,
    location TEXT,
    store_keeper_id UUID,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_auto_created BOOLEAN DEFAULT false,
    site_code VARCHAR,
    auto_delete_when_empty BOOLEAN DEFAULT true,
    storage_location_id UUID,
    CONSTRAINT stores_storage_location_id_fkey FOREIGN KEY (storage_location_id) REFERENCES storage_locations(id)
);

-- Stock Items
CREATE TABLE stock_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_code VARCHAR NOT NULL UNIQUE,
    description TEXT NOT NULL,
    category VARCHAR,
    unit VARCHAR NOT NULL,
    reorder_level NUMERIC DEFAULT 0,
    maximum_level NUMERIC DEFAULT 0,
    minimum_level NUMERIC DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    project_id UUID,
    material_type_id UUID,
    valuation_class_id UUID,
    CONSTRAINT stock_items_project_id_fkey FOREIGN KEY (project_id) REFERENCES projects(id),
    CONSTRAINT stock_items_material_type_id_fkey FOREIGN KEY (material_type_id) REFERENCES material_types(id)
);

-- Stock Balances
CREATE TABLE stock_balances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    stock_item_id UUID NOT NULL REFERENCES stock_items(id),
    current_quantity NUMERIC DEFAULT 0,
    reserved_quantity NUMERIC DEFAULT 0,
    available_quantity NUMERIC DEFAULT (current_quantity - reserved_quantity),
    average_cost NUMERIC DEFAULT 0,
    total_value NUMERIC DEFAULT (current_quantity * average_cost),
    last_movement_date TIMESTAMP WITH TIME ZONE,
    stock_type VARCHAR DEFAULT 'WAREHOUSE',
    account_assignment CHAR DEFAULT 'W',
    project_code VARCHAR,
    wbs_element VARCHAR,
    cost_center VARCHAR,
    storage_location_id UUID NOT NULL,
    CONSTRAINT stock_balances_storage_location_id_fkey FOREIGN KEY (storage_location_id) REFERENCES storage_locations(id)
);

-- Stock Movements
CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id),
    stock_item_id UUID NOT NULL REFERENCES stock_items(id),
    movement_type movement_type NOT NULL,
    reference_number VARCHAR NOT NULL,
    reference_type VARCHAR NOT NULL,
    reference_id UUID,
    quantity NUMERIC NOT NULL,
    unit_cost NUMERIC NOT NULL,
    total_cost NUMERIC DEFAULT (quantity * unit_cost),
    movement_date DATE NOT NULL,
    created_by UUID NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    account_assignment CHAR DEFAULT 'W',
    project_code VARCHAR,
    wbs_element VARCHAR,
    cost_center VARCHAR
);

-- Stock FIFO Layers
CREATE TABLE stock_fifo_layers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id),
    stock_item_id UUID NOT NULL REFERENCES stock_items(id),
    batch_reference VARCHAR NOT NULL,
    receipt_date TIMESTAMP WITH TIME ZONE NOT NULL,
    original_quantity NUMERIC NOT NULL,
    remaining_quantity NUMERIC NOT NULL CHECK (remaining_quantity >= 0),
    unit_cost NUMERIC NOT NULL,
    grn_line_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Goods Receipts
CREATE TABLE goods_receipts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    po_id UUID NOT NULL REFERENCES purchase_orders(id),
    store_id UUID NOT NULL REFERENCES stores(id),
    grn_number VARCHAR NOT NULL UNIQUE,
    vendor_id UUID NOT NULL,
    receipt_date DATE NOT NULL,
    received_by UUID NOT NULL,
    status receipt_status NOT NULL DEFAULT 'pending',
    delivery_note_number VARCHAR,
    vehicle_number VARCHAR,
    driver_name VARCHAR,
    total_received_value NUMERIC DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    quality_status quality_status DEFAULT 'pending',
    quality_checked_by UUID,
    quality_check_date TIMESTAMP WITH TIME ZONE,
    quality_notes TEXT
);

-- GRN Lines
CREATE TABLE grn_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    grn_id UUID NOT NULL REFERENCES goods_receipts(id),
    po_line_id UUID NOT NULL REFERENCES po_lines(id),
    ordered_quantity NUMERIC NOT NULL,
    received_quantity NUMERIC NOT NULL,
    accepted_quantity NUMERIC NOT NULL,
    rejected_quantity NUMERIC DEFAULT 0,
    unit_rate NUMERIC NOT NULL,
    line_value NUMERIC DEFAULT (accepted_quantity * unit_rate),
    quality_status quality_status NOT NULL DEFAULT 'pending',
    batch_number VARCHAR,
    expiry_date DATE,
    notes TEXT
);

-- =====================================================
-- TIME MANAGEMENT
-- =====================================================

-- Daily Timesheets
CREATE TABLE daily_timesheets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timesheet_date DATE NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id),
    employee_id UUID,
    vendor_id UUID,
    supervisor_id UUID,
    status VARCHAR DEFAULT 'draft',
    total_regular_hours NUMERIC DEFAULT 0,
    total_overtime_hours NUMERIC DEFAULT 0,
    total_cost NUMERIC DEFAULT 0,
    submitted_at TIMESTAMP WITH TIME ZONE,
    approved_by UUID,
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT daily_timesheets_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES employees(id),
    CONSTRAINT daily_timesheets_supervisor_id_fkey FOREIGN KEY (supervisor_id) REFERENCES employees(id),
    CONSTRAINT daily_timesheets_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES employees(id)
);

-- Timesheet Lines
CREATE TABLE timesheet_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timesheet_id UUID NOT NULL REFERENCES daily_timesheets(id),
    task_id UUID,
    activity_id UUID,
    cost_object_id UUID,
    work_description TEXT NOT NULL,
    start_time TIME,
    end_time TIME,
    break_minutes INTEGER DEFAULT 0,
    regular_hours NUMERIC NOT NULL DEFAULT 0,
    overtime_hours NUMERIC DEFAULT 0,
    hourly_rate NUMERIC NOT NULL,
    line_cost NUMERIC DEFAULT ((regular_hours + (overtime_hours * 1.5)) * hourly_rate),
    work_location VARCHAR,
    equipment_used TEXT,
    materials_used TEXT,
    weather_conditions VARCHAR,
    remarks TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT timesheet_lines_task_id_fkey FOREIGN KEY (task_id) REFERENCES tasks(id),
    CONSTRAINT timesheet_lines_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES activities(id)
);

-- Timesheet Cost Allocations
CREATE TABLE timesheet_cost_allocations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    timesheet_line_id UUID NOT NULL REFERENCES timesheet_lines(id),
    cost_object_id UUID NOT NULL,
    allocation_date DATE NOT NULL,
    labor_hours NUMERIC NOT NULL,
    labor_cost NUMERIC NOT NULL,
    cost_type VARCHAR DEFAULT 'actual',
    allocation_method VARCHAR DEFAULT 'direct',
    created_by UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- COSTING & BOQ
-- =====================================================

-- Cost Objects
CREATE TABLE cost_objects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID,
    activity_id UUID,
    task_id UUID,
    code VARCHAR NOT NULL,
    name VARCHAR NOT NULL,
    cost_type cost_type NOT NULL,
    budget_amount NUMERIC DEFAULT 0,
    actual_amount NUMERIC DEFAULT 0,
    committed_amount NUMERIC DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT cost_objects_wbs_node_id_fkey FOREIGN KEY (wbs_node_id) REFERENCES wbs_nodes(id),
    CONSTRAINT cost_objects_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES activities(id),
    CONSTRAINT cost_objects_task_id_fkey FOREIGN KEY (task_id) REFERENCES tasks(id)
);

-- Cost Transactions
CREATE TABLE cost_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cost_object_id UUID NOT NULL REFERENCES cost_objects(id),
    transaction_type cost_type NOT NULL,
    amount NUMERIC NOT NULL,
    reference_type VARCHAR NOT NULL,
    reference_id UUID NOT NULL,
    transaction_date DATE NOT NULL,
    description TEXT,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Actual Costs
CREATE TABLE actual_costs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    cost_object_id UUID NOT NULL REFERENCES cost_objects(id),
    wbs_node_id UUID,
    activity_id UUID,
    task_id UUID,
    cost_type cost_type NOT NULL,
    cost_status cost_status NOT NULL DEFAULT 'actual',
    amount NUMERIC NOT NULL,
    cost_date DATE NOT NULL,
    reference_number VARCHAR,
    reference_type VARCHAR,
    reference_id UUID,
    description TEXT,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT actual_costs_wbs_node_id_fkey FOREIGN KEY (wbs_node_id) REFERENCES wbs_nodes(id),
    CONSTRAINT actual_costs_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES activities(id),
    CONSTRAINT actual_costs_task_id_fkey FOREIGN KEY (task_id) REFERENCES tasks(id)
);

-- BOQ Categories
CREATE TABLE boq_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    name VARCHAR NOT NULL,
    code VARCHAR NOT NULL,
    description TEXT,
    parent_category_id UUID REFERENCES boq_categories(id),
    sequence_order INTEGER DEFAULT 0
);

-- BOQ Items
CREATE TABLE boq_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id),
    wbs_node_id UUID,
    category_id UUID NOT NULL REFERENCES boq_categories(id),
    item_code VARCHAR NOT NULL,
    description TEXT NOT NULL,
    specification TEXT,
    unit VARCHAR NOT NULL,
    quantity NUMERIC NOT NULL,
    rate NUMERIC NOT NULL,
    amount NUMERIC DEFAULT (quantity * rate),
    is_provisional BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT boq_items_wbs_node_id_fkey FOREIGN KEY (wbs_node_id) REFERENCES wbs_nodes(id)
);

-- =====================================================
-- MRP & DEMAND MANAGEMENT
-- =====================================================

-- Demand Headers
CREATE TABLE demand_headers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    demand_number VARCHAR NOT NULL UNIQUE,
    demand_source_type VARCHAR NOT NULL,
    demand_source_id UUID NOT NULL,
    cost_object_type VARCHAR NOT NULL,
    cost_object_id UUID NOT NULL,
    demand_status VARCHAR DEFAULT 'active',
    planning_horizon_start DATE,
    planning_horizon_end DATE,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Demand Lines
CREATE TABLE demand_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    demand_header_id UUID NOT NULL REFERENCES demand_headers(id),
    demand_line_type VARCHAR NOT NULL,
    demand_line_id UUID,
    material_code VARCHAR NOT NULL,
    required_quantity NUMERIC NOT NULL,
    unit_of_measure VARCHAR NOT NULL,
    required_date DATE NOT NULL,
    priority_level VARCHAR DEFAULT 'normal',
    bom_explosion_level INTEGER DEFAULT 0,
    line_status VARCHAR DEFAULT 'active'
);

-- Planned Procurement Documents
CREATE TABLE planned_procurement_docs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    planned_doc_number VARCHAR NOT NULL UNIQUE,
    planned_doc_type VARCHAR NOT NULL,
    source_demand_header_id UUID NOT NULL REFERENCES demand_headers(id),
    material_code VARCHAR NOT NULL,
    planned_quantity NUMERIC NOT NULL,
    unit_of_measure VARCHAR NOT NULL,
    planned_date DATE NOT NULL,
    procurement_type VARCHAR NOT NULL,
    estimated_cost NUMERIC,
    conversion_status VARCHAR DEFAULT 'planned',
    converted_document_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- MRP Shortage Analysis
CREATE TABLE mrp_shortage_analysis (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    analysis_run_id UUID NOT NULL,
    material_code VARCHAR NOT NULL,
    planning_date DATE NOT NULL,
    total_demand NUMERIC NOT NULL,
    available_stock NUMERIC NOT NULL,
    reserved_stock NUMERIC NOT NULL,
    net_shortage NUMERIC NOT NULL,
    procurement_proposal_qty NUMERIC,
    procurement_proposal_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- SCHEMA COMPLETION
-- =====================================================

-- Schema creation completed
SELECT 'Unified Construction Management Schema v3.0 Created Successfully - Matching Actual Database!' as status;