-- Add missing fields to material_request_items table at line item level
-- Note: Workflow approval remains at header level for simplicity
ALTER TABLE material_request_items 
ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'RESERVED', 'PARTIALLY_ISSUED', 'FULLY_ISSUED', 'CANCELLED')),
ADD COLUMN IF NOT EXISTS priority VARCHAR(10) DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
ADD COLUMN IF NOT EXISTS requested_by VARCHAR(50),
ADD COLUMN IF NOT EXISTS requested_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS required_date TIMESTAMP,
ADD COLUMN IF NOT EXISTS project_id INTEGER,
ADD COLUMN IF NOT EXISTS wbs_element_id INTEGER,
ADD COLUMN IF NOT EXISTS activity_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS account_assignment_category VARCHAR(2),
ADD COLUMN IF NOT EXISTS gl_account VARCHAR(10),
ADD COLUMN IF NOT EXISTS asset_number VARCHAR(12),
ADD COLUMN IF NOT EXISTS order_number VARCHAR(12),
ADD COLUMN IF NOT EXISTS production_order_number VARCHAR(12),
ADD COLUMN IF NOT EXISTS operation_number VARCHAR(4),
ADD COLUMN IF NOT EXISTS quality_order_number VARCHAR(12),
ADD COLUMN IF NOT EXISTS inspection_lot VARCHAR(12),
ADD COLUMN IF NOT EXISTS company_code VARCHAR(4),
ADD COLUMN IF NOT EXISTS plant_code VARCHAR(4),
ADD COLUMN IF NOT EXISTS department_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS delivery_location VARCHAR(50),
ADD COLUMN IF NOT EXISTS purpose TEXT,
ADD COLUMN IF NOT EXISTS justification TEXT,
ADD COLUMN IF NOT EXISTS notes TEXT,
ADD COLUMN IF NOT EXISTS total_value DECIMAL(15,2),
ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'GBP';
-- Removed: approval_workflow_id, approved_by, approved_date (kept at header level)

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_material_request_items_status ON material_request_items(status);
CREATE INDEX IF NOT EXISTS idx_material_request_items_priority ON material_request_items(priority);
CREATE INDEX IF NOT EXISTS idx_material_request_items_project ON material_request_items(project_id);
CREATE INDEX IF NOT EXISTS idx_material_request_items_wbs ON material_request_items(wbs_element_id);
CREATE INDEX IF NOT EXISTS idx_material_request_items_activity ON material_request_items(activity_code);
CREATE INDEX IF NOT EXISTS idx_material_request_items_acct_cat ON material_request_items(account_assignment_category);
CREATE INDEX IF NOT EXISTS idx_material_request_items_company ON material_request_items(company_code);
CREATE INDEX IF NOT EXISTS idx_material_request_items_plant ON material_request_items(plant_code);