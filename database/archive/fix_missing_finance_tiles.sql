-- Check Main Finance Tiles Status
-- ================================

-- Check if the main Finance tiles exist
SELECT 'Main Finance Tiles Check' as check_type;
SELECT title, auth_object, is_active, created_at
FROM tiles 
WHERE auth_object IN (
    'FI_GL_DISP', 'FI_GL_POST', 'FI_DOC_DIS', 'FI_DOC_REV', 
    'FI_PER_CLO', 'FI_REPORTS', 'FI_CASHFLO',
    'CO_PRJ_DIS', 'CO_CST_ELE', 'CO_PRJ_BUD', 'CO_ALLOCAT', 
    'CO_VARIANC', 'CO_SETTLEM', 'CO_PROFITA'
)
ORDER BY auth_object;

-- Count Finance tiles by auth_object
SELECT 'Finance Tiles Count' as check_type;
SELECT 
    CASE 
        WHEN auth_object LIKE 'FI_%' THEN 'Financial Accounting'
        WHEN auth_object LIKE 'CO_%' THEN 'Controlling'
        ELSE 'Other'
    END as module,
    COUNT(*) as tile_count
FROM tiles 
WHERE tile_category = 'Finance'
GROUP BY 
    CASE 
        WHEN auth_object LIKE 'FI_%' THEN 'Financial Accounting'
        WHEN auth_object LIKE 'CO_%' THEN 'Controlling'
        ELSE 'Other'
    END;

-- Re-insert main Finance tiles if missing
INSERT INTO tiles (
    title, subtitle, icon, color, route, module_code, tile_category, 
    construction_action, auth_object, sequence_order, is_active
) VALUES
('Chart of Accounts', 'Maintain GL accounts and cost elements', 'BookOpen', 'blue', '/finance/chart-of-accounts', 'FI', 'Finance', 'DISPLAY', 'FI_GL_DISP', 1, true),
('Create Journal Entry', 'Manual journal entry posting', 'Edit3', 'green', '/finance/journal-entry', 'FI', 'Finance', 'CREATE', 'FI_GL_POST', 2, true),
('Document Display', 'View financial documents', 'FileText', 'blue', '/finance/document-display', 'FI', 'Finance', 'DISPLAY', 'FI_DOC_DIS', 3, true),
('Document Reversal', 'Reverse financial documents', 'RotateCcw', 'red', '/finance/document-reversal', 'FI', 'Finance', 'CHANGE', 'FI_DOC_REV', 4, true),
('Trial Balance', 'GL account balances', 'BarChart3', 'purple', '/finance/trial-balance', 'FI', 'Finance', 'DISPLAY', 'FI_GL_DISP', 5, true),
('Project Cost Analysis', 'CJI3 - Project line items', 'TrendingUp', 'orange', '/controlling/project-costs', 'CO', 'Finance', 'DISPLAY', 'CO_PRJ_DIS', 6, true),
('Cost Element Master', 'Maintain cost elements', 'Target', 'blue', '/controlling/cost-elements', 'CO', 'Finance', 'CHANGE', 'CO_CST_ELE', 7, true),
('Project Budget', 'Project budget planning', 'DollarSign', 'green', '/controlling/project-budget', 'CO', 'Finance', 'CHANGE', 'CO_PRJ_BUD', 8, true),
('Overhead Allocation', 'Allocate overhead costs', 'Share2', 'purple', '/controlling/overhead-allocation', 'CO', 'Finance', 'EXECUTE', 'CO_ALLOCAT', 9, true),
('Variance Analysis', 'Plan vs actual analysis', 'GitCompare', 'red', '/controlling/variance-analysis', 'CO', 'Finance', 'DISPLAY', 'CO_VARIANC', 10, true),
('Period End Closing', 'Month/year end processing', 'Calendar', 'gray', '/finance/period-closing', 'FI', 'Finance', 'EXECUTE', 'FI_PER_CLO', 11, true),
('Cost Settlement', 'Settle project costs', 'ArrowRightLeft', 'orange', '/controlling/cost-settlement', 'CO', 'Finance', 'EXECUTE', 'CO_SETTLEM', 12, true),
('Financial Statements', 'P&L and Balance Sheet', 'FileBarChart', 'blue', '/finance/financial-statements', 'FI', 'Finance', 'DISPLAY', 'FI_REPORTS', 13, true),
('Project Profitability', 'Project P&L analysis', 'PieChart', 'green', '/controlling/project-profitability', 'CO', 'Finance', 'DISPLAY', 'CO_PROFITA', 14, true),
('Cash Flow Report', 'Cash flow analysis', 'TrendingUp', 'blue', '/finance/cash-flow', 'FI', 'Finance', 'DISPLAY', 'FI_CASHFLO', 15, true);

-- Verify insertion
SELECT 'Final Verification' as check_type;
SELECT COUNT(*) as total_finance_tiles
FROM tiles 
WHERE tile_category = 'Finance';