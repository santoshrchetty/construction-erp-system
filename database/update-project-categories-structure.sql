-- Update project_categories table structure
-- Rename posting_logic column to cost_ownership and update data

-- 1. Add new cost_ownership column
ALTER TABLE project_categories 
ADD COLUMN IF NOT EXISTS cost_ownership VARCHAR(50);

-- 2. Update existing data to new cost ownership values
UPDATE project_categories 
SET cost_ownership = CASE 
    WHEN posting_logic = 'DIRECT_POSTING' THEN 'ASSET_CAPITALIZED'
    WHEN posting_logic = 'SETTLEMENT_BASED' THEN 'REVENUE_GENERATING'
    WHEN posting_logic = 'ALLOCATION_BASED' THEN 'COST_ALLOCATED'
    ELSE 'PERIOD_EXPENSED'
END
WHERE cost_ownership IS NULL;

-- 3. Drop old posting_logic column (optional - can keep for migration period)
-- ALTER TABLE project_categories DROP COLUMN IF EXISTS posting_logic;

-- 4. Update sample data with proper cost ownership
UPDATE project_categories 
SET cost_ownership = CASE category_code
    WHEN 'CUSTOMER' THEN 'REVENUE_GENERATING'
    WHEN 'CONTRACT' THEN 'REVENUE_GENERATING' 
    WHEN 'CAPITAL' THEN 'ASSET_CAPITALIZED'
    WHEN 'OVERHEAD' THEN 'PERIOD_EXPENSED'
    WHEN 'RND' THEN 'PERIOD_EXPENSED'
    WHEN 'MAINTENANCE' THEN 'COST_ALLOCATED'
    ELSE cost_ownership
END
WHERE company_code = 'C001';