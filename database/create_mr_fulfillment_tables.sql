-- ============================================================================
-- MATERIAL REQUEST FULFILLMENT: RESERVATIONS & PURCHASE REQUISITIONS
-- ============================================================================

-- 1. RESERVATIONS TABLE (Stock Allocation)
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.reservations (
  id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  reservation_number VARCHAR(20) UNIQUE NOT NULL,
  mr_id UUID NOT NULL REFERENCES material_requests(id) ON DELETE CASCADE,
  plant_code VARCHAR(4) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, GOODS_ISSUED, CANCELLED
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  tenant_id UUID NOT NULL DEFAULT '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  CONSTRAINT fk_reservations_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE INDEX idx_reservations_mr ON public.reservations(mr_id);
CREATE INDEX idx_reservations_status ON public.reservations(status);

-- 2. RESERVATION ITEMS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.reservation_items (
  id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  reservation_id UUID NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
  mr_item_id UUID NOT NULL REFERENCES material_request_items(id) ON DELETE CASCADE,
  line_number INTEGER NOT NULL,
  material_id UUID NOT NULL REFERENCES materials(id),
  storage_location_id UUID NOT NULL REFERENCES storage_locations(id),
  
  -- Quantities
  reserved_quantity NUMERIC(13,3) NOT NULL,
  issued_quantity NUMERIC(13,3) DEFAULT 0,
  base_uom VARCHAR(3) NOT NULL,
  
  -- Account Assignment
  account_assignment_type VARCHAR(1), -- K=Cost Center, P=Project
  project_code VARCHAR(24),
  wbs_element VARCHAR(24),
  cost_center VARCHAR(10),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  tenant_id UUID NOT NULL DEFAULT '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  CONSTRAINT fk_reservation_items_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  UNIQUE(reservation_id, line_number)
);

CREATE INDEX idx_reservation_items_reservation ON public.reservation_items(reservation_id);
CREATE INDEX idx_reservation_items_mr_item ON public.reservation_items(mr_item_id);
CREATE INDEX idx_reservation_items_material ON public.reservation_items(material_id);

-- 3. PURCHASE REQUISITIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.purchase_requisitions (
  id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  pr_number VARCHAR(20) UNIQUE NOT NULL,
  mr_id UUID REFERENCES material_requests(id) ON DELETE SET NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT', -- DRAFT, SUBMITTED, APPROVED, CONVERTED_TO_PO, CANCELLED
  company_code VARCHAR(4) NOT NULL,
  plant_code VARCHAR(4) NOT NULL,
  total_amount NUMERIC(15,2) DEFAULT 0,
  currency_code VARCHAR(3) DEFAULT 'USD',
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  approved_at TIMESTAMP WITH TIME ZONE,
  tenant_id UUID NOT NULL DEFAULT '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  CONSTRAINT fk_purchase_requisitions_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id)
);

CREATE INDEX idx_pr_mr ON public.purchase_requisitions(mr_id);
CREATE INDEX idx_pr_status ON public.purchase_requisitions(status);
CREATE INDEX idx_pr_plant ON public.purchase_requisitions(plant_code);

-- 4. PURCHASE REQUISITION ITEMS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.purchase_requisition_items (
  id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
  pr_id UUID NOT NULL REFERENCES purchase_requisitions(id) ON DELETE CASCADE,
  mr_item_id UUID REFERENCES material_request_items(id) ON DELETE SET NULL,
  line_number INTEGER NOT NULL,
  material_id UUID NOT NULL REFERENCES materials(id),
  material_code VARCHAR(18) NOT NULL,
  material_name VARCHAR(100),
  description TEXT,
  
  -- Quantities & Pricing
  quantity NUMERIC(13,3) NOT NULL,
  base_uom VARCHAR(3) NOT NULL,
  unit_price NUMERIC(13,2),
  total_price NUMERIC(15,2),
  currency_code VARCHAR(3) DEFAULT 'USD',
  
  -- Delivery
  delivery_date DATE,
  plant_code VARCHAR(4) NOT NULL,
  storage_location_id UUID REFERENCES storage_locations(id),
  
  -- Vendor
  vendor_code VARCHAR(10),
  vendor_name VARCHAR(100),
  
  -- Account Assignment
  account_assignment_type VARCHAR(1), -- K=Cost Center, P=Project, A=Asset
  project_code VARCHAR(24),
  wbs_element VARCHAR(24),
  cost_center VARCHAR(10),
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  tenant_id UUID NOT NULL DEFAULT '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
  CONSTRAINT fk_pr_items_tenant FOREIGN KEY (tenant_id) REFERENCES tenants(id),
  UNIQUE(pr_id, line_number)
);

CREATE INDEX idx_pr_items_pr ON public.purchase_requisition_items(pr_id);
CREATE INDEX idx_pr_items_mr_item ON public.purchase_requisition_items(mr_item_id);
CREATE INDEX idx_pr_items_material ON public.purchase_requisition_items(material_id);

-- 5. UPDATE MATERIAL REQUEST ITEMS TABLE (Add fulfillment tracking)
-- ============================================================================
ALTER TABLE material_request_items 
ADD COLUMN IF NOT EXISTS fulfillment_type VARCHAR(20), -- STOCK, PURCHASE, PARTIAL_STOCK, NOT_FULFILLED
ADD COLUMN IF NOT EXISTS reservation_id UUID REFERENCES reservations(id),
ADD COLUMN IF NOT EXISTS pr_id UUID REFERENCES purchase_requisitions(id),
ADD COLUMN IF NOT EXISTS stock_available_qty NUMERIC(13,3) DEFAULT 0,
ADD COLUMN IF NOT EXISTS stock_reserved_qty NUMERIC(13,3) DEFAULT 0,
ADD COLUMN IF NOT EXISTS purchase_qty NUMERIC(13,3) DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_mr_items_fulfillment ON material_request_items(fulfillment_type);
CREATE INDEX IF NOT EXISTS idx_mr_items_reservation ON material_request_items(reservation_id);
CREATE INDEX IF NOT EXISTS idx_mr_items_pr ON material_request_items(pr_id);

-- 6. NUMBER RANGES FOR RESERVATIONS AND PRs
-- ============================================================================
INSERT INTO number_ranges (object_type, prefix, current_number, min_number, max_number, is_active, tenant_id)
VALUES 
  ('RESERVATION', 'RES', 1, 1, 9999999, true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('PURCHASE_REQ', 'PR', 1, 1, 9999999, true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid)
ON CONFLICT (object_type, tenant_id) DO NOTHING;

-- 7. SAMPLE MATERIAL STATUS DATA
-- ============================================================================
INSERT INTO material_status (status_code, status_name, allow_procurement, allow_consumption, tenant_id)
VALUES 
  ('01', 'Unrestricted', true, true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('02', 'Quality Inspection', false, false, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('03', 'Blocked', false, false, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('04', 'Reserved', false, true, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid)
ON CONFLICT (status_code) DO NOTHING;

-- 8. VERIFY TABLES
-- ============================================================================
SELECT 
  'reservations' as table_name, 
  COUNT(*) as row_count 
FROM reservations
UNION ALL
SELECT 'reservation_items', COUNT(*) FROM reservation_items
UNION ALL
SELECT 'purchase_requisitions', COUNT(*) FROM purchase_requisitions
UNION ALL
SELECT 'purchase_requisition_items', COUNT(*) FROM purchase_requisition_items
UNION ALL
SELECT 'material_storage_data', COUNT(*) FROM material_storage_data
UNION ALL
SELECT 'material_status', COUNT(*) FROM material_status;
