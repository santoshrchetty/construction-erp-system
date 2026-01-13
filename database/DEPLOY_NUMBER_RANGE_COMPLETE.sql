-- DEPLOY NUMBER RANGE SYSTEM - COMPLETE CONFIGURATION
-- Execute in sequence: Fix Constraint → Current Modules → Test

-- =====================================================
-- STEP 1: FIX ON CONFLICT ERROR
-- =====================================================

-- Add missing unique constraint
ALTER TABLE document_number_ranges 
DROP CONSTRAINT IF EXISTS unique_company_document_type;

ALTER TABLE document_number_ranges 
ADD CONSTRAINT unique_company_document_type 
UNIQUE (company_code, document_type);

-- =====================================================
-- STEP 2: DEPLOY CURRENT MODULE CONFIGURATIONS
-- =====================================================

-- Financial Accounting (FI) - Payment Documents
INSERT INTO document_number_ranges (
    company_code, document_type, fiscal_year, range_from, range_to, current_number,
    number_range_object, from_number, to_number, status, external_numbering, year_dependent, prefix, description
) VALUES
-- Payment Documents
('C001', 'PY', 2024, '5000000000', '5999999999', '5000000000', 'RF_BELEG', 5000000000, 5999999999, 'ACTIVE', false, true, 'PY', 'Payment Documents'),
('C001', 'PR', 2024, '5100000000', '5199999999', '5100000000', 'RF_BELEG', 5100000000, 5199999999, 'ACTIVE', false, true, 'PR', 'Payment Reversals'),
('C001', 'PC', 2024, '5200000000', '5299999999', '5200000000', 'RF_BELEG', 5200000000, 5299999999, 'ACTIVE', false, true, 'PC', 'Payment Clearing'),

-- Bank Documents
('C001', 'BK', 2024, '5300000000', '5399999999', '5300000000', 'RF_BELEG', 5300000000, 5399999999, 'ACTIVE', false, true, 'BK', 'Bank Documents'),
('C001', 'BS', 2024, '5400000000', '5499999999', '5400000000', 'RF_BELEG', 5400000000, 5499999999, 'ACTIVE', false, true, 'BS', 'Bank Statements'),

-- Materials Management (MM) - Goods Movement Documents
('C001', 'GI', 2024, '4900000000', '4999999999', '4900000000', 'MATBELEG', 4900000000, 4999999999, 'ACTIVE', false, false, 'GI', 'Goods Issue Documents'),
('C001', 'GT', 2024, '4800000000', '4899999999', '4800000000', 'MATBELEG', 4800000000, 4899999999, 'ACTIVE', false, false, 'GT', 'Goods Transfer Documents'),
('C001', 'GC', 2024, '4700000000', '4799999999', '4700000000', 'MATBELEG', 4700000000, 4799999999, 'ACTIVE', false, false, 'GC', 'Goods Receipt Cancellation'),

-- Inventory Documents
('C001', 'IV', 2024, '4600000000', '4699999999', '4600000000', 'MATBELEG', 4600000000, 4699999999, 'ACTIVE', false, false, 'IV', 'Inventory Documents'),
('C001', 'IC', 2024, '4500000000', '4599999999', '4500000000', 'MATBELEG', 4500000000, 4599999999, 'ACTIVE', false, false, 'IC', 'Inventory Count Documents'),
('C001', 'ID', 2024, '4400000000', '4499999999', '4400000000', 'MATBELEG', 4400000000, 4499999999, 'ACTIVE', false, false, 'ID', 'Inventory Difference Documents'),

-- Controlling (CO) - Cost Documents
('C001', 'CD', 2024, '6000000000', '6999999999', '6000000000', 'CO_BELEG', 6000000000, 6999999999, 'ACTIVE', false, true, 'CD', 'Cost Documents'),
('C001', 'CA', 2024, '6100000000', '6199999999', '6100000000', 'CO_BELEG', 6100000000, 6199999999, 'ACTIVE', false, true, 'CA', 'Cost Allocation Documents'),
('C001', 'CR', 2024, '6200000000', '6299999999', '6200000000', 'CO_BELEG', 6200000000, 6299999999, 'ACTIVE', false, true, 'CR', 'Cost Reposting Documents'),

-- Activity Based Costing
('C001', 'AB', 2024, '6300000000', '6399999999', '6300000000', 'CO_BELEG', 6300000000, 6399999999, 'ACTIVE', false, true, 'AB', 'Activity Based Costing'),
('C001', 'AC', 2024, '6400000000', '6499999999', '6400000000', 'CO_BELEG', 6400000000, 6499999999, 'ACTIVE', false, true, 'AC', 'Activity Allocation'),

-- Project System (PS) - Network and Activity Documents
('C001', 'NW', 2024, '7000000000', '7999999999', '7000000000', 'PROJ_BELEG', 7000000000, 7999999999, 'ACTIVE', false, false, 'NW', 'Network Documents'),
('C001', 'PS', 2024, '7100000000', '7199999999', '7100000000', 'PROJ_BELEG', 7100000000, 7199999999, 'ACTIVE', false, false, 'PS', 'Activity Documents'),
('C001', 'PJ', 2024, '7200000000', '7299999999', '7200000000', 'PROJ_BELEG', 7200000000, 7299999999, 'ACTIVE', false, false, 'PJ', 'Project Documents'),

-- Milestone and Progress Documents
('C001', 'MS', 2024, '7300000000', '7399999999', '7300000000', 'PROJ_BELEG', 7300000000, 7399999999, 'ACTIVE', false, false, 'MS', 'Milestone Documents'),
('C001', 'PG', 2024, '7400000000', '7499999999', '7400000000', 'PROJ_BELEG', 7400000000, 7499999999, 'ACTIVE', false, false, 'PG', 'Progress Documents'),

-- Resource Planning Documents
('C001', 'RP', 2024, '7500000000', '7599999999', '7500000000', 'PROJ_BELEG', 7500000000, 7599999999, 'ACTIVE', false, false, 'RP', 'Resource Planning Documents'),
('C001', 'RC', 2024, '7600000000', '7699999999', '7600000000', 'PROJ_BELEG', 7600000000, 7699999999, 'ACTIVE', false, false, 'RC', 'Resource Confirmation Documents')

ON CONFLICT (company_code, document_type) DO UPDATE SET
    range_from = EXCLUDED.range_from,
    range_to = EXCLUDED.range_to,
    from_number = EXCLUDED.from_number,
    to_number = EXCLUDED.to_number,
    current_number = EXCLUDED.current_number,
    status = EXCLUDED.status,
    external_numbering = EXCLUDED.external_numbering,
    year_dependent = EXCLUDED.year_dependent,
    prefix = EXCLUDED.prefix,
    description = EXCLUDED.description,
    fiscal_year = EXCLUDED.fiscal_year,
    modified_at = NOW();

-- Create number range groups for current modules
INSERT INTO number_range_groups (group_code, group_name, company_code, description) VALUES
('01', 'Financial Documents', 'C001', 'All financial accounting documents'),
('02', 'Material Documents', 'C001', 'All materials management documents'),
('03', 'Controlling Documents', 'C001', 'All controlling documents'),
('04', 'Project Documents', 'C001', 'All project system documents')
ON CONFLICT (company_code, group_code) DO UPDATE SET
    group_name = EXCLUDED.group_name,
    description = EXCLUDED.description;

-- Update number range groups for existing ranges
UPDATE document_number_ranges SET number_range_group = '01' 
WHERE company_code = 'C001' AND document_type IN ('PY', 'PR', 'PC', 'BK', 'BS');

UPDATE document_number_ranges SET number_range_group = '02' 
WHERE company_code = 'C001' AND document_type IN ('GI', 'GT', 'GC', 'IV', 'IC', 'ID');

UPDATE document_number_ranges SET number_range_group = '03' 
WHERE company_code = 'C001' AND document_type IN ('CD', 'CA', 'CR', 'AB', 'AC');

UPDATE document_number_ranges SET number_range_group = '04' 
WHERE company_code = 'C001' AND document_type IN ('NW', 'PS', 'PJ', 'MS', 'PG', 'RP', 'RC');

SELECT 'Step 2: Current module number ranges configured successfully' as status;

-- =====================================================
-- STEP 3: VERIFICATION
-- =====================================================

SELECT 'DEPLOYMENT VERIFICATION' as section;

SELECT 
    'Total Ranges Configured' as metric,
    COUNT(*) as count
FROM document_number_ranges 
WHERE company_code = 'C001';

SELECT 
    'Ranges by Module' as metric,
    number_range_group,
    COUNT(*) as count
FROM document_number_ranges 
WHERE company_code = 'C001'
GROUP BY number_range_group
ORDER BY number_range_group;

SELECT 'Number Range System Deployment Complete!' as final_status;