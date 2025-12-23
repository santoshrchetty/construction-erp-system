-- Inter-company Transactions for Sister Companies
-- Handles material transfers, service billing, equipment rental

-- Inter-company Purchase Orders (Sister company work)
CREATE TABLE inter_company_pos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_number VARCHAR(50) UNIQUE NOT NULL,
    ordering_company_id UUID NOT NULL REFERENCES company_codes(id),
    supplying_company_id UUID NOT NULL REFERENCES company_codes(id),
    project_id UUID NOT NULL REFERENCES projects(id),
    po_type VARCHAR(20) DEFAULT 'SERVICE', -- SERVICE, MATERIAL, EQUIPMENT
    total_amount DECIMAL(15,2) NOT NULL,
    transfer_price_method VARCHAR(50) DEFAULT 'COST_PLUS_MARGIN',
    status VARCHAR(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Material Transfers between companies
CREATE TABLE inter_company_transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transfer_number VARCHAR(50) UNIQUE NOT NULL,
    from_company_id UUID NOT NULL REFERENCES company_codes(id),
    to_company_id UUID NOT NULL REFERENCES company_codes(id),
    from_plant_id UUID NOT NULL REFERENCES plants(id),
    to_plant_id UUID NOT NULL REFERENCES plants(id),
    transfer_date DATE NOT NULL,
    total_value DECIMAL(15,2) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'IN_TRANSIT',
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Transfer line items
CREATE TABLE inter_company_transfer_lines (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transfer_id UUID NOT NULL REFERENCES inter_company_transfers(id),
    stock_item_id UUID NOT NULL REFERENCES stock_items(id),
    quantity DECIMAL(15,4) NOT NULL,
    transfer_price DECIMAL(15,2) NOT NULL,
    line_value DECIMAL(15,2) GENERATED ALWAYS AS (quantity * transfer_price) STORED
);

-- Update purchase orders to support inter-company
ALTER TABLE purchase_orders 
ADD COLUMN IF NOT EXISTS is_inter_company BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS supplying_company_id UUID REFERENCES company_codes(id);

-- Update vendors to include sister companies
ALTER TABLE vendors
ADD COLUMN IF NOT EXISTS company_code_id UUID REFERENCES company_codes(id),
ADD COLUMN IF NOT EXISTS is_inter_company BOOLEAN DEFAULT false;

-- View for sister company vendors
CREATE OR REPLACE VIEW sister_company_vendors AS
SELECT v.*, cc.company_name, cc.company_code
FROM vendors v
JOIN company_codes cc ON v.company_code_id = cc.id
WHERE v.is_inter_company = true;

-- Consolidated reporting view across companies
CREATE OR REPLACE VIEW consolidated_project_costs AS
SELECT 
    p.id as project_id,
    p.name as project_name,
    cc.company_code,
    cc.company_name,
    SUM(ac.amount) as total_cost,
    ac.cost_type
FROM projects p
JOIN company_codes cc ON p.company_code_id = cc.id
JOIN actual_costs ac ON ac.project_id = p.id
GROUP BY p.id, p.name, cc.company_code, cc.company_name, ac.cost_type;