-- Add PR Tables and Quantity Tracking for MR→PR→PO Flow
-- Estimated time: 5 minutes to run

-- 1. Create PR Header Table
CREATE TABLE IF NOT EXISTS pr_headers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pr_number VARCHAR(20) UNIQUE NOT NULL,
  company_code VARCHAR(4) NOT NULL,
  purchasing_org VARCHAR(4) NOT NULL,
  purchase_group VARCHAR(3) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
  created_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(12),
  tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'
);

-- 2. Create PR Items Table
CREATE TABLE IF NOT EXISTS pr_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pr_header_id UUID NOT NULL REFERENCES pr_headers(id) ON DELETE CASCADE,
  line_number INTEGER NOT NULL,
  material_code VARCHAR(40),
  material_description TEXT,
  quantity DECIMAL(13,3) NOT NULL,
  uom VARCHAR(3) NOT NULL,
  delivery_plant VARCHAR(4) NOT NULL,
  required_date DATE NOT NULL,
  estimated_price DECIMAL(13,2),
  currency VARCHAR(3),
  project_code VARCHAR(24),
  wbs_element VARCHAR(24),
  activity_code VARCHAR(12),
  cost_center VARCHAR(10),
  pr_quantity DECIMAL(13,3) NOT NULL,
  open_quantity DECIMAL(13,3) NOT NULL,
  po_quantity DECIMAL(13,3) DEFAULT 0,
  item_status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
  tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
  UNIQUE(pr_header_id, line_number)
);

-- 3. Create MR→PR Mapping Table
CREATE TABLE IF NOT EXISTS mr_pr_item_mapping (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mr_item_id UUID NOT NULL REFERENCES material_request_items(id),
  pr_item_id UUID NOT NULL REFERENCES pr_items(id),
  quantity DECIMAL(13,3) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'
);

-- 4. Create PR→PO Mapping Table
CREATE TABLE IF NOT EXISTS pr_po_item_mapping (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pr_item_id UUID NOT NULL REFERENCES pr_items(id),
  po_item_id UUID NOT NULL REFERENCES po_lines(id),
  quantity DECIMAL(13,3) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'
);

-- 5. Add Quantity Tracking to MR Items
ALTER TABLE material_request_items
ADD COLUMN IF NOT EXISTS open_quantity DECIMAL(13,3),
ADD COLUMN IF NOT EXISTS pr_quantity DECIMAL(13,3) DEFAULT 0,
ADD COLUMN IF NOT EXISTS item_status VARCHAR(20) DEFAULT 'OPEN';

UPDATE material_request_items 
SET open_quantity = requested_quantity,
    pr_quantity = 0,
    item_status = 'OPEN'
WHERE open_quantity IS NULL;

-- 6. Add Quantity Tracking to PO Lines
ALTER TABLE po_lines
ADD COLUMN IF NOT EXISTS open_quantity DECIMAL(13,3),
ADD COLUMN IF NOT EXISTS gr_quantity DECIMAL(13,3) DEFAULT 0,
ADD COLUMN IF NOT EXISTS item_status VARCHAR(20) DEFAULT 'OPEN';

UPDATE po_lines 
SET open_quantity = quantity,
    gr_quantity = 0,
    item_status = 'OPEN'
WHERE open_quantity IS NULL;

-- 7. Create Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_pr_items_pr_header ON pr_items(pr_header_id);
CREATE INDEX IF NOT EXISTS idx_pr_items_material ON pr_items(material_code);
CREATE INDEX IF NOT EXISTS idx_mr_pr_mapping_mr ON mr_pr_item_mapping(mr_item_id);
CREATE INDEX IF NOT EXISTS idx_mr_pr_mapping_pr ON mr_pr_item_mapping(pr_item_id);
CREATE INDEX IF NOT EXISTS idx_pr_po_mapping_pr ON pr_po_item_mapping(pr_item_id);
CREATE INDEX IF NOT EXISTS idx_pr_po_mapping_po ON pr_po_item_mapping(po_item_id);

-- 8. Grant Permissions
GRANT SELECT, INSERT, UPDATE ON pr_headers TO authenticated;
GRANT SELECT, INSERT, UPDATE ON pr_items TO authenticated;
GRANT SELECT, INSERT ON mr_pr_item_mapping TO authenticated;
GRANT SELECT, INSERT ON pr_po_item_mapping TO authenticated;

SELECT 'MR→PR→PO tables created successfully!' as status;
