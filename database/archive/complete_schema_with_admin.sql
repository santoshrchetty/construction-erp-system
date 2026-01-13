-- Complete Construction Management Schema with Admin Tiles
-- ========================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Step 1: Core Tables
-- ===================

-- Projects table
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    project_type VARCHAR(50) NOT NULL CHECK (project_type IN ('residential', 'commercial', 'infrastructure', 'industrial')),
    status VARCHAR(20) DEFAULT 'planning' CHECK (status IN ('planning', 'active', 'on_hold', 'completed', 'cancelled')),
    start_date DATE,
    planned_end_date DATE,
    actual_end_date DATE,
    budget DECIMAL(15,2),
    actual_cost DECIMAL(15,2) DEFAULT 0,
    client_name VARCHAR(255),
    project_manager_id UUID,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- WBS Nodes table
CREATE TABLE IF NOT EXISTS wbs_nodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES wbs_nodes(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    node_type VARCHAR(20) NOT NULL CHECK (node_type IN ('phase', 'deliverable', 'work_package')),
    level INTEGER NOT NULL DEFAULT 1,
    sequence_order INTEGER DEFAULT 0,
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    budget DECIMAL(15,2),
    actual_cost DECIMAL(15,2) DEFAULT 0,
    progress_percentage DECIMAL(5,2) DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    status VARCHAR(20) DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed', 'on_hold', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(project_id, code)
);

-- Activities table
CREATE TABLE IF NOT EXISTS activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wbs_node_id UUID NOT NULL REFERENCES wbs_nodes(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    activity_type VARCHAR(50) NOT NULL,
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    planned_duration INTEGER,
    actual_duration INTEGER,
    budget DECIMAL(15,2),
    actual_cost DECIMAL(15,2) DEFAULT 0,
    progress_percentage DECIMAL(5,2) DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    status VARCHAR(20) DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed', 'on_hold', 'cancelled')),
    responsible_person_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    activity_id UUID NOT NULL REFERENCES activities(id) ON DELETE CASCADE,
    code VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    task_type VARCHAR(50) NOT NULL,
    planned_start_date DATE,
    planned_end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,
    planned_duration INTEGER,
    actual_duration INTEGER,
    estimated_hours DECIMAL(8,2),
    actual_hours DECIMAL(8,2) DEFAULT 0,
    progress_percentage DECIMAL(5,2) DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    status VARCHAR(20) DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed', 'on_hold', 'cancelled')),
    priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'critical')),
    assigned_to_id UUID,
    created_by_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Task Dependencies table
CREATE TABLE IF NOT EXISTS task_dependencies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    predecessor_task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    successor_task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
    dependency_type VARCHAR(20) DEFAULT 'finish_to_start' CHECK (dependency_type IN ('finish_to_start', 'start_to_start', 'finish_to_finish', 'start_to_finish')),
    lag_days INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(predecessor_task_id, successor_task_id)
);

-- Vendors table
CREATE TABLE IF NOT EXISTS vendors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    contact_person VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    vendor_type VARCHAR(50) NOT NULL,
    payment_terms VARCHAR(100),
    credit_limit DECIMAL(15,2),
    tax_id VARCHAR(50),
    bank_details JSONB,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'blocked')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Purchase Orders table
CREATE TABLE IF NOT EXISTS purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_number VARCHAR(50) UNIQUE NOT NULL,
    project_id UUID NOT NULL REFERENCES projects(id),
    vendor_id UUID NOT NULL REFERENCES vendors(id),
    po_date DATE NOT NULL DEFAULT CURRENT_DATE,
    delivery_date DATE,
    total_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    discount_amount DECIMAL(15,2) DEFAULT 0,
    net_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
    currency VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'pending_approval', 'approved', 'sent', 'partially_received', 'fully_received', 'cancelled')),
    payment_terms VARCHAR(100),
    delivery_address TEXT,
    notes TEXT,
    created_by_id UUID,
    approved_by_id UUID,
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Purchase Order Items table
CREATE TABLE IF NOT EXISTS purchase_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    item_code VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    quantity DECIMAL(10,3) NOT NULL,
    unit_of_measure VARCHAR(20) NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    received_quantity DECIMAL(10,3) DEFAULT 0,
    pending_quantity DECIMAL(10,3) NOT NULL,
    delivery_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Stores table
CREATE TABLE IF NOT EXISTS stores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255),
    store_type VARCHAR(50) NOT NULL,
    manager_id UUID,
    capacity_info JSONB,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'maintenance')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inventory table
CREATE TABLE IF NOT EXISTS inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID NOT NULL REFERENCES stores(id),
    item_code VARCHAR(50) NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    unit_of_measure VARCHAR(20) NOT NULL,
    current_stock DECIMAL(10,3) DEFAULT 0,
    reserved_stock DECIMAL(10,3) DEFAULT 0,
    available_stock DECIMAL(10,3) GENERATED ALWAYS AS (current_stock - reserved_stock) STORED,
    minimum_stock DECIMAL(10,3) DEFAULT 0,
    maximum_stock DECIMAL(10,3),
    reorder_point DECIMAL(10,3),
    standard_cost DECIMAL(12,2),
    last_purchase_price DECIMAL(12,2),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(store_id, item_code)
);

-- Timesheets table
CREATE TABLE IF NOT EXISTS timesheets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID NOT NULL,
    project_id UUID REFERENCES projects(id),
    task_id UUID REFERENCES tasks(id),
    work_date DATE NOT NULL,
    start_time TIME,
    end_time TIME,
    break_duration INTEGER DEFAULT 0,
    total_hours DECIMAL(4,2) NOT NULL,
    overtime_hours DECIMAL(4,2) DEFAULT 0,
    work_description TEXT,
    status VARCHAR(20) DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'approved', 'rejected')),
    submitted_at TIMESTAMP WITH TIME ZONE,
    approved_by_id UUID,
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 2: Authorization Framework
-- ===============================

-- Roles table
CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Authorization Objects table
CREATE TABLE IF NOT EXISTS authorization_objects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    object_name VARCHAR(20) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    module VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Authorization Fields table
CREATE TABLE IF NOT EXISTS authorization_fields (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_object_id UUID NOT NULL REFERENCES authorization_objects(id) ON DELETE CASCADE,
    field_name VARCHAR(20) NOT NULL,
    field_description TEXT,
    field_values TEXT[] NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(auth_object_id, field_name)
);

-- User Authorizations table
CREATE TABLE IF NOT EXISTS user_authorizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    auth_object_name VARCHAR(20) NOT NULL,
    field_values JSONB NOT NULL DEFAULT '{}',
    granted_by UUID,
    granted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(user_id, auth_object_name)
);

-- Role Authorization Mapping table
CREATE TABLE IF NOT EXISTS role_authorization_mapping (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name VARCHAR(50) NOT NULL,
    auth_object_name VARCHAR(20) NOT NULL,
    field_values JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(role_name, auth_object_name)
);

-- User Roles table
CREATE TABLE IF NOT EXISTS user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    role_name VARCHAR(50) NOT NULL,
    assigned_by UUID,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(user_id, role_name)
);

-- Tiles table
CREATE TABLE IF NOT EXISTS tiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(100) NOT NULL,
    subtitle VARCHAR(200),
    icon VARCHAR(50),
    color VARCHAR(20),
    route VARCHAR(200),
    roles TEXT[] DEFAULT '{}',
    sequence_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    auth_object VARCHAR(20),
    construction_action VARCHAR(20),
    module_code VARCHAR(2),
    tile_category VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 3: Construction Authorization Objects
-- ==========================================

INSERT INTO authorization_objects (object_name, description, module) VALUES
-- PS - Project System
('PS_PRJ_INITIATE', 'Project Initiation Authorization', 'project_system'),
('PS_PRJ_MODIFY', 'Project Modification Authorization', 'project_system'),
('PS_PRJ_REVIEW', 'Project Review Authorization', 'project_system'),
('PS_WBS_CREATE', 'WBS Creation Authorization', 'project_system'),
('PS_WBS_MODIFY', 'WBS Modification Authorization', 'project_system'),

-- MM - Materials Management
('MM_PO_CREATE', 'Purchase Order Creation Authorization', 'materials_mgmt'),
('MM_PO_APPROVE', 'Purchase Order Approval Authorization', 'materials_mgmt'),
('MM_PO_MODIFY', 'Purchase Order Modification Authorization', 'materials_mgmt'),
('MM_GRN_EXECUTE', 'Goods Receipt Execution Authorization', 'materials_mgmt'),
('MM_MAT_MASTER', 'Material Master Authorization', 'materials_mgmt'),
('MM_VEN_MANAGE', 'Vendor Management Authorization', 'materials_mgmt'),

-- PP - Production Planning
('PP_ACT_SCHEDULE', 'Activity Scheduling Authorization', 'production_planning'),
('PP_ACT_EXECUTE', 'Activity Execution Authorization', 'production_planning'),
('PP_TSK_ASSIGN', 'Task Assignment Authorization', 'production_planning'),
('PP_TSK_UPDATE', 'Task Update Authorization', 'production_planning'),
('PP_TSK_APPROVE', 'Task Approval Authorization', 'production_planning'),

-- QM - Quality Management
('QM_BOQ_REVIEW', 'BOQ Review Authorization', 'quality_mgmt'),
('QM_BOQ_MODIFY', 'BOQ Modification Authorization', 'quality_mgmt'),
('QM_QC_EXECUTE', 'Quality Control Execution Authorization', 'quality_mgmt'),
('QM_QC_APPROVE', 'Quality Control Approval Authorization', 'quality_mgmt'),

-- FI - Financial Accounting
('FI_CST_REVIEW', 'Cost Review Authorization', 'financial_accounting'),
('FI_CST_APPROVE', 'Cost Approval Authorization', 'financial_accounting'),
('FI_INV_PROCESS', 'Invoice Processing Authorization', 'financial_accounting'),

-- CO - Controlling
('CO_BDG_MODIFY', 'Budget Modification Authorization', 'controlling'),
('CO_CTC_ANALYZE', 'Cost-to-Complete Analysis Authorization', 'controlling'),
('CO_RPT_EXECUTE', 'Reporting Execution Authorization', 'controlling'),

-- HR - Human Resources
('HR_TMS_EXECUTE', 'Timesheet Execution Authorization', 'human_resources'),
('HR_TMS_APPROVE', 'Timesheet Approval Authorization', 'human_resources'),
('HR_EMP_MANAGE', 'Employee Management Authorization', 'human_resources'),

-- WM - Warehouse Management
('WM_STK_REVIEW', 'Stock Review Authorization', 'warehouse_mgmt'),
('WM_STK_TRANSFER', 'Stock Transfer Authorization', 'warehouse_mgmt'),
('WM_STR_MANAGE', 'Store Management Authorization', 'warehouse_mgmt'),

-- SY - System Administration
('SY_USR_MANAGE', 'User Management Authorization', 'system'),
('SY_ROL_MANAGE', 'Role Management Authorization', 'system'),
('SY_USR_ASSIGN', 'User Role Assignment Authorization', 'system')
ON CONFLICT (object_name) DO NOTHING;

-- Step 4: Authorization Fields
-- ============================

-- Add authorization fields for all objects
INSERT INTO authorization_fields (auth_object_id, field_name, field_description, field_values)
SELECT ao.id, 'ACTION', 'Construction Action', 
    CASE ao.module
        WHEN 'project_system' THEN ARRAY['INITIATE', 'MODIFY', 'REVIEW', 'APPROVE']
        WHEN 'materials_mgmt' THEN ARRAY['CREATE', 'MODIFY', 'APPROVE', 'EXECUTE', 'REVIEW']
        WHEN 'production_planning' THEN ARRAY['SCHEDULE', 'EXECUTE', 'ASSIGN', 'UPDATE', 'APPROVE']
        WHEN 'quality_mgmt' THEN ARRAY['REVIEW', 'MODIFY', 'EXECUTE', 'APPROVE']
        WHEN 'financial_accounting' THEN ARRAY['REVIEW', 'APPROVE', 'PROCESS']
        WHEN 'controlling' THEN ARRAY['MODIFY', 'ANALYZE', 'EXECUTE']
        WHEN 'human_resources' THEN ARRAY['EXECUTE', 'APPROVE', 'MANAGE']
        WHEN 'warehouse_mgmt' THEN ARRAY['REVIEW', 'TRANSFER', 'MANAGE']
        WHEN 'system' THEN ARRAY['CREATE', 'MODIFY', 'DELETE', 'ASSIGN']
        ELSE ARRAY['EXECUTE']
    END
FROM authorization_objects ao
WHERE NOT EXISTS (
    SELECT 1 FROM authorization_fields af 
    WHERE af.auth_object_id = ao.id AND af.field_name = 'ACTION'
);

-- Step 5: Roles and Authorization Mapping
-- =======================================

INSERT INTO roles (name, description) VALUES
('Admin', 'System Administrator with full access'),
('Manager', 'Project Manager with project oversight'),
('Engineer', 'Site Engineer with technical responsibilities'),
('Procurement', 'Procurement specialist for purchasing'),
('Finance', 'Finance team member for cost management'),
('HR', 'Human Resources for employee management'),
('Storekeeper', 'Warehouse and inventory management'),
('Employee', 'General employee with basic access')
ON CONFLICT (name) DO NOTHING;

-- Admin role mappings (full access)
INSERT INTO role_authorization_mapping (role_name, auth_object_name, field_values) VALUES
-- Project System
('Admin', 'PS_PRJ_INITIATE', '{"ACTION": ["INITIATE", "MODIFY", "REVIEW", "APPROVE"]}'::jsonb),
('Admin', 'PS_PRJ_MODIFY', '{"ACTION": ["MODIFY", "REVIEW", "APPROVE"]}'::jsonb),
('Admin', 'PS_PRJ_REVIEW', '{"ACTION": ["REVIEW"]}'::jsonb),
('Admin', 'PS_WBS_CREATE', '{"ACTION": ["INITIATE", "MODIFY", "REVIEW"]}'::jsonb),
('Admin', 'PS_WBS_MODIFY', '{"ACTION": ["MODIFY", "REVIEW"]}'::jsonb),

-- Materials Management
('Admin', 'MM_PO_CREATE', '{"ACTION": ["CREATE", "MODIFY", "REVIEW"]}'::jsonb),
('Admin', 'MM_PO_APPROVE', '{"ACTION": ["APPROVE", "REVIEW"]}'::jsonb),
('Admin', 'MM_PO_MODIFY', '{"ACTION": ["MODIFY", "REVIEW"]}'::jsonb),
('Admin', 'MM_GRN_EXECUTE', '{"ACTION": ["EXECUTE", "REVIEW"]}'::jsonb),
('Admin', 'MM_MAT_MASTER', '{"ACTION": ["CREATE", "MODIFY", "REVIEW"]}'::jsonb),
('Admin', 'MM_VEN_MANAGE', '{"ACTION": ["CREATE", "MODIFY", "REVIEW"]}'::jsonb),

-- Production Planning
('Admin', 'PP_ACT_SCHEDULE', '{"ACTION": ["SCHEDULE", "EXECUTE", "REVIEW"]}'::jsonb),
('Admin', 'PP_ACT_EXECUTE', '{"ACTION": ["EXECUTE", "REVIEW"]}'::jsonb),
('Admin', 'PP_TSK_ASSIGN', '{"ACTION": ["ASSIGN", "UPDATE", "REVIEW"]}'::jsonb),
('Admin', 'PP_TSK_UPDATE', '{"ACTION": ["UPDATE", "REVIEW"]}'::jsonb),
('Admin', 'PP_TSK_APPROVE', '{"ACTION": ["APPROVE", "REVIEW"]}'::jsonb),

-- Quality Management
('Admin', 'QM_BOQ_REVIEW', '{"ACTION": ["REVIEW"]}'::jsonb),
('Admin', 'QM_BOQ_MODIFY', '{"ACTION": ["MODIFY", "REVIEW"]}'::jsonb),
('Admin', 'QM_QC_EXECUTE', '{"ACTION": ["EXECUTE", "REVIEW"]}'::jsonb),
('Admin', 'QM_QC_APPROVE', '{"ACTION": ["APPROVE", "REVIEW"]}'::jsonb),

-- Financial
('Admin', 'FI_CST_REVIEW', '{"ACTION": ["REVIEW"]}'::jsonb),
('Admin', 'FI_CST_APPROVE', '{"ACTION": ["APPROVE", "REVIEW"]}'::jsonb),
('Admin', 'FI_INV_PROCESS', '{"ACTION": ["PROCESS", "REVIEW"]}'::jsonb),
('Admin', 'CO_BDG_MODIFY', '{"ACTION": ["MODIFY", "REVIEW"]}'::jsonb),
('Admin', 'CO_CTC_ANALYZE', '{"ACTION": ["ANALYZE", "REVIEW"]}'::jsonb),
('Admin', 'CO_RPT_EXECUTE', '{"ACTION": ["EXECUTE"]}'::jsonb),

-- Human Resources
('Admin', 'HR_TMS_EXECUTE', '{"ACTION": ["EXECUTE", "REVIEW"]}'::jsonb),
('Admin', 'HR_TMS_APPROVE', '{"ACTION": ["APPROVE", "REVIEW"]}'::jsonb),
('Admin', 'HR_EMP_MANAGE', '{"ACTION": ["MANAGE", "REVIEW"]}'::jsonb),

-- Warehouse Management
('Admin', 'WM_STK_REVIEW', '{"ACTION": ["REVIEW"]}'::jsonb),
('Admin', 'WM_STK_TRANSFER', '{"ACTION": ["TRANSFER", "REVIEW"]}'::jsonb),
('Admin', 'WM_STR_MANAGE', '{"ACTION": ["MANAGE", "REVIEW"]}'::jsonb),

-- System Administration
('Admin', 'SY_USR_MANAGE', '{"ACTION": ["CREATE", "MODIFY", "DELETE"]}'::jsonb),
('Admin', 'SY_ROL_MANAGE', '{"ACTION": ["CREATE", "MODIFY", "DELETE"]}'::jsonb),
('Admin', 'SY_USR_ASSIGN', '{"ACTION": ["ASSIGN", "MODIFY"]}'::jsonb)
ON CONFLICT (role_name, auth_object_name) DO NOTHING;

-- Step 6: Authorization Functions
-- ===============================

-- Function to check construction authorization
CREATE OR REPLACE FUNCTION check_construction_authorization(
    p_user_id UUID,
    p_auth_object VARCHAR(20),
    p_action VARCHAR(20),
    p_context JSONB DEFAULT '{}'
) RETURNS BOOLEAN AS $$
DECLARE
    v_has_auth BOOLEAN := false;
    v_auth_record RECORD;
BEGIN
    -- Check user authorizations
    SELECT ua.field_values INTO v_auth_record
    FROM user_authorizations ua
    WHERE ua.user_id = p_user_id 
    AND ua.auth_object_name = p_auth_object
    AND ua.is_active = true
    AND (ua.expires_at IS NULL OR ua.expires_at > NOW());
    
    IF FOUND THEN
        -- Check if user has the required action
        IF v_auth_record.field_values ? 'ACTION' THEN
            SELECT p_action = ANY(
                SELECT jsonb_array_elements_text(v_auth_record.field_values->'ACTION')
            ) INTO v_has_auth;
        END IF;
    END IF;
    
    RETURN COALESCE(v_has_auth, false);
END;
$$ LANGUAGE plpgsql;

-- Function to assign role authorizations to user
CREATE OR REPLACE FUNCTION assign_role_authorizations(
    p_user_id UUID,
    p_role_name VARCHAR(50)
) RETURNS VOID AS $$
BEGIN
    -- Delete existing authorizations for this user
    DELETE FROM user_authorizations WHERE user_id = p_user_id;
    
    -- Insert authorizations from role mapping
    INSERT INTO user_authorizations (user_id, auth_object_name, field_values, granted_by)
    SELECT 
        p_user_id,
        ram.auth_object_name,
        ram.field_values,
        p_user_id -- Self-assigned through role
    FROM role_authorization_mapping ram
    WHERE ram.role_name = p_role_name;
    
    -- Assign user to role
    INSERT INTO user_roles (user_id, role_name, assigned_by)
    VALUES (p_user_id, p_role_name, p_user_id)
    ON CONFLICT (user_id, role_name) DO UPDATE SET
        assigned_at = NOW(),
        is_active = true;
END;
$$ LANGUAGE plpgsql;

-- Step 7: Enhanced Tiles with Admin Management
-- ============================================

-- Insert Construction Module Tiles
INSERT INTO tiles (title, subtitle, icon, color, route, roles, sequence_order, auth_object, construction_action, module_code, tile_category) VALUES

-- PS - Project System Tiles
('Projects Dashboard', 'View all projects', 'building-2', 'bg-blue-500', '/projects', '{admin,manager}', 10, 'PS_PRJ_REVIEW', 'REVIEW', 'PS', 'Project Management'),
('Create Project', 'Start new project', 'plus-circle', 'bg-green-500', '/projects/create', '{admin,manager}', 11, 'PS_PRJ_INITIATE', 'INITIATE', 'PS', 'Project Management'),
('Modify Projects', 'Edit project details', 'edit-3', 'bg-blue-600', '/projects/edit', '{admin,manager}', 12, 'PS_PRJ_MODIFY', 'MODIFY', 'PS', 'Project Management'),
('WBS Management', 'Work breakdown structure', 'git-branch', 'bg-purple-500', '/wbs', '{admin,manager}', 13, 'PS_WBS_CREATE', 'INITIATE', 'PS', 'Project Management'),

-- MM - Materials Management Tiles  
('Purchase Orders', 'Manage purchase orders', 'shopping-cart', 'bg-orange-500', '/purchase-orders', '{admin,procurement}', 20, 'MM_PO_CREATE', 'CREATE', 'MM', 'Procurement'),
('PO Approvals', 'Approve purchase orders', 'check-circle', 'bg-green-600', '/purchase-orders/approve', '{admin,manager,finance}', 21, 'MM_PO_APPROVE', 'APPROVE', 'MM', 'Procurement'),
('Goods Receipt', 'Process material receipts', 'package-check', 'bg-teal-500', '/inventory/grn', '{admin,storekeeper}', 22, 'MM_GRN_EXECUTE', 'EXECUTE', 'MM', 'Materials'),
('Material Master', 'Maintain materials', 'box', 'bg-indigo-500', '/materials', '{admin,procurement}', 23, 'MM_MAT_MASTER', 'MODIFY', 'MM', 'Materials'),
('Vendor Management', 'Manage suppliers', 'users', 'bg-cyan-500', '/vendors', '{admin,procurement}', 24, 'MM_VEN_MANAGE', 'MODIFY', 'MM', 'Procurement'),

-- PP - Production Planning Tiles
('Activity Scheduler', 'Schedule work activities', 'calendar', 'bg-violet-500', '/activities/schedule', '{admin,manager}', 30, 'PP_ACT_SCHEDULE', 'SCHEDULE', 'PP', 'Planning'),
('Activity Execution', 'Execute work activities', 'play-circle', 'bg-emerald-500', '/activities/execute', '{admin,engineer}', 31, 'PP_ACT_EXECUTE', 'EXECUTE', 'PP', 'Execution'),
('Task Assignment', 'Assign tasks to workers', 'user-check', 'bg-amber-500', '/tasks/assign', '{admin,manager}', 32, 'PP_TSK_ASSIGN', 'ASSIGN', 'PP', 'Planning'),
('Progress Update', 'Update task progress', 'trending-up', 'bg-lime-500', '/tasks/progress', '{admin,engineer,employee}', 33, 'PP_TSK_UPDATE', 'UPDATE', 'PP', 'Execution'),

-- QM - Quality Management Tiles
('BOQ Review', 'Review quantities', 'file-text', 'bg-slate-500', '/boq', '{admin,engineer}', 40, 'QM_BOQ_REVIEW', 'REVIEW', 'QM', 'Quality'),
('BOQ Modification', 'Modify quantities', 'edit', 'bg-gray-600', '/boq/edit', '{admin}', 41, 'QM_BOQ_MODIFY', 'MODIFY', 'QM', 'Quality'),
('Quality Control', 'Quality inspections', 'shield-check', 'bg-red-500', '/quality', '{admin}', 42, 'QM_QC_EXECUTE', 'EXECUTE', 'QM', 'Quality'),

-- FI/CO - Financial Tiles
('Cost Review', 'Review project costs', 'dollar-sign', 'bg-green-700', '/finance/costs', '{admin,finance}', 50, 'FI_CST_REVIEW', 'REVIEW', 'FI', 'Finance'),
('Budget Management', 'Manage project budgets', 'pie-chart', 'bg-blue-700', '/finance/budget', '{admin,finance}', 51, 'CO_BDG_MODIFY', 'MODIFY', 'CO', 'Finance'),
('Cost Analysis', 'Cost-to-complete analysis', 'bar-chart-3', 'bg-purple-700', '/finance/ctc', '{admin,manager,finance}', 52, 'CO_CTC_ANALYZE', 'ANALYZE', 'CO', 'Finance'),

-- HR - Human Resources Tiles
('Timesheet Entry', 'Log work hours', 'clock', 'bg-indigo-600', '/timesheets', '{admin,engineer,employee}', 60, 'HR_TMS_EXECUTE', 'EXECUTE', 'HR', 'Time Management'),
('Timesheet Approval', 'Approve work hours', 'check-square', 'bg-green-800', '/timesheets/approve', '{admin,manager,hr}', 61, 'HR_TMS_APPROVE', 'APPROVE', 'HR', 'Time Management'),
('Employee Management', 'Manage workforce', 'user-cog', 'bg-gray-700', '/employees', '{admin,hr}', 62, 'HR_EMP_MANAGE', 'MANAGE', 'HR', 'Human Resources'),

-- WM - Warehouse Management Tiles
('Stock Review', 'View inventory levels', 'package', 'bg-teal-600', '/inventory', '{admin,storekeeper}', 70, 'WM_STK_REVIEW', 'REVIEW', 'WM', 'Warehouse'),
('Stock Transfer', 'Transfer materials', 'truck', 'bg-orange-600', '/inventory/transfer', '{admin,storekeeper}', 71, 'WM_STK_TRANSFER', 'TRANSFER', 'WM', 'Warehouse'),
('Store Management', 'Manage warehouses', 'warehouse', 'bg-stone-600', '/stores', '{admin,storekeeper}', 72, 'WM_STR_MANAGE', 'MANAGE', 'WM', 'Warehouse'),

-- SY - Administration Tiles
('User Management', 'Create, modify, and manage users', 'users', 'bg-blue-600', '#', '{admin}', 90, 'SY_USR_MANAGE', 'MODIFY', 'SY', 'Administration'),
('Role Management', 'Create roles and assign authorization objects', 'shield', 'bg-purple-600', '#', '{admin}', 91, 'SY_ROL_MANAGE', 'MODIFY', 'SY', 'Administration'),
('User Role Assignment', 'Assign users to roles', 'user-check', 'bg-green-600', '#', '{admin}', 92, 'SY_USR_ASSIGN', 'MODIFY', 'SY', 'Administration');

-- Step 8: Tile Functions
-- ======================

-- Function to get authorized tiles for user
CREATE OR REPLACE FUNCTION get_user_authorized_tiles(p_user_id UUID)
RETURNS TABLE (
    tile_id UUID,
    title VARCHAR(100),
    subtitle VARCHAR(200),
    icon VARCHAR(50),
    color VARCHAR(20),
    route VARCHAR(200),
    module_code VARCHAR(2),
    tile_category VARCHAR(50),
    construction_action VARCHAR(20),
    has_authorization BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        t.id,
        t.title,
        t.subtitle,
        t.icon,
        t.color,
        t.route,
        t.module_code,
        t.tile_category,
        t.construction_action,
        CASE 
            WHEN t.auth_object IS NOT NULL THEN
                check_construction_authorization(
                    p_user_id,
                    t.auth_object,
                    t.construction_action,
                    '{}'::jsonb
                )
            ELSE true
        END as has_authorization
    FROM tiles t
    WHERE t.is_active = true
    ORDER BY t.module_code, t.sequence_order;
END;
$$ LANGUAGE plpgsql;

-- Step 9: Setup Admin User
-- ========================

-- Assign Admin role to the admin user
DO $$
BEGIN
    PERFORM assign_role_authorizations('70f8baa8-27b8-4061-84c4-6dd027d6b89f', 'Admin');
    RAISE NOTICE 'Admin user configured with full authorizations';
END $$;

-- Verification queries
SELECT 'AUTHORIZATION OBJECTS' as status, COUNT(*) as count FROM authorization_objects;
SELECT 'TILES CREATED' as status, COUNT(*) as count FROM tiles;
SELECT 'ADMIN AUTHORIZATIONS' as status, COUNT(*) as count FROM user_authorizations WHERE user_id = '70f8baa8-27b8-4061-84c4-6dd027d6b89f';