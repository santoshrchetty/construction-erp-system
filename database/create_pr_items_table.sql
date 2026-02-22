-- ============================================================================
-- PURCHASE REQUISITION LINE ITEMS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.purchase_requisition_items (
  id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  pr_id UUID NOT NULL REFERENCES purchase_requisitions(id) ON DELETE CASCADE,
  mr_item_id UUID REFERENCES material_request_items(id) ON DELETE SET NULL,
  line_number INTEGER NOT NULL,
  
  -- Material Information
  material_id UUID NOT NULL REFERENCES materials(id),
  material_code VARCHAR(18) NOT NULL,
  material_name VARCHAR(100),
  description TEXT,
  
  -- Quantities & UOM
  quantity NUMERIC(13,3) NOT NULL,
  base_uom VARCHAR(3) NOT NULL,
  
  -- Pricing
  unit_price NUMERIC(13,2),
  total_price NUMERIC(15,2),
  currency_code VARCHAR(3) DEFAULT 'USD',
  
  -- Delivery
  delivery_date DATE,
  plant_code VARCHAR(4) NOT NULL,
  storage_location_id UUID REFERENCES storage_locations(id),
  
  -- Vendor (Suggested)
  vendor_code VARCHAR(10),
  vendor_name VARCHAR(100),
  
  -- Account Assignment
  account_assignment_type VARCHAR(1), -- K=Cost Center, P=Project, A=Asset
  project_code VARCHAR(24),
  wbs_element VARCHAR(24),
  cost_center VARCHAR(10),
  
  -- Status
  item_status VARCHAR(20) DEFAULT 'OPEN', -- OPEN, ORDERED, CLOSED, CANCELLED
  
  -- Audit
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  tenant_id UUID NOT NULL DEFAULT '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  
  CONSTRAINT fk_pr_items_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  CONSTRAINT purchase_requisition_items_unique_line UNIQUE(pr_id, line_number)
);

-- Indexes
CREATE INDEX idx_pr_items_pr ON public.purchase_requisition_items(pr_id);
CREATE INDEX idx_pr_items_mr_item ON public.purchase_requisition_items(mr_item_id);
CREATE INDEX idx_pr_items_material ON public.purchase_requisition_items(material_id);
CREATE INDEX idx_pr_items_status ON public.purchase_requisition_items(item_status);
CREATE INDEX idx_pr_items_plant ON public.purchase_requisition_items(plant_code);

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION update_pr_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_pr_items_updated_at
BEFORE UPDATE ON purchase_requisition_items
FOR EACH ROW
EXECUTE FUNCTION update_pr_items_updated_at();

-- Verify
SELECT 
  'purchase_requisition_items' as table_name,
  COUNT(*) as row_count
FROM purchase_requisition_items;
