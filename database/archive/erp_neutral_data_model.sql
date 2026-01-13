-- ERP-Neutral Data Model for Construction & Manufacturing
-- ======================================================

-- 1. DEMAND HEADER (Universal demand source)
CREATE TABLE demand_headers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  demand_number VARCHAR(50) UNIQUE NOT NULL,
  demand_source_type VARCHAR(20) NOT NULL, -- 'PROJECT', 'PRODUCTION', 'FORECAST'
  demand_source_id UUID NOT NULL, -- Project ID or Production Order ID
  cost_object_type VARCHAR(20) NOT NULL, -- 'WBS', 'PRODUCTION_ORDER', 'COST_CENTER'
  cost_object_id UUID NOT NULL,
  demand_status VARCHAR(20) DEFAULT 'active',
  planning_horizon_start DATE,
  planning_horizon_end DATE,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. DEMAND LINES (Material requirements per demand source)
CREATE TABLE demand_lines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  demand_header_id UUID NOT NULL REFERENCES demand_headers(id),
  demand_line_type VARCHAR(20) NOT NULL, -- 'ACTIVITY', 'OPERATION', 'FORECAST'
  demand_line_id UUID, -- Activity ID or Operation ID
  material_code VARCHAR(50) NOT NULL,
  required_quantity DECIMAL(15,3) NOT NULL,
  unit_of_measure VARCHAR(10) NOT NULL,
  required_date DATE NOT NULL,
  priority_level VARCHAR(20) DEFAULT 'normal',
  bom_explosion_level INTEGER DEFAULT 0, -- For future BOM support
  line_status VARCHAR(20) DEFAULT 'active'
);

-- 3. MATERIAL RESERVATIONS (Stock allocation)
CREATE TABLE material_reservations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reservation_number VARCHAR(50) UNIQUE NOT NULL,
  demand_line_id UUID NOT NULL REFERENCES demand_lines(id),
  material_code VARCHAR(50) NOT NULL,
  reserved_quantity DECIMAL(15,3) NOT NULL,
  unit_of_measure VARCHAR(10) NOT NULL,
  reservation_date DATE NOT NULL,
  expiry_date DATE,
  reservation_status VARCHAR(20) DEFAULT 'active', -- active, consumed, expired, cancelled
  cost_object_type VARCHAR(20) NOT NULL,
  cost_object_id UUID NOT NULL,
  created_by UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. PLANNED PROCUREMENT DOCUMENTS
CREATE TABLE planned_procurement_docs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  planned_doc_number VARCHAR(50) UNIQUE NOT NULL,
  planned_doc_type VARCHAR(20) NOT NULL, -- 'PLANNED_PR', 'PLANNED_PO', 'PLANNED_PROD_ORDER'
  source_demand_header_id UUID NOT NULL REFERENCES demand_headers(id),
  material_code VARCHAR(50) NOT NULL,
  planned_quantity DECIMAL(15,3) NOT NULL,
  unit_of_measure VARCHAR(10) NOT NULL,
  planned_date DATE NOT NULL,
  procurement_type VARCHAR(20) NOT NULL, -- 'EXTERNAL', 'INTERNAL', 'PRODUCTION'
  estimated_cost DECIMAL(15,2),
  conversion_status VARCHAR(20) DEFAULT 'planned', -- planned, converted, cancelled
  converted_document_id UUID, -- Links to actual PR/PO/Production Order
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. COST OBJECTS (Universal cost assignment)
CREATE TABLE cost_objects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cost_object_number VARCHAR(50) UNIQUE NOT NULL,
  cost_object_type VARCHAR(20) NOT NULL, -- 'WBS', 'PRODUCTION_ORDER', 'COST_CENTER'
  cost_object_name VARCHAR(200) NOT NULL,
  parent_cost_object_id UUID REFERENCES cost_objects(id),
  project_id UUID, -- For project-based cost objects
  is_statistical BOOLEAN DEFAULT false,
  cost_object_status VARCHAR(20) DEFAULT 'active'
);

-- 6. MRP SHORTAGE ANALYSIS
CREATE TABLE mrp_shortage_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  analysis_run_id UUID NOT NULL,
  material_code VARCHAR(50) NOT NULL,
  planning_date DATE NOT NULL,
  total_demand DECIMAL(15,3) NOT NULL,
  available_stock DECIMAL(15,3) NOT NULL,
  reserved_stock DECIMAL(15,3) NOT NULL,
  net_shortage DECIMAL(15,3) NOT NULL,
  procurement_proposal_qty DECIMAL(15,3),
  procurement_proposal_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CONSTRUCTION vs MANUFACTURING MAPPING TABLE
-- ===========================================

/*
CONSTRUCTION CONCEPTS → MANUFACTURING CONCEPTS MAPPING:

| Construction Term    | Manufacturing Term     | Universal Object      |
|---------------------|------------------------|----------------------|
| Project             | Production Program     | demand_headers       |
| WBS Element         | Production Order       | cost_objects         |
| Activity            | Operation              | demand_lines         |
| BOQ Line Item       | BOM Component          | demand_lines         |
| Material Requisition| Component Requirement  | material_reservations|
| Project Cost        | Production Cost        | cost_objects         |
| Site Stock          | Work-in-Process        | inventory_locations  |
| Goods Issue         | Material Consumption   | goods_movements      |

SHARED OBJECTS:
- Materials Master (same for both)
- Vendors (same for both)
- Purchase Orders (same for both)
- Inventory Management (same for both)
- Cost Accounting (same posting logic)
*/

-- Indexes for performance
CREATE INDEX idx_demand_headers_source ON demand_headers(demand_source_type, demand_source_id);
CREATE INDEX idx_demand_lines_material ON demand_lines(material_code, required_date);
CREATE INDEX idx_reservations_material ON material_reservations(material_code, reservation_status);
CREATE INDEX idx_planned_docs_material ON planned_procurement_docs(material_code, planned_date);
CREATE INDEX idx_cost_objects_type ON cost_objects(cost_object_type, cost_object_status);

SELECT 'ERP-NEUTRAL DATA MODEL CREATED' as status;