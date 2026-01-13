-- Construction App Project Category Framework
-- Based on ERP best practices with construction industry focus

-- 1. Add project category columns to existing projects table
ALTER TABLE projects ADD COLUMN IF NOT EXISTS project_category VARCHAR(20) DEFAULT 'CUSTOMER';
ALTER TABLE projects ADD COLUMN IF NOT EXISTS settlement_type VARCHAR(30) DEFAULT 'REVENUE';
ALTER TABLE projects ADD COLUMN IF NOT EXISTS revenue_recognition VARCHAR(30) DEFAULT 'POC';
ALTER TABLE projects ADD COLUMN IF NOT EXISTS capitalization_flag BOOLEAN DEFAULT false;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS profitability_tracking BOOLEAN DEFAULT true;
ALTER TABLE projects ADD COLUMN IF NOT EXISTS construction_type VARCHAR(20) DEFAULT 'NEW_BUILD';
ALTER TABLE projects ADD COLUMN IF NOT EXISTS sector VARCHAR(20) DEFAULT 'PRIVATE';

-- 2. Create project categories lookup table
CREATE TABLE IF NOT EXISTS project_categories (
    category_code VARCHAR(20) PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    settlement_type VARCHAR(30) NOT NULL,
    financial_impact VARCHAR(100),
    revenue_recognition VARCHAR(30),
    capitalization_flag BOOLEAN DEFAULT false,
    profitability_tracking BOOLEAN DEFAULT true,
    gl_account_range VARCHAR(50),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. Insert construction-specific project categories
INSERT INTO project_categories VALUES
-- Revenue-generating projects (Customer work)
('CUSTOMER', 'Customer Project', 'REVENUE', 'Revenue + Direct Costs', 'POC', false, true, '400000-499999,500000-599999', 'External client construction projects with revenue recognition', true),
('CONTRACT', 'Contract Project', 'REVENUE', 'Contract Revenue/Costs', 'MILESTONE', false, true, '400000-499999,500000-599999', 'Fixed-price construction contracts with milestone billing', true),
('TIME_MAT', 'Time & Material', 'REVENUE', 'Hourly + Material Costs', 'REAL_TIME', false, true, '400000-499999,500000-599999', 'T&M construction work with real-time billing', true),

-- Capital/Investment projects (Asset creation)
('CAPITAL', 'Capital Project', 'ASSET', 'CIP to Fixed Assets', null, true, false, '150000-159999,600000-699999', 'Internal capital construction projects creating fixed assets', true),
('FACILITY', 'Facility Project', 'ASSET', 'Facility Construction', null, true, false, '150000-159999,600000-699999', 'Office, warehouse, or facility construction projects', true),
('EQUIPMENT', 'Equipment Project', 'ASSET', 'Equipment Installation', null, true, false, '140000-149999,600000-699999', 'Heavy equipment and machinery installation projects', true),

-- Overhead/Internal projects (Cost allocation)
('OVERHEAD', 'Overhead Project', 'COST_CENTER', 'Operating Expenses', null, false, false, '700000-799999', 'Internal overhead and administrative projects', true),
('MAINTENANCE', 'Maintenance Project', 'COST_CENTER', 'Maintenance Costs', null, false, false, '520000-529999', 'Ongoing maintenance and repair projects', true),
('TRAINING', 'Training Project', 'COST_CENTER', 'Training Expenses', null, false, false, '530000-539999', 'Employee training and development projects', true),

-- R&D/Innovation projects
('RND', 'R&D Project', 'EXPENSE', 'R&D Expenses or IP Assets', null, true, true, '540000-549999', 'Research and development construction innovation', true),
('INNOVATION', 'Innovation Project', 'EXPENSE', 'Innovation Investment', null, true, true, '540000-549999', 'New construction methods and technology development', true),

-- Compliance/Regulatory projects
('COMPLIANCE', 'Compliance Project', 'EXPENSE', 'Regulatory Costs', null, false, false, '550000-559999', 'Safety, environmental, and regulatory compliance projects', true),
('SAFETY', 'Safety Project', 'EXPENSE', 'Safety Investments', null, false, false, '550000-559999', 'Workplace safety and risk mitigation projects', true);

-- 4. Create construction type lookup
CREATE TABLE IF NOT EXISTS construction_types (
    type_code VARCHAR(20) PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

INSERT INTO construction_types VALUES
('NEW_BUILD', 'New Construction', 'Ground-up new construction projects', true),
('RENOVATION', 'Renovation', 'Existing building renovation and remodeling', true),
('ADDITION', 'Addition', 'Building additions and expansions', true),
('RETROFIT', 'Retrofit', 'Building system upgrades and retrofits', true),
('DEMOLITION', 'Demolition', 'Demolition and site clearing projects', true),
('INFRASTRUCTURE', 'Infrastructure', 'Roads, utilities, and infrastructure projects', true);

-- 5. Create sector lookup
CREATE TABLE IF NOT EXISTS project_sectors (
    sector_code VARCHAR(20) PRIMARY KEY,
    sector_name VARCHAR(50) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT true
);

INSERT INTO project_sectors VALUES
('PRIVATE', 'Private Sector', 'Private commercial and residential projects', true),
('PUBLIC', 'Public Sector', 'Government and municipal projects', true),
('FEDERAL', 'Federal Government', 'Federal government construction projects', true),
('STATE', 'State Government', 'State and provincial government projects', true),
('MUNICIPAL', 'Municipal', 'City and local government projects', true),
('NON_PROFIT', 'Non-Profit', 'Non-profit and charitable organization projects', true);

-- 6. Update existing P100 project with proper categorization
UPDATE projects 
SET 
    project_category = 'CUSTOMER',
    settlement_type = 'REVENUE',
    revenue_recognition = 'POC',
    capitalization_flag = false,
    profitability_tracking = true,
    construction_type = 'NEW_BUILD',
    sector = 'PRIVATE'
WHERE code = 'P100';

-- 7. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_projects_category ON projects(project_category);
CREATE INDEX IF NOT EXISTS idx_projects_settlement ON projects(settlement_type);
CREATE INDEX IF NOT EXISTS idx_projects_construction_type ON projects(construction_type);
CREATE INDEX IF NOT EXISTS idx_projects_sector ON projects(sector);

-- 8. Verify the setup
SELECT 
    p.code,
    p.name,
    p.project_category,
    pc.category_name,
    p.settlement_type,
    p.construction_type,
    p.sector,
    p.budget
FROM projects p
LEFT JOIN project_categories pc ON p.project_category = pc.category_code
WHERE p.code = 'P100';