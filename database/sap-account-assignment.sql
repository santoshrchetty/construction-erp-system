-- SAP-STYLE ACCOUNT ASSIGNMENT FOR PO LINE ITEMS

-- Add account assignment fields to purchase_order_items
ALTER TABLE purchase_order_items
ADD COLUMN IF NOT EXISTS account_assignment_category VARCHAR(1), -- K=Cost Center, P=Project, A=Asset, O=Order
ADD COLUMN IF NOT EXISTS account_assignment_object VARCHAR(20),
ADD COLUMN IF NOT EXISTS profit_center VARCHAR(10);

-- Account Assignment Categories master data
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

-- Cost Centers master data
CREATE TABLE IF NOT EXISTS cost_centers (
    cost_center VARCHAR(10) PRIMARY KEY,
    cost_center_name VARCHAR(50),
    company_code VARCHAR(4),
    controlling_area VARCHAR(4),
    person_responsible VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE DEFAULT '9999-12-31'
);

-- Internal Orders master data  
CREATE TABLE IF NOT EXISTS internal_orders (
    order_number VARCHAR(12) PRIMARY KEY,
    order_type VARCHAR(4),
    order_description VARCHAR(50),
    responsible_person VARCHAR(50),
    cost_center VARCHAR(10),
    company_code VARCHAR(4),
    status VARCHAR(4) DEFAULT 'REL',
    is_active BOOLEAN DEFAULT true,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE DEFAULT '9999-12-31'
);

-- Assets master data
CREATE TABLE IF NOT EXISTS fixed_assets (
    asset_number VARCHAR(12) PRIMARY KEY,
    sub_number VARCHAR(4) DEFAULT '0000',
    asset_description VARCHAR(50),
    asset_class VARCHAR(8),
    company_code VARCHAR(4),
    cost_center VARCHAR(10),
    location VARCHAR(50),
    acquisition_date DATE,
    is_active BOOLEAN DEFAULT true
);

-- Profit Centers master data
CREATE TABLE IF NOT EXISTS profit_centers (
    profit_center VARCHAR(10) PRIMARY KEY,
    profit_center_name VARCHAR(50),
    company_code VARCHAR(4),
    controlling_area VARCHAR(4),
    person_responsible VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE DEFAULT '9999-12-31'
);

-- Account Assignment validation function
CREATE OR REPLACE FUNCTION validate_account_assignment(
    p_category VARCHAR(1),
    p_object VARCHAR(20),
    p_company_code VARCHAR(4)
) RETURNS BOOLEAN AS $$
BEGIN
    CASE p_category
        WHEN 'K' THEN -- Cost Center
            RETURN EXISTS (
                SELECT 1 FROM cost_centers 
                WHERE cost_center = p_object 
                AND company_code = p_company_code 
                AND is_active = true
                AND CURRENT_DATE BETWEEN valid_from AND valid_to
            );
        WHEN 'P' THEN -- Project/WBS
            RETURN EXISTS (
                SELECT 1 FROM wbs_nodes 
                WHERE wbs_element = p_object 
                AND is_active = true
            );
        WHEN 'A' THEN -- Asset
            RETURN EXISTS (
                SELECT 1 FROM fixed_assets 
                WHERE asset_number = p_object 
                AND company_code = p_company_code 
                AND is_active = true
            );
        WHEN 'O' THEN -- Internal Order
            RETURN EXISTS (
                SELECT 1 FROM internal_orders 
                WHERE order_number = p_object 
                AND company_code = p_company_code 
                AND is_active = true
                AND CURRENT_DATE BETWEEN valid_from AND valid_to
            );
        ELSE
            RETURN false;
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Sample data for testing
INSERT INTO cost_centers VALUES
('CC001', 'Construction Operations', 'C001', 'CA01', 'John Manager', true, CURRENT_DATE, '9999-12-31'),
('CC002', 'Procurement Department', 'C001', 'CA01', 'Jane Supervisor', true, CURRENT_DATE, '9999-12-31')
ON CONFLICT (cost_center) DO NOTHING;

INSERT INTO internal_orders VALUES
('IO001001', 'CONS', 'Building Construction Project', 'Project Manager', 'CC001', 'C001', 'REL', true, CURRENT_DATE, '9999-12-31'),
('IO002001', 'MAINT', 'Equipment Maintenance', 'Maintenance Head', 'CC002', 'C001', 'REL', true, CURRENT_DATE, '9999-12-31')
ON CONFLICT (order_number) DO NOTHING;

INSERT INTO profit_centers VALUES
('PC001', 'Construction Division', 'C001', 'CA01', 'Division Head', true, CURRENT_DATE, '9999-12-31'),
('PC002', 'Support Services', 'C001', 'CA01', 'Support Manager', true, CURRENT_DATE, '9999-12-31')
ON CONFLICT (profit_center) DO NOTHING;

SELECT 'SAP ACCOUNT ASSIGNMENT SCHEMA CREATED' as status;