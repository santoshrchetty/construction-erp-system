-- Cost Elements Master Table (SAP CO Model)
-- Separate from GL Accounts for Cost Accounting purposes

CREATE TABLE IF NOT EXISTS cost_elements (
    -- Identity
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cost_element VARCHAR(20) UNIQUE NOT NULL,
    cost_element_name VARCHAR(100) NOT NULL,
    
    -- Classification
    cost_element_category VARCHAR(20) NOT NULL CHECK (
        cost_element_category IN ('PRIMARY_DIRECT', 'PRIMARY_INDIRECT', 'SECONDARY')
    ),
    cost_element_type VARCHAR(20) NOT NULL CHECK (
        cost_element_type IN ('MATERIAL', 'LABOR', 'EQUIPMENT', 'SUBCONTRACTOR', 
                              'OVERHEAD', 'ALLOCATION', 'SETTLEMENT', 'INTERNAL_ORDER')
    ),
    
    -- Cost Accounting Attributes
    is_direct_cost BOOLEAN DEFAULT false,
    is_primary_cost BOOLEAN DEFAULT true,
    is_secondary_cost BOOLEAN DEFAULT false,
    
    -- GL Integration (for primary cost elements only)
    gl_account VARCHAR(20),
    chart_of_accounts_id UUID,
    
    -- Allocation & Settlement
    allocation_allowed BOOLEAN DEFAULT false,
    settlement_allowed BOOLEAN DEFAULT false,
    default_allocation_basis VARCHAR(30) CHECK (
        default_allocation_basis IS NULL OR 
        default_allocation_basis IN ('LABOR_HOURS', 'MACHINE_HOURS', 'AREA', 'QUANTITY', 
                                     'DIRECT_COST', 'HEADCOUNT', 'ACTIVITY_QUANTITY')
    ),
    
    -- Activity-Based Costing
    activity_type VARCHAR(30),
    
    -- Variance Analysis
    variance_category VARCHAR(20) CHECK (
        variance_category IS NULL OR
        variance_category IN ('PRICE', 'QUANTITY', 'EFFICIENCY', 'OVERHEAD', 'RATE')
    ),
    
    -- Control
    is_active BOOLEAN DEFAULT true,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_to DATE,
    
    -- Audit
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    updated_by UUID,
    
    -- Business Rules
    CONSTRAINT chk_primary_has_gl CHECK (
        (is_primary_cost = false) OR (gl_account IS NOT NULL)
    ),
    CONSTRAINT chk_secondary_no_gl CHECK (
        (is_secondary_cost = false) OR (gl_account IS NULL)
    ),
    CONSTRAINT chk_valid_dates CHECK (valid_to IS NULL OR valid_to >= valid_from)
);

-- Indexes for Performance
CREATE INDEX idx_cost_elements_gl ON cost_elements(gl_account) WHERE gl_account IS NOT NULL;
CREATE INDEX idx_cost_elements_category ON cost_elements(cost_element_category);
CREATE INDEX idx_cost_elements_type ON cost_elements(cost_element_type);
CREATE INDEX idx_cost_elements_active ON cost_elements(is_active, valid_from, valid_to);
CREATE INDEX idx_cost_elements_direct ON cost_elements(is_direct_cost);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_cost_elements_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_cost_elements_timestamp
    BEFORE UPDATE ON cost_elements
    FOR EACH ROW
    EXECUTE FUNCTION update_cost_elements_timestamp();

-- Insert Primary Direct Cost Elements (1:1 with GL Accounts)
INSERT INTO cost_elements (
    cost_element, cost_element_name, cost_element_category, 
    cost_element_type, is_direct_cost, is_primary_cost, gl_account
) VALUES
-- Direct Materials
('500000', 'Direct Materials', 'PRIMARY_DIRECT', 'MATERIAL', true, true, '500000'),
('501000', 'Cement & Concrete', 'PRIMARY_DIRECT', 'MATERIAL', true, true, '501000'),
('502000', 'Steel & Reinforcement', 'PRIMARY_DIRECT', 'MATERIAL', true, true, '502000'),
('503000', 'Electrical Materials', 'PRIMARY_DIRECT', 'MATERIAL', true, true, '503000'),
('504000', 'Plumbing Materials', 'PRIMARY_DIRECT', 'MATERIAL', true, true, '504000'),
('505000', 'Finishing Materials', 'PRIMARY_DIRECT', 'MATERIAL', true, true, '505000'),

-- Direct Labor
('510000', 'Direct Labor', 'PRIMARY_DIRECT', 'LABOR', true, true, '510000'),
('511000', 'Skilled Labor', 'PRIMARY_DIRECT', 'LABOR', true, true, '511000'),
('512000', 'Unskilled Labor', 'PRIMARY_DIRECT', 'LABOR', true, true, '512000'),
('513000', 'Overtime Costs', 'PRIMARY_DIRECT', 'LABOR', true, true, '513000'),

-- Subcontractors
('520000', 'Subcontractor Costs', 'PRIMARY_DIRECT', 'SUBCONTRACTOR', true, true, '520000'),
('521000', 'Civil Subcontractors', 'PRIMARY_DIRECT', 'SUBCONTRACTOR', true, true, '521000'),
('522000', 'MEP Subcontractors', 'PRIMARY_DIRECT', 'SUBCONTRACTOR', true, true, '522000'),
('523000', 'Finishing Subcontractors', 'PRIMARY_DIRECT', 'SUBCONTRACTOR', true, true, '523000'),

-- Equipment
('530000', 'Equipment Costs', 'PRIMARY_DIRECT', 'EQUIPMENT', true, true, '530000'),
('531000', 'Equipment Rental', 'PRIMARY_DIRECT', 'EQUIPMENT', true, true, '531000'),
('532000', 'Equipment Fuel', 'PRIMARY_DIRECT', 'EQUIPMENT', true, true, '532000'),
('533000', 'Equipment Maintenance', 'PRIMARY_DIRECT', 'EQUIPMENT', true, true, '533000')

ON CONFLICT (cost_element) DO NOTHING;

-- Insert Primary Indirect Cost Elements (1:1 with GL Accounts)
INSERT INTO cost_elements (
    cost_element, cost_element_name, cost_element_category, 
    cost_element_type, is_direct_cost, is_primary_cost, gl_account
) VALUES
-- Site Overhead
('600000', 'Site Overhead', 'PRIMARY_INDIRECT', 'OVERHEAD', false, true, '600000'),
('601000', 'Site Office Expenses', 'PRIMARY_INDIRECT', 'OVERHEAD', false, true, '601000'),
('602000', 'Site Utilities', 'PRIMARY_INDIRECT', 'OVERHEAD', false, true, '602000'),
('603000', 'Site Security', 'PRIMARY_INDIRECT', 'OVERHEAD', false, true, '603000'),
('604000', 'Site Insurance', 'PRIMARY_INDIRECT', 'OVERHEAD', false, true, '604000'),

-- Project Management
('610000', 'Project Management', 'PRIMARY_INDIRECT', 'OVERHEAD', false, true, '610000'),
('611000', 'Project Staff Salaries', 'PRIMARY_INDIRECT', 'OVERHEAD', false, true, '611000'),
('612000', 'Project Consultancy', 'PRIMARY_INDIRECT', 'OVERHEAD', false, true, '612000'),

-- General Overhead
('620000', 'General Admin Overhead', 'PRIMARY_INDIRECT', 'OVERHEAD', false, true, '620000'),
('621000', 'Head Office Expenses', 'PRIMARY_INDIRECT', 'OVERHEAD', false, true, '621000'),
('622000', 'Marketing Expenses', 'PRIMARY_INDIRECT', 'OVERHEAD', false, true, '622000'),
('623000', 'Finance Costs', 'PRIMARY_INDIRECT', 'OVERHEAD', false, true, '623000')

ON CONFLICT (cost_element) DO NOTHING;

-- Insert Secondary Cost Elements (CO-only, no GL Account)
INSERT INTO cost_elements (
    cost_element, cost_element_name, cost_element_category, 
    cost_element_type, is_direct_cost, is_primary_cost, is_secondary_cost,
    allocation_allowed, default_allocation_basis
) VALUES
-- Allocations
('900000', 'Overhead Allocation', 'SECONDARY', 'ALLOCATION', false, false, true, true, 'DIRECT_COST'),
('901000', 'Equipment Hour Allocation', 'SECONDARY', 'ALLOCATION', false, false, true, true, 'MACHINE_HOURS'),
('902000', 'Labor Hour Allocation', 'SECONDARY', 'ALLOCATION', false, false, true, true, 'LABOR_HOURS'),
('903000', 'Area-Based Allocation', 'SECONDARY', 'ALLOCATION', false, false, true, true, 'AREA'),

-- Settlements
('910000', 'WBS Settlement', 'SECONDARY', 'SETTLEMENT', false, false, true, true, NULL),
('911000', 'Internal Order Settlement', 'SECONDARY', 'SETTLEMENT', false, false, true, true, NULL),

-- Internal Activities
('920000', 'Internal Activity Allocation', 'SECONDARY', 'INTERNAL_ORDER', false, false, true, true, 'ACTIVITY_QUANTITY')

ON CONFLICT (cost_element) DO NOTHING;

COMMENT ON TABLE cost_elements IS 'Cost Elements Master (SAP CO Model) - Separate from GL Accounts for Cost Accounting';
COMMENT ON COLUMN cost_elements.cost_element IS 'Cost Element Code (same as GL Account for primary cost elements)';
COMMENT ON COLUMN cost_elements.cost_element_category IS 'PRIMARY_DIRECT, PRIMARY_INDIRECT, or SECONDARY';
COMMENT ON COLUMN cost_elements.is_primary_cost IS 'Primary cost elements map 1:1 to GL accounts';
COMMENT ON COLUMN cost_elements.is_secondary_cost IS 'Secondary cost elements are CO-only (allocations, settlements)';
COMMENT ON COLUMN cost_elements.gl_account IS 'GL Account reference (NULL for secondary cost elements)';
