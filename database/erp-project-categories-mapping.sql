-- Universal Project Category Mapping Across ERPs
-- SAP, Oracle Cloud, Workday, Microsoft Dynamics

CREATE TABLE erp_project_categories (
    id SERIAL PRIMARY KEY,
    erp_system VARCHAR(20),
    category_code VARCHAR(10),
    category_name VARCHAR(100),
    settlement_type VARCHAR(30),
    financial_impact VARCHAR(50),
    revenue_recognition VARCHAR(30),
    asset_capitalization BOOLEAN,
    profitability_tracking BOOLEAN,
    compliance_requirements TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- SAP Project System (PS) Categories
INSERT INTO erp_project_categories VALUES
(1, 'SAP', 'CUST', 'Customer Project', 'Revenue Settlement', 'P&L Revenue + Costs', 'POC/Milestone', false, true, 'Revenue Recognition (ASC 606)'),
(2, 'SAP', 'INVT', 'Investment Project', 'Asset Settlement', 'Balance Sheet CIP->FA', null, true, false, 'Capitalization Rules'),
(3, 'SAP', 'OVHD', 'Overhead Project', 'Cost Center Settlement', 'Operating Expense', null, false, false, 'Cost Allocation'),
(4, 'SAP', 'RND', 'R&D Project', 'Expense/Asset Settlement', 'R&D Expense or IP Asset', null, true, true, 'R&D Capitalization Rules'),

-- Oracle Cloud PPM Categories  
(5, 'ORACLE', 'CONTRACT', 'Contract Project', 'Revenue Recognition', 'Contract Revenue/Costs', 'ASC 606 Compliant', false, true, 'Revenue Recognition Standards'),
(6, 'ORACLE', 'CAPITAL', 'Capital Project', 'Asset Capitalization', 'CIP to Fixed Assets', null, true, false, 'Asset Accounting Standards'),
(7, 'ORACLE', 'GRANT', 'Grant Project', 'Grant Accounting', 'Grant Revenue/Restrictions', 'Grant Compliance', false, true, 'Grant Compliance Rules'),
(8, 'ORACLE', 'INDIRECT', 'Indirect Project', 'Cost Allocation', 'Overhead Distribution', null, false, false, 'Cost Allocation Methods'),

-- Workday Financial Management Categories
(9, 'WORKDAY', 'BILLABLE', 'Billable Project', 'Customer Billing', 'Revenue Generation', 'Workday Revenue Mgmt', false, true, 'Revenue Recognition'),
(10, 'WORKDAY', 'CAPEX', 'Capital Expenditure', 'Asset Creation', 'Asset Capitalization', null, true, false, 'Asset Management Integration'),
(11, 'WORKDAY', 'OPERATIONAL', 'Operational Project', 'Cost Management', 'Operating Costs', null, false, false, 'Cost Center Allocation'),
(12, 'WORKDAY', 'COMPLIANCE', 'Compliance Project', 'Regulatory Expense', 'Compliance Costs', null, false, false, 'Regulatory Requirements'),

-- Microsoft Dynamics Categories
(13, 'DYNAMICS', 'TIME_MAT', 'Time & Material', 'T&M Billing', 'Hourly + Expenses', 'Real-time Recognition', false, true, 'Time Tracking Compliance'),
(14, 'DYNAMICS', 'FIXED_PRICE', 'Fixed Price', 'Milestone Billing', 'Contract Value', 'Milestone/POC', false, true, 'Contract Management'),
(15, 'DYNAMICS', 'INTERNAL', 'Internal Project', 'Cost Tracking', 'Internal Costs Only', null, false, false, 'Budget Control'),
(16, 'DYNAMICS', 'INVESTMENT', 'Investment Project', 'Asset Investment', 'Capital Investment', null, true, false, 'Investment Analysis');

-- Cross-ERP Project Type Mapping
CREATE TABLE project_type_mapping (
    universal_category VARCHAR(20),
    sap_equivalent VARCHAR(20),
    oracle_equivalent VARCHAR(20), 
    workday_equivalent VARCHAR(20),
    dynamics_equivalent VARCHAR(20),
    description TEXT
);

INSERT INTO project_type_mapping VALUES
('REVENUE_PROJECT', 'Customer Project', 'Contract Project', 'Billable Project', 'Time & Material', 'External revenue-generating projects'),
('CAPITAL_PROJECT', 'Investment Project', 'Capital Project', 'Capital Expenditure', 'Investment Project', 'Asset creation and capital expenditure'),
('OVERHEAD_PROJECT', 'Overhead Project', 'Indirect Project', 'Operational Project', 'Internal Project', 'Internal cost allocation and overhead'),
('RESEARCH_PROJECT', 'R&D Project', 'Grant Project', 'Compliance Project', 'Fixed Price', 'Research, development, and innovation'),
('MAINTENANCE_PROJECT', 'Overhead Project', 'Indirect Project', 'Operational Project', 'Internal Project', 'Ongoing maintenance and support');

-- Query to show cross-ERP compatibility
SELECT 
    universal_category,
    sap_equivalent,
    oracle_equivalent,
    workday_equivalent,
    dynamics_equivalent,
    description
FROM project_type_mapping
ORDER BY universal_category;