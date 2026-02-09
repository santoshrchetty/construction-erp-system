-- Material Request System Database Schema
-- Updated to support all MR types and features discussed

-- Update material_requests table to include MR type and additional fields
ALTER TABLE material_requests 
ADD COLUMN IF NOT EXISTS mr_type VARCHAR(20) DEFAULT 'PROJECT' CHECK (mr_type IN ('PROJECT', 'MAINTENANCE', 'OFFICE', 'SAFETY', 'EQUIPMENT', 'GENERAL')),
ADD COLUMN IF NOT EXISTS department_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS delivery_location VARCHAR(50),
ADD COLUMN IF NOT EXISTS total_value DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'GBP',
ADD COLUMN IF NOT EXISTS approval_workflow_id VARCHAR(50),
ADD COLUMN IF NOT EXISTS approved_by VARCHAR(50),
ADD COLUMN IF NOT EXISTS approved_date TIMESTAMP,
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- Create material_request_items table for line items
CREATE TABLE IF NOT EXISTS material_request_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_request_id UUID NOT NULL REFERENCES material_requests(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    material_code VARCHAR(50) NOT NULL,
    material_description TEXT,
    quantity DECIMAL(15,3) NOT NULL,
    unit_of_measure VARCHAR(10) NOT NULL,
    standard_price DECIMAL(15,2),
    total_line_value DECIMAL(15,2),
    available_stock DECIMAL(15,3),
    reserved_quantity DECIMAL(15,3) DEFAULT 0,
    issued_quantity DECIMAL(15,3) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'RESERVED', 'PARTIALLY_ISSUED', 'FULLY_ISSUED', 'CANCELLED')),
    storage_location VARCHAR(50),
    batch_number VARCHAR(50),
    serial_number VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(material_request_id, line_number)
);

-- Create materials master table
CREATE TABLE IF NOT EXISTS materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_code VARCHAR(50) UNIQUE NOT NULL,
    material_description TEXT NOT NULL,
    material_type VARCHAR(20) NOT NULL CHECK (material_type IN ('RAW_MATERIAL', 'FINISHED_GOODS', 'SEMI_FINISHED', 'CONSUMABLE', 'SPARE_PARTS', 'TOOLS', 'PPE')),
    base_unit_of_measure VARCHAR(10) NOT NULL,
    standard_price DECIMAL(15,2),
    currency VARCHAR(3) DEFAULT 'GBP',
    valuation_method VARCHAR(20) DEFAULT 'MOVING_AVERAGE' CHECK (valuation_method IN ('STANDARD_PRICE', 'MOVING_AVERAGE', 'FIFO', 'LIFO')),
    procurement_type VARCHAR(20) DEFAULT 'PURCHASE' CHECK (procurement_type IN ('PURCHASE', 'MANUFACTURE', 'BOTH')),
    material_group VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL,
    updated_by VARCHAR(50)
);

-- Create inventory/stock table
CREATE TABLE IF NOT EXISTS inventory_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_code VARCHAR(50) NOT NULL REFERENCES materials(material_code),
    storage_location VARCHAR(50) NOT NULL,
    batch_number VARCHAR(50),
    quantity_on_hand DECIMAL(15,3) NOT NULL DEFAULT 0,
    quantity_reserved DECIMAL(15,3) NOT NULL DEFAULT 0,
    quantity_available DECIMAL(15,3) GENERATED ALWAYS AS (quantity_on_hand - quantity_reserved) STORED,
    unit_cost DECIMAL(15,2),
    total_value DECIMAL(15,2) GENERATED ALWAYS AS (quantity_on_hand * unit_cost) STORED,
    last_movement_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(material_code, storage_location, COALESCE(batch_number, ''))
);

-- Create reservations table
CREATE TABLE IF NOT EXISTS material_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_number VARCHAR(50) UNIQUE NOT NULL,
    material_request_id UUID NOT NULL REFERENCES material_requests(id),
    material_request_item_id UUID NOT NULL REFERENCES material_request_items(id),
    material_code VARCHAR(50) NOT NULL,
    storage_location VARCHAR(50) NOT NULL,
    reserved_quantity DECIMAL(15,3) NOT NULL,
    consumed_quantity DECIMAL(15,3) DEFAULT 0,
    remaining_quantity DECIMAL(15,3) GENERATED ALWAYS AS (reserved_quantity - consumed_quantity) STORED,
    reservation_date TIMESTAMP NOT NULL,
    expiry_date TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'PARTIALLY_CONSUMED', 'FULLY_CONSUMED', 'EXPIRED', 'CANCELLED')),
    project_code VARCHAR(50),
    activity_code VARCHAR(50),
    cost_center VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL
);

-- Create departments table
CREATE TABLE IF NOT EXISTS departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    department_code VARCHAR(20) UNIQUE NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    description TEXT,
    cost_center VARCHAR(20),
    manager_id VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create cost centers table
CREATE TABLE IF NOT EXISTS cost_centers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cost_center_code VARCHAR(20) UNIQUE NOT NULL,
    cost_center_name VARCHAR(100) NOT NULL,
    description TEXT,
    department_code VARCHAR(20) REFERENCES departments(department_code),
    budget_amount DECIMAL(15,2),
    currency VARCHAR(3) DEFAULT 'GBP',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Storage locations table (updated to match actual schema)
CREATE TABLE IF NOT EXISTS storage_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plant_id UUID NOT NULL,
    sloc_code VARCHAR(31) NOT NULL,
    sloc_name VARCHAR(240) NOT NULL,
    location_type VARCHAR(20) DEFAULT 'WAREHOUSE' CHECK (location_type IN ('WAREHOUSE', 'SITE', 'YARD', 'OFFICE', 'VEHICLE')),
    is_active BOOLEAN DEFAULT true,
    plant_code VARCHAR(4),
    tenant_id UUID NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(plant_id, sloc_code)
);

-- Create material transfer orders table
CREATE TABLE IF NOT EXISTS material_transfer_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transfer_order_number VARCHAR(50) UNIQUE NOT NULL,
    material_request_id UUID REFERENCES material_requests(id),
    from_location VARCHAR(50) NOT NULL,
    to_location VARCHAR(50) NOT NULL,
    transfer_date TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'CREATED' CHECK (status IN ('CREATED', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED')),
    transport_cost DECIMAL(15,2) DEFAULT 0,
    handling_cost DECIMAL(15,2) DEFAULT 0,
    total_transfer_cost DECIMAL(15,2) GENERATED ALWAYS AS (transport_cost + handling_cost) STORED,
    vehicle_number VARCHAR(20),
    driver_name VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(50) NOT NULL
);

-- Create material transfer order items table
CREATE TABLE IF NOT EXISTS material_transfer_order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    transfer_order_id UUID NOT NULL REFERENCES material_transfer_orders(id) ON DELETE CASCADE,
    line_number INTEGER NOT NULL,
    material_code VARCHAR(50) NOT NULL,
    quantity DECIMAL(15,3) NOT NULL,
    unit_cost DECIMAL(15,2),
    transport_cost_per_unit DECIMAL(15,2) DEFAULT 0,
    handling_cost_per_unit DECIMAL(15,2) DEFAULT 0,
    total_landed_cost DECIMAL(15,2) GENERATED ALWAYS AS ((unit_cost + transport_cost_per_unit + handling_cost_per_unit) * quantity) STORED,
    batch_number VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(transfer_order_id, line_number)
);

-- Create approval workflow table
CREATE TABLE IF NOT EXISTS approval_workflows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_name VARCHAR(100) NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    mr_type VARCHAR(20),
    department_code VARCHAR(20),
    approval_levels INTEGER NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create approval workflow steps table
CREATE TABLE IF NOT EXISTS approval_workflow_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id UUID NOT NULL REFERENCES approval_workflows(id),
    step_number INTEGER NOT NULL,
    approver_role VARCHAR(50) NOT NULL,
    approver_id VARCHAR(50),
    is_mandatory BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(workflow_id, step_number)
);

-- Create approval history table
CREATE TABLE IF NOT EXISTS approval_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    step_number INTEGER NOT NULL,
    approver_id VARCHAR(50) NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('APPROVED', 'REJECTED', 'RETURNED')),
    comments TEXT,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data for departments
INSERT INTO departments (department_code, department_name, description, cost_center) VALUES
('MAINT', 'Maintenance', 'Equipment and facility maintenance', 'CC001'),
('ADMIN', 'Administration', 'Administrative operations', 'CC002'),
('HR', 'Human Resources', 'Human resources management', 'CC003'),
('SAFETY', 'Safety Department', 'Safety and compliance', 'CC004'),
('IT', 'IT Department', 'Information technology', 'CC005')
ON CONFLICT (department_code) DO NOTHING;

-- Insert sample data for cost centers
INSERT INTO cost_centers (cost_center_code, cost_center_name, description, department_code, budget_amount) VALUES
('CC001', 'General Maintenance', 'General maintenance activities', 'MAINT', 50000.00),
('CC002', 'Office Operations', 'Administrative office operations', 'ADMIN', 25000.00),
('CC003', 'Safety & Training', 'Safety programs and training', 'SAFETY', 30000.00),
('CC004', 'Equipment Maintenance', 'Equipment maintenance and repair', 'MAINT', 75000.00),
('CC005', 'IT Operations', 'IT infrastructure and support', 'IT', 40000.00)
ON CONFLICT (cost_center_code) DO NOTHING;

-- Insert sample data for storage locations
INSERT INTO storage_locations (location_code, location_name, location_type, address) VALUES
('SITE001', 'Site A - Main Warehouse', 'WAREHOUSE', 'Main construction site warehouse'),
('SITE002', 'Site B - Storage Area', 'SITE', 'Secondary site storage area'),
('SITE003', 'Site C - Laydown Area', 'YARD', 'Material laydown and staging area'),
('OFFICE001', 'Head Office Store', 'OFFICE', 'Head office supply store'),
('YARD001', 'Central Yard', 'YARD', 'Central material yard')
ON CONFLICT (location_code) DO NOTHING;

-- Insert sample materials
INSERT INTO materials (material_code, material_description, material_type, base_unit_of_measure, standard_price, material_group, created_by) VALUES
('MAT001', 'Cement - OPC 42.5 Grade', 'RAW_MATERIAL', 'TON', 50.00, 'CEMENT', 'SYSTEM'),
('MAT002', 'Steel Rebar - 16mm', 'RAW_MATERIAL', 'TON', 800.00, 'STEEL', 'SYSTEM'),
('MAT003', 'Concrete Aggregate', 'RAW_MATERIAL', 'TON', 25.00, 'AGGREGATE', 'SYSTEM'),
('PPE001', 'Safety Helmet', 'PPE', 'EA', 15.00, 'SAFETY', 'SYSTEM'),
('OFF001', 'A4 Paper Ream', 'CONSUMABLE', 'EA', 5.00, 'STATIONERY', 'SYSTEM')
ON CONFLICT (material_code) DO NOTHING;

-- Insert sample inventory
INSERT INTO inventory_stock (material_code, storage_location, quantity_on_hand, unit_cost) VALUES
('MAT001', 'SITE001', 150.000, 50.00),
('MAT002', 'SITE001', 25.000, 800.00),
('MAT003', 'SITE001', 200.000, 25.00),
('PPE001', 'OFFICE001', 100.000, 15.00),
('OFF001', 'OFFICE001', 50.000, 5.00)
ON CONFLICT (material_code, storage_location, COALESCE(batch_number, '')) DO NOTHING;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_material_requests_type ON material_requests(mr_type);
CREATE INDEX IF NOT EXISTS idx_material_requests_status ON material_requests(status);
CREATE INDEX IF NOT EXISTS idx_material_requests_project ON material_requests(project_code);
CREATE INDEX IF NOT EXISTS idx_material_request_items_material ON material_request_items(material_code);
CREATE INDEX IF NOT EXISTS idx_inventory_stock_material ON inventory_stock(material_code);
CREATE INDEX IF NOT EXISTS idx_inventory_stock_location ON inventory_stock(storage_location);
CREATE INDEX IF NOT EXISTS idx_reservations_material ON material_reservations(material_code);
CREATE INDEX IF NOT EXISTS idx_reservations_status ON material_reservations(status);