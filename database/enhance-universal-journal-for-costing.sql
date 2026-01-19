-- Enhance Universal Journal for Activity-Level Cost Tracking and Cost Elements

-- Add activity_code column for execution-level cost tracking
ALTER TABLE universal_journal 
ADD COLUMN IF NOT EXISTS activity_code VARCHAR(50);

-- Add cost_element column for cost accounting (SAP CO model)
ALTER TABLE universal_journal 
ADD COLUMN IF NOT EXISTS cost_element VARCHAR(20);

-- Add foreign key to cost_elements (optional, can be removed if causing issues)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'fk_uj_cost_element'
    ) THEN
        ALTER TABLE universal_journal 
        ADD CONSTRAINT fk_uj_cost_element 
        FOREIGN KEY (cost_element) REFERENCES cost_elements(cost_element);
    END IF;
END $$;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_uj_activity_code 
ON universal_journal(activity_code);

CREATE INDEX IF NOT EXISTS idx_uj_cost_element 
ON universal_journal(cost_element);

CREATE INDEX IF NOT EXISTS idx_uj_wbs_activity 
ON universal_journal(wbs_element, activity_code);

CREATE INDEX IF NOT EXISTS idx_uj_cost_gl 
ON universal_journal(cost_element, gl_account);

CREATE INDEX IF NOT EXISTS idx_uj_project_activity 
ON universal_journal(project_code, activity_code);

-- Trigger to auto-populate cost_element from gl_account for primary cost elements
CREATE OR REPLACE FUNCTION sync_cost_element_from_gl()
RETURNS TRIGGER AS $$
BEGIN
    -- If cost_element is NULL and gl_account exists, try to map from cost_elements
    IF NEW.cost_element IS NULL AND NEW.gl_account IS NOT NULL THEN
        SELECT cost_element INTO NEW.cost_element
        FROM cost_elements
        WHERE gl_account = NEW.gl_account
          AND is_primary_cost = true
          AND is_active = true
        LIMIT 1;
    END IF;
    
    -- If activity_code is provided, extract WBS from it
    IF NEW.activity_code IS NOT NULL AND NEW.wbs_element IS NULL THEN
        NEW.wbs_element := split_part(NEW.activity_code, '-', 1);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_cost_element_from_gl
    BEFORE INSERT OR UPDATE ON universal_journal
    FOR EACH ROW
    EXECUTE FUNCTION sync_cost_element_from_gl();

COMMENT ON COLUMN universal_journal.activity_code IS 'Activity-level cost tracking (e.g., HW-0001.01-A01) - execution level';
COMMENT ON COLUMN universal_journal.cost_element IS 'Cost Element for cost accounting (SAP CO model) - maps to gl_account for primary costs';
