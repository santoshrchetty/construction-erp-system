-- Unified Material Request System Schema
-- Supports reservations, purchase requisitions, and material requests

-- 1. Main material requests table (unified document)
CREATE TABLE material_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_number VARCHAR(50) UNIQUE NOT NULL,
  request_type VARCHAR(20) NOT NULL CHECK (request_type IN ('RESERVATION', 'PURCHASE_REQ', 'MATERIAL_REQ')),
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED', 'CONVERTED', 'FULFILLED', 'CANCELLED')),
  priority VARCHAR(10) NOT NULL DEFAULT 'MEDIUM' CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'URGENT')),
  
  -- Requestor information
  requested_by UUID NOT NULL REFERENCES auth.users(id),
  requested_date DATE NOT NULL DEFAULT CURRENT_DATE,
  required_date DATE NOT NULL,
  
  -- Organizational assignment
  company_code VARCHAR(31) NOT NULL,
  plant_code VARCHAR(31),
  cost_center VARCHAR(31),
  wbs_element VARCHAR(50),
  project_code VARCHAR(31),
  
  -- Request details
  purpose TEXT,
  justification TEXT,
  notes TEXT,
  
  -- Workflow tracking
  current_approver UUID REFERENCES auth.users(id),
  approved_by UUID REFERENCES auth.users(id),
  approved_date TIMESTAMP,
  rejected_by UUID REFERENCES auth.users(id),
  rejected_date TIMESTAMP,
  rejection_reason TEXT,
  
  -- Conversion tracking
  converted_to_po VARCHAR(50), -- PO number if converted
  converted_date TIMESTAMP,
  
  -- Audit fields
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  created_by UUID NOT NULL REFERENCES auth.users(id),
  updated_by UUID REFERENCES auth.users(id)
);

-- 2. Material request line items
CREATE TABLE material_request_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES material_requests(id) ON DELETE CASCADE,
  line_number INTEGER NOT NULL,
  
  -- Material information
  material_code VARCHAR(50) NOT NULL,
  material_name VARCHAR(240),
  description TEXT,
  
  -- Quantity and units
  requested_quantity DECIMAL(15,3) NOT NULL,
  reserved_quantity DECIMAL(15,3) DEFAULT 0,
  fulfilled_quantity DECIMAL(15,3) DEFAULT 0,
  base_uom VARCHAR(10) NOT NULL,
  
  -- Pricing (for purchase requisitions)
  estimated_price DECIMAL(15,2),
  currency_code VARCHAR(3) DEFAULT 'USD',
  
  -- Storage information
  storage_location VARCHAR(31),
  bin_location VARCHAR(50),
  
  -- Vendor information (for PRs)
  preferred_vendor VARCHAR(50),
  vendor_material_number VARCHAR(100),
  
  -- Delivery information
  delivery_date DATE,
  delivery_address TEXT,
  
  -- Item status
  item_status VARCHAR(20) DEFAULT 'OPEN' CHECK (item_status IN ('OPEN', 'RESERVED', 'ORDERED', 'RECEIVED', 'CANCELLED')),
  
  -- Audit fields
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(request_id, line_number)
);

-- 3. Approval workflow configuration
CREATE TABLE approval_workflows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_name VARCHAR(100) NOT NULL,
  request_type VARCHAR(20) NOT NULL,
  company_code VARCHAR(31),
  material_category VARCHAR(50),
  amount_threshold DECIMAL(15,2),
  
  -- Approval levels
  level_1_approver_role VARCHAR(50),
  level_1_amount_limit DECIMAL(15,2),
  level_2_approver_role VARCHAR(50),
  level_2_amount_limit DECIMAL(15,2),
  level_3_approver_role VARCHAR(50),
  level_3_amount_limit DECIMAL(15,2),
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 4. Request templates for common scenarios
CREATE TABLE request_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_name VARCHAR(100) NOT NULL,
  template_type VARCHAR(20) NOT NULL,
  company_code VARCHAR(31),
  project_type VARCHAR(50),
  
  -- Default values
  default_priority VARCHAR(10) DEFAULT 'MEDIUM',
  default_cost_center VARCHAR(31),
  default_purpose TEXT,
  
  -- Template items (JSON for flexibility)
  template_items JSONB,
  
  is_active BOOLEAN DEFAULT true,
  created_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 5. Request attachments
CREATE TABLE request_attachments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES material_requests(id) ON DELETE CASCADE,
  file_name VARCHAR(255) NOT NULL,
  file_path VARCHAR(500) NOT NULL,
  file_size INTEGER,
  mime_type VARCHAR(100),
  uploaded_by UUID NOT NULL REFERENCES auth.users(id),
  uploaded_at TIMESTAMP DEFAULT NOW()
);

-- 6. Indexes for performance
CREATE INDEX idx_material_requests_status ON material_requests(status);
CREATE INDEX idx_material_requests_type ON material_requests(request_type);
CREATE INDEX idx_material_requests_company ON material_requests(company_code);
CREATE INDEX idx_material_requests_requested_by ON material_requests(requested_by);
CREATE INDEX idx_material_requests_required_date ON material_requests(required_date);
CREATE INDEX idx_material_request_items_material ON material_request_items(material_code);
CREATE INDEX idx_material_request_items_status ON material_request_items(item_status);

-- 7. Update triggers
CREATE OR REPLACE FUNCTION update_material_requests_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_material_requests_timestamp
  BEFORE UPDATE ON material_requests
  FOR EACH ROW EXECUTE FUNCTION update_material_requests_timestamp();

CREATE TRIGGER trigger_update_material_request_items_timestamp
  BEFORE UPDATE ON material_request_items
  FOR EACH ROW EXECUTE FUNCTION update_material_requests_timestamp();

-- 8. Sample approval workflows
INSERT INTO approval_workflows (workflow_name, request_type, company_code, amount_threshold, level_1_approver_role, level_1_amount_limit, level_2_approver_role, level_2_amount_limit) VALUES
('Standard Reservation Approval', 'RESERVATION', 'C001', 0, 'SUPERVISOR', 10000, 'MANAGER', 50000),
('Purchase Requisition Approval', 'PURCHASE_REQ', 'C001', 1000, 'SUPERVISOR', 25000, 'MANAGER', 100000),
('Emergency Material Request', 'MATERIAL_REQ', 'C001', 0, 'SUPERVISOR', 5000, 'MANAGER', 25000);

-- 9. Sample request templates
INSERT INTO request_templates (template_name, template_type, company_code, project_type, default_priority, default_purpose, template_items) VALUES
('Construction Site Materials', 'MATERIAL_REQ', 'C001', 'CONSTRUCTION', 'HIGH', 'Site construction materials', 
 '[{"material_code": "CEMENT-OPC-53", "quantity": 100, "uom": "BAG"}, {"material_code": "STEEL-TMT-12MM", "quantity": 5, "uom": "TON"}]'),
('Office Supplies Request', 'PURCHASE_REQ', 'C001', 'ADMIN', 'LOW', 'Monthly office supplies', 
 '[{"material_code": "PAPER-A4", "quantity": 10, "uom": "REAM"}, {"material_code": "PEN-BLUE", "quantity": 50, "uom": "PCS"}]');

COMMENT ON TABLE material_requests IS 'Unified table for material reservations, purchase requisitions, and material requests';
COMMENT ON TABLE material_request_items IS 'Line items for material requests with quantity and fulfillment tracking';
COMMENT ON TABLE approval_workflows IS 'Configurable approval workflows based on request type, amount, and organizational rules';
COMMENT ON TABLE request_templates IS 'Pre-configured templates for common material request scenarios';