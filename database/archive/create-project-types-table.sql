-- Create project_types table for 2-level hierarchy
CREATE TABLE IF NOT EXISTS project_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type_code VARCHAR(50) NOT NULL,
    type_name VARCHAR(100) NOT NULL,
    category_code VARCHAR(50) NOT NULL,
    gl_posting_variant VARCHAR(50),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    company_code VARCHAR(10) DEFAULT 'C001',
    sort_order INTEGER DEFAULT 999,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(type_code, company_code)
);

-- Insert project types for each category
INSERT INTO project_types (type_code, type_name, category_code, gl_posting_variant, description, company_code, sort_order) VALUES
-- CUSTOMER Category Types
('FIXED_PRICE', 'Fixed Price Contracts', 'CUSTOMER', 'REVENUE_MATCHING', 'Fixed price customer contracts', 'C001', 1),
('TIME_MATERIAL', 'Time & Material', 'CUSTOMER', 'DIRECT_BILLING', 'T&M customer contracts', 'C001', 2),
('COST_PLUS', 'Cost Plus Fee', 'CUSTOMER', 'COST_REIMBURSABLE', 'Cost plus fee contracts', 'C001', 3),
('MAINTENANCE', 'Service Contracts', 'CUSTOMER', 'SERVICE_REVENUE', 'Ongoing service contracts', 'C001', 4),

-- CONTRACT Category Types  
('LUMP_SUM', 'Lump Sum Contract', 'CONTRACT', 'MILESTONE_BILLING', 'Design-build contracts', 'C001', 1),
('UNIT_PRICE', 'Unit Price Contract', 'CONTRACT', 'QUANTITY_BASED', 'Per unit pricing contracts', 'C001', 2),
('MILESTONE', 'Milestone Contract', 'CONTRACT', 'MILESTONE_BILLING', 'Milestone-based billing', 'C001', 3),
('RETAINER', 'Retainer Contract', 'CONTRACT', 'RECURRING_REVENUE', 'Ongoing retainer services', 'C001', 4),

-- CAPITAL Category Types
('BUILDING', 'Building Construction', 'CAPITAL', 'ASSET_CONSTRUCTION', 'Building and facility projects', 'C001', 1),
('EQUIPMENT', 'Equipment Purchase', 'CAPITAL', 'ASSET_ACQUISITION', 'Machinery and equipment', 'C001', 2),
('IT_INFRASTRUCTURE', 'IT Infrastructure', 'CAPITAL', 'TECHNOLOGY_ASSET', 'Technology and IT projects', 'C001', 3),
('RENOVATION', 'Renovation Projects', 'CAPITAL', 'ASSET_IMPROVEMENT', 'Facility improvements', 'C001', 4),

-- OVERHEAD Category Types
('ADMIN', 'Administrative Overhead', 'OVERHEAD', 'PERIOD_EXPENSE', 'General administrative costs', 'C001', 1),
('FACILITIES', 'Facilities Overhead', 'OVERHEAD', 'ALLOCATED_EXPENSE', 'Facility-related overhead', 'C001', 2),
('UTILITIES', 'Utilities & Services', 'OVERHEAD', 'ALLOCATED_EXPENSE', 'Utilities and shared services', 'C001', 3),
('MANAGEMENT', 'Management Overhead', 'OVERHEAD', 'ALLOCATED_EXPENSE', 'Management and supervision', 'C001', 4)
ON CONFLICT (type_code, company_code) DO NOTHING;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_project_types_category ON project_types(category_code);
CREATE INDEX IF NOT EXISTS idx_project_types_company ON project_types(company_code);
CREATE INDEX IF NOT EXISTS idx_project_types_active ON project_types(is_active);

-- Add foreign key constraint (optional)
-- ALTER TABLE project_types 
-- ADD CONSTRAINT fk_project_types_category 
-- FOREIGN KEY (category_code, company_code) 
-- REFERENCES project_categories(category_code, company_code);