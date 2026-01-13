-- STEP 5: MINIMAL SAP ACCOUNT ASSIGNMENT

-- Add account assignment fields to purchase_order_items
ALTER TABLE purchase_order_items
ADD COLUMN IF NOT EXISTS account_assignment_category VARCHAR(1), -- K=Cost Center, P=Project, A=Asset, O=Order
ADD COLUMN IF NOT EXISTS account_assignment_object VARCHAR(20),
ADD COLUMN IF NOT EXISTS profit_center VARCHAR(10);

-- Account Assignment Categories
CREATE TABLE IF NOT EXISTS account_assignment_categories (
    category_code VARCHAR(1) PRIMARY KEY,
    category_name VARCHAR(50),
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

INSERT INTO account_assignment_categories VALUES
('K', 'Cost Center', 'Cost Center Assignment', true),
('P', 'Project/WBS', 'Project or WBS Element Assignment', true),
('A', 'Asset', 'Fixed Asset Assignment', true),
('O', 'Internal Order', 'Internal Order Assignment', true)
ON CONFLICT (category_code) DO NOTHING;

-- Cost Centers master
CREATE TABLE IF NOT EXISTS cost_centers (
    cost_center VARCHAR(10) PRIMARY KEY,
    cost_center_name VARCHAR(50),
    company_code VARCHAR(4) DEFAULT 'C001',
    is_active BOOLEAN DEFAULT true
);

-- Internal Orders master  
CREATE TABLE IF NOT EXISTS internal_orders (
    order_number VARCHAR(12) PRIMARY KEY,
    order_description VARCHAR(50),
    cost_center VARCHAR(10),
    company_code VARCHAR(4) DEFAULT 'C001',
    is_active BOOLEAN DEFAULT true
);

-- Assets master
CREATE TABLE IF NOT EXISTS fixed_assets (
    asset_number VARCHAR(12) PRIMARY KEY,
    asset_description VARCHAR(50),
    company_code VARCHAR(4) DEFAULT 'C001',
    is_active BOOLEAN DEFAULT true
);

-- Profit Centers master
CREATE TABLE IF NOT EXISTS profit_centers (
    profit_center VARCHAR(10) PRIMARY KEY,
    profit_center_name VARCHAR(50),
    company_code VARCHAR(4) DEFAULT 'C001',
    is_active BOOLEAN DEFAULT true
);

SELECT 'STEP 5 COMPLETE - SAP ACCOUNT ASSIGNMENT' as status;