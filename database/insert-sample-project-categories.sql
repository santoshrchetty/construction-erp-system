-- Insert sample project categories if they don't exist
INSERT INTO project_categories (
    company_code,
    category_code,
    category_name,
    settlement_type,
    financial_impact,
    revenue_recognition,
    capitalization_flag,
    profitability_tracking,
    is_active
) VALUES
    ('C001', 'CUSTOMER', 'Customer Project', 'REVENUE', 'DIRECT', 'PERCENTAGE_COMPLETION', true, true, true),
    ('C001', 'INTERNAL', 'Internal Project', 'COST', 'INDIRECT', 'NONE', false, false, true),
    ('C001', 'INVESTMENT', 'Investment Project', 'ASSET', 'DIRECT', 'NONE', true, true, true),
    ('C001', 'OVERHEAD', 'Overhead Project', 'COST', 'INDIRECT', 'NONE', false, false, true)
ON CONFLICT (company_code, category_code) DO NOTHING;

-- Verify the insert
SELECT category_code, category_name, company_code, is_active 
FROM project_categories 
WHERE is_active = true
ORDER BY category_code;
