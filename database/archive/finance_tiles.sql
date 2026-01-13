-- Finance and Controlling Tiles
-- ===============================

-- Insert Finance category tiles
INSERT INTO tiles (
    title, subtitle, icon, color, route, module_code, tile_category, 
    construction_action, auth_object, sequence_order, is_active
) VALUES

-- Financial Accounting (FI) Tiles
('Chart of Accounts', 'Maintain GL accounts and cost elements', 'BookOpen', 'blue', '/finance/chart-of-accounts', 'FI', 'Finance', 'DISPLAY', 'FI_GL_DISP', 1, true),
('Create Journal Entry', 'Manual journal entry posting', 'Edit3', 'green', '/finance/journal-entry', 'FI', 'Finance', 'CREATE', 'FI_GL_POST', 2, true),
('Document Display', 'View financial documents', 'FileText', 'blue', '/finance/document-display', 'FI', 'Finance', 'DISPLAY', 'FI_DOC_DIS', 3, true),
('Document Reversal', 'Reverse financial documents', 'RotateCcw', 'red', '/finance/document-reversal', 'FI', 'Finance', 'CHANGE', 'FI_DOC_REV', 4, true),
('Trial Balance', 'GL account balances', 'BarChart3', 'purple', '/finance/trial-balance', 'FI', 'Finance', 'DISPLAY', 'FI_GL_DISP', 5, true),

-- Controlling (CO) Tiles  
('Project Cost Analysis', 'CJI3 - Project line items', 'TrendingUp', 'orange', '/controlling/project-costs', 'CO', 'Finance', 'DISPLAY', 'CO_PRJ_DIS', 6, true),
('Cost Element Master', 'Maintain cost elements', 'Target', 'blue', '/controlling/cost-elements', 'CO', 'Finance', 'CHANGE', 'CO_CST_ELE', 7, true),
('Project Budget', 'Project budget planning', 'DollarSign', 'green', '/controlling/project-budget', 'CO', 'Finance', 'CHANGE', 'CO_PRJ_BUD', 8, true),
('Overhead Allocation', 'Allocate overhead costs', 'Share2', 'purple', '/controlling/overhead-allocation', 'CO', 'Finance', 'EXECUTE', 'CO_ALLOCAT', 9, true),
('Variance Analysis', 'Plan vs actual analysis', 'GitCompare', 'red', '/controlling/variance-analysis', 'CO', 'Finance', 'DISPLAY', 'CO_VARIANC', 10, true),

-- Period End Processing
('Period End Closing', 'Month/year end processing', 'Calendar', 'gray', '/finance/period-closing', 'FI', 'Finance', 'EXECUTE', 'FI_PER_CLO', 11, true),
('Cost Settlement', 'Settle project costs', 'ArrowRightLeft', 'orange', '/controlling/cost-settlement', 'CO', 'Finance', 'EXECUTE', 'CO_SETTLEM', 12, true),

-- Reports
('Financial Statements', 'P&L and Balance Sheet', 'FileBarChart', 'blue', '/finance/financial-statements', 'FI', 'Finance', 'DISPLAY', 'FI_REPORTS', 13, true),
('Project Profitability', 'Project P&L analysis', 'PieChart', 'green', '/controlling/project-profitability', 'CO', 'Finance', 'DISPLAY', 'CO_PROFITA', 14, true),
('Cash Flow Report', 'Cash flow analysis', 'TrendingUp', 'blue', '/finance/cash-flow', 'FI', 'Finance', 'DISPLAY', 'FI_CASHFLO', 15, true);

-- Create Finance authorization objects
INSERT INTO authorization_objects (
    object_name, description, module, is_active
) VALUES
('FI_GL_DISP', 'FI GL Account Display', 'FI', true),
('FI_GL_POST', 'FI GL Posting', 'FI', true),
('FI_DOC_DIS', 'FI Document Display', 'FI', true),
('FI_DOC_REV', 'FI Document Reversal', 'FI', true),
('FI_PER_CLO', 'FI Period Closing', 'FI', true),
('FI_REPORTS', 'FI Reporting', 'FI', true),
('FI_CASHFLO', 'FI Cash Flow', 'FI', true),
('CO_PRJ_DIS', 'CO Project Display', 'CO', true),
('CO_CST_ELE', 'CO Cost Element', 'CO', true),
('CO_PRJ_BUD', 'CO Project Budget', 'CO', true),
('CO_ALLOCAT', 'CO Allocation', 'CO', true),
('CO_VARIANC', 'CO Variance Analysis', 'CO', true),
('CO_SETTLEM', 'CO Settlement', 'CO', true),
('CO_PROFITA', 'CO Profitability', 'CO', true);

-- Verify tiles were created
SELECT 
    title, module_code, tile_category, auth_object, sequence_order
FROM tiles 
WHERE tile_category = 'Finance' 
ORDER BY sequence_order;