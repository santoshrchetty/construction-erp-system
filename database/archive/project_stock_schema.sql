-- Add project stock columns to existing stock_balances table
ALTER TABLE stock_balances ADD COLUMN IF NOT EXISTS stock_type VARCHAR(20) DEFAULT 'WAREHOUSE';
ALTER TABLE stock_balances ADD COLUMN IF NOT EXISTS account_assignment CHAR(1) DEFAULT 'W';
ALTER TABLE stock_balances ADD COLUMN IF NOT EXISTS project_code VARCHAR(20);
ALTER TABLE stock_balances ADD COLUMN IF NOT EXISTS wbs_element VARCHAR(50);
ALTER TABLE stock_balances ADD COLUMN IF NOT EXISTS cost_center VARCHAR(20);

-- Add project stock columns to existing stock_movements table
ALTER TABLE stock_movements ADD COLUMN IF NOT EXISTS account_assignment CHAR(1) DEFAULT 'W';
ALTER TABLE stock_movements ADD COLUMN IF NOT EXISTS project_code VARCHAR(20);
ALTER TABLE stock_movements ADD COLUMN IF NOT EXISTS wbs_element VARCHAR(50);
ALTER TABLE stock_movements ADD COLUMN IF NOT EXISTS cost_center VARCHAR(20);

-- Create project stock view with correct column references
CREATE OR REPLACE VIEW project_stock_overview AS
SELECT 
    sb.id,
    sb.current_quantity as current_stock,
    sb.available_quantity as available_stock,
    sb.stock_type,
    sb.account_assignment,
    sb.project_code,
    sb.wbs_element,
    sb.cost_center,
    sb.total_value as stock_value,
    p.name as project_name,
    wbs.name as wbs_name,
    wbs.description as wbs_description
FROM stock_balances sb
LEFT JOIN projects p ON sb.project_code = p.code
LEFT JOIN wbs_nodes wbs ON sb.wbs_element = wbs.code
WHERE sb.account_assignment = 'P' AND sb.current_quantity > 0;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_stock_balances_project ON stock_balances(project_code, wbs_element);
CREATE INDEX IF NOT EXISTS idx_stock_movements_project ON stock_movements(project_code, wbs_element);

-- Verify setup (check if project columns were added)
SELECT column_name 
FROM information_schema.columns 
WHERE table_name = 'stock_balances' 
AND column_name IN ('stock_type', 'account_assignment', 'project_code', 'wbs_element', 'cost_center')
ORDER BY column_name;