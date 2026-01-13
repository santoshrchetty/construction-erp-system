-- Material Reservations & Purchase Requisition Logic
-- =================================================

-- 1. Material Reservations Table
CREATE TABLE IF NOT EXISTS material_reservations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES projects(id),
  wbs_node_id UUID REFERENCES wbs_nodes(id),
  activity_id UUID REFERENCES activities(id),
  material_code VARCHAR(50) NOT NULL,
  material_description TEXT NOT NULL,
  reserved_quantity DECIMAL(15,3) NOT NULL,
  unit_of_measure VARCHAR(10) NOT NULL,
  required_date DATE NOT NULL,
  priority_level VARCHAR(20) DEFAULT 'normal', -- critical, high, normal, low
  reservation_status VARCHAR(20) DEFAULT 'pending', -- pending, approved, converted, cancelled
  created_by UUID NOT NULL REFERENCES users(id),
  approved_by UUID REFERENCES users(id),
  approved_date TIMESTAMP WITH TIME ZONE,
  estimated_cost DECIMAL(15,2),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Purchase Requisitions Table
CREATE TABLE IF NOT EXISTS purchase_requisitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pr_number VARCHAR(50) UNIQUE NOT NULL,
  project_id UUID NOT NULL REFERENCES projects(id),
  requested_by UUID NOT NULL REFERENCES users(id),
  department VARCHAR(50),
  pr_status VARCHAR(20) DEFAULT 'draft', -- draft, submitted, approved, rejected, converted
  total_estimated_value DECIMAL(15,2),
  justification TEXT,
  required_date DATE NOT NULL,
  approved_by UUID REFERENCES users(id),
  approved_date TIMESTAMP WITH TIME ZONE,
  rejection_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. PR Line Items (linked to reservations)
CREATE TABLE IF NOT EXISTS pr_line_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pr_id UUID NOT NULL REFERENCES purchase_requisitions(id),
  reservation_id UUID REFERENCES material_reservations(id),
  material_code VARCHAR(50) NOT NULL,
  material_description TEXT NOT NULL,
  quantity DECIMAL(15,3) NOT NULL,
  unit_of_measure VARCHAR(10) NOT NULL,
  estimated_unit_cost DECIMAL(15,2),
  estimated_total_cost DECIMAL(15,2),
  preferred_vendor VARCHAR(100),
  specifications TEXT,
  line_status VARCHAR(20) DEFAULT 'active'
);

-- 4. Workflow Logic Functions

-- Check available stock vs reservations
CREATE OR REPLACE FUNCTION check_material_availability(
  p_material_code VARCHAR(50),
  p_required_quantity DECIMAL(15,3)
) RETURNS TABLE (
  available_stock DECIMAL(15,3),
  reserved_quantity DECIMAL(15,3),
  net_available DECIMAL(15,3),
  shortage DECIMAL(15,3)
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE(s.current_stock, 0) as available_stock,
    COALESCE(SUM(mr.reserved_quantity), 0) as reserved_quantity,
    COALESCE(s.current_stock, 0) - COALESCE(SUM(mr.reserved_quantity), 0) as net_available,
    GREATEST(0, p_required_quantity - (COALESCE(s.current_stock, 0) - COALESCE(SUM(mr.reserved_quantity), 0))) as shortage
  FROM (SELECT p_material_code as material_code) m
  LEFT JOIN stores s ON s.material_code = m.material_code
  LEFT JOIN material_reservations mr ON mr.material_code = m.material_code 
    AND mr.reservation_status IN ('approved', 'pending')
  GROUP BY s.current_stock;
END;
$$;

-- Auto-generate PR from approved reservations
CREATE OR REPLACE FUNCTION create_pr_from_reservations(
  p_project_id UUID,
  p_requested_by UUID,
  p_reservation_ids UUID[]
) RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_pr_id UUID;
  v_pr_number VARCHAR(50);
  v_total_value DECIMAL(15,2) := 0;
  v_reservation RECORD;
BEGIN
  -- Generate PR number
  SELECT 'PR-' || TO_CHAR(NOW(), 'YYYYMM') || '-' || LPAD(NEXTVAL('pr_sequence')::TEXT, 4, '0') 
  INTO v_pr_number;
  
  -- Create PR header
  INSERT INTO purchase_requisitions (pr_number, project_id, requested_by, pr_status, required_date)
  SELECT v_pr_number, p_project_id, p_requested_by, 'submitted', MIN(required_date)
  FROM material_reservations 
  WHERE id = ANY(p_reservation_ids)
  RETURNING id INTO v_pr_id;
  
  -- Create PR line items from reservations
  FOR v_reservation IN 
    SELECT * FROM material_reservations WHERE id = ANY(p_reservation_ids)
  LOOP
    INSERT INTO pr_line_items (
      pr_id, reservation_id, material_code, material_description, 
      quantity, unit_of_measure, estimated_total_cost
    ) VALUES (
      v_pr_id, v_reservation.id, v_reservation.material_code, 
      v_reservation.material_description, v_reservation.reserved_quantity,
      v_reservation.unit_of_measure, v_reservation.estimated_cost
    );
    
    v_total_value := v_total_value + COALESCE(v_reservation.estimated_cost, 0);
    
    -- Update reservation status
    UPDATE material_reservations 
    SET reservation_status = 'converted', updated_at = NOW()
    WHERE id = v_reservation.id;
  END LOOP;
  
  -- Update PR total value
  UPDATE purchase_requisitions 
  SET total_estimated_value = v_total_value
  WHERE id = v_pr_id;
  
  RETURN v_pr_id;
END;
$$;

-- Create sequence for PR numbering
CREATE SEQUENCE IF NOT EXISTS pr_sequence START 1;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_material_reservations_project ON material_reservations(project_id);
CREATE INDEX IF NOT EXISTS idx_material_reservations_status ON material_reservations(reservation_status);
CREATE INDEX IF NOT EXISTS idx_material_reservations_material ON material_reservations(material_code);
CREATE INDEX IF NOT EXISTS idx_pr_status ON purchase_requisitions(pr_status);
CREATE INDEX IF NOT EXISTS idx_pr_project ON purchase_requisitions(project_id);

-- Sample workflow status data
INSERT INTO material_reservations (
  project_id, material_code, material_description, reserved_quantity, 
  unit_of_measure, required_date, priority_level, created_by, estimated_cost
) VALUES 
(
  (SELECT id FROM projects LIMIT 1),
  'CEMENT-OPC-53', 'OPC 53 Grade Cement', 100.000, 'BAG',
  CURRENT_DATE + INTERVAL '7 days', 'high',
  (SELECT id FROM users WHERE email = 'engineer@nttdemo.com' LIMIT 1),
  50000.00
),
(
  (SELECT id FROM projects LIMIT 1),
  'STEEL-TMT-12MM', 'TMT Steel Bars 12mm', 5.000, 'TON',
  CURRENT_DATE + INTERVAL '10 days', 'critical',
  (SELECT id FROM users WHERE email = 'engineer@nttdemo.com' LIMIT 1),
  350000.00
);

SELECT 'MATERIAL RESERVATIONS & PR LOGIC IMPLEMENTED' as status;