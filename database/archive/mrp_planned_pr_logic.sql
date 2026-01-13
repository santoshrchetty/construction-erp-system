-- MRP & Planned PR Generation Logic
-- =================================

-- 1. MRP Net Requirements Calculation
CREATE OR REPLACE FUNCTION calculate_net_requirements(
  p_planning_horizon_days INTEGER DEFAULT 90
) RETURNS TABLE (
  material_code VARCHAR(50),
  planning_date DATE,
  gross_requirement DECIMAL(15,3),
  available_stock DECIMAL(15,3),
  reserved_stock DECIMAL(15,3),
  net_requirement DECIMAL(15,3),
  procurement_proposal DECIMAL(15,3)
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_analysis_run_id UUID := gen_random_uuid();
BEGIN
  -- Clear previous analysis
  DELETE FROM mrp_shortage_analysis WHERE created_at < NOW() - INTERVAL '7 days';
  
  -- Calculate net requirements by material and date
  INSERT INTO mrp_shortage_analysis (
    analysis_run_id, material_code, planning_date, 
    total_demand, available_stock, reserved_stock, net_shortage,
    procurement_proposal_qty, procurement_proposal_date
  )
  SELECT 
    v_analysis_run_id,
    dl.material_code,
    dl.required_date as planning_date,
    SUM(dl.required_quantity) as total_demand,
    COALESCE(s.current_stock, 0) as available_stock,
    COALESCE(SUM(mr.reserved_quantity), 0) as reserved_stock,
    GREATEST(0, 
      SUM(dl.required_quantity) - 
      COALESCE(s.current_stock, 0) + 
      COALESCE(SUM(mr.reserved_quantity), 0)
    ) as net_shortage,
    -- Procurement proposal with lot sizing
    CASE 
      WHEN GREATEST(0, SUM(dl.required_quantity) - COALESCE(s.current_stock, 0) + COALESCE(SUM(mr.reserved_quantity), 0)) > 0
      THEN CEIL(GREATEST(0, SUM(dl.required_quantity) - COALESCE(s.current_stock, 0) + COALESCE(SUM(mr.reserved_quantity), 0)) / 100) * 100 -- Round up to nearest 100
      ELSE 0
    END as procurement_proposal_qty,
    dl.required_date - INTERVAL '7 days' as procurement_proposal_date -- Lead time offset
  FROM demand_lines dl
  JOIN demand_headers dh ON dl.demand_header_id = dh.id
  LEFT JOIN stores s ON s.material_code = dl.material_code
  LEFT JOIN material_reservations mr ON mr.material_code = dl.material_code 
    AND mr.reservation_status = 'active'
  WHERE dl.required_date BETWEEN CURRENT_DATE AND CURRENT_DATE + p_planning_horizon_days
    AND dl.line_status = 'active'
    AND dh.demand_status = 'active'
  GROUP BY dl.material_code, dl.required_date, s.current_stock
  HAVING SUM(dl.required_quantity) > 0;
  
  -- Return results
  RETURN QUERY
  SELECT 
    msa.material_code,
    msa.planning_date,
    msa.total_demand,
    msa.available_stock,
    msa.reserved_stock,
    msa.net_shortage,
    msa.procurement_proposal_qty
  FROM mrp_shortage_analysis msa
  WHERE msa.analysis_run_id = v_analysis_run_id
  ORDER BY msa.material_code, msa.planning_date;
END;
$$;

-- 2. Generate Planned PRs from MRP Results
CREATE OR REPLACE FUNCTION generate_planned_prs(
  p_grouping_strategy VARCHAR(20) DEFAULT 'PROJECT_DATE' -- PROJECT_DATE, MATERIAL_DATE, WEEKLY
) RETURNS TABLE (
  planned_pr_id UUID,
  materials_count INTEGER,
  total_estimated_value DECIMAL(15,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_shortage_record RECORD;
  v_planned_pr_id UUID;
  v_planned_pr_number VARCHAR(50);
  v_materials_count INTEGER := 0;
  v_total_value DECIMAL(15,2) := 0;
BEGIN
  -- Generate Planned PRs based on grouping strategy
  FOR v_shortage_record IN 
    SELECT 
      msa.material_code,
      msa.planning_date,
      msa.procurement_proposal_qty,
      dh.demand_source_id as project_id,
      CASE p_grouping_strategy
        WHEN 'PROJECT_DATE' THEN dh.demand_source_id::TEXT || '_' || msa.planning_date::TEXT
        WHEN 'MATERIAL_DATE' THEN msa.material_code || '_' || msa.planning_date::TEXT
        WHEN 'WEEKLY' THEN dh.demand_source_id::TEXT || '_' || DATE_TRUNC('week', msa.planning_date)::TEXT
        ELSE dh.demand_source_id::TEXT || '_' || msa.planning_date::TEXT
      END as grouping_key
    FROM mrp_shortage_analysis msa
    JOIN demand_lines dl ON dl.material_code = msa.material_code
    JOIN demand_headers dh ON dl.demand_header_id = dh.id
    WHERE msa.procurement_proposal_qty > 0
      AND msa.created_at > NOW() - INTERVAL '1 hour' -- Recent analysis only
    GROUP BY msa.material_code, msa.planning_date, msa.procurement_proposal_qty, 
             dh.demand_source_id, grouping_key
  LOOP
    -- Generate Planned PR number
    SELECT 'PPR-' || TO_CHAR(NOW(), 'YYYYMM') || '-' || LPAD(NEXTVAL('planned_pr_sequence')::TEXT, 4, '0') 
    INTO v_planned_pr_number;
    
    -- Create Planned PR
    INSERT INTO planned_procurement_docs (
      planned_doc_number, planned_doc_type, source_demand_header_id,
      material_code, planned_quantity, unit_of_measure, planned_date,
      procurement_type, estimated_cost
    ) 
    SELECT 
      v_planned_pr_number, 'PLANNED_PR', dh.id,
      v_shortage_record.material_code, v_shortage_record.procurement_proposal_qty,
      'EA', v_shortage_record.planning_date,
      'EXTERNAL', v_shortage_record.procurement_proposal_qty * 100 -- Estimated cost
    FROM demand_headers dh 
    WHERE dh.demand_source_id = v_shortage_record.project_id::UUID
    LIMIT 1
    RETURNING id INTO v_planned_pr_id;
    
    v_materials_count := v_materials_count + 1;
    v_total_value := v_total_value + (v_shortage_record.procurement_proposal_qty * 100);
  END LOOP;
  
  RETURN QUERY SELECT v_planned_pr_id, v_materials_count, v_total_value;
END;
$$;

-- 3. Convert Planned PR to Purchase Requisition
CREATE OR REPLACE FUNCTION convert_planned_pr_to_pr(
  p_planned_pr_id UUID,
  p_converted_by UUID
) RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
  v_pr_id UUID;
  v_pr_number VARCHAR(50);
  v_planned_pr RECORD;
BEGIN
  -- Get planned PR details
  SELECT * INTO v_planned_pr
  FROM planned_procurement_docs
  WHERE id = p_planned_pr_id AND conversion_status = 'planned';
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Planned PR not found or already converted';
  END IF;
  
  -- Generate PR number
  SELECT 'PR-' || TO_CHAR(NOW(), 'YYYYMM') || '-' || LPAD(NEXTVAL('pr_sequence')::TEXT, 4, '0') 
  INTO v_pr_number;
  
  -- Create Purchase Requisition
  INSERT INTO purchase_requisitions (
    pr_number, project_id, requested_by, pr_status, 
    total_estimated_value, required_date
  ) VALUES (
    v_pr_number, 
    (SELECT demand_source_id FROM demand_headers WHERE id = v_planned_pr.source_demand_header_id),
    p_converted_by, 'submitted',
    v_planned_pr.estimated_cost, v_planned_pr.planned_date
  ) RETURNING id INTO v_pr_id;
  
  -- Create PR line items
  INSERT INTO pr_line_items (
    pr_id, material_code, material_description, quantity, 
    unit_of_measure, estimated_total_cost
  ) VALUES (
    v_pr_id, v_planned_pr.material_code, 
    'Auto-generated from Planned PR', v_planned_pr.planned_quantity,
    v_planned_pr.unit_of_measure, v_planned_pr.estimated_cost
  );
  
  -- Update planned PR status
  UPDATE planned_procurement_docs
  SET conversion_status = 'converted', converted_document_id = v_pr_id
  WHERE id = p_planned_pr_id;
  
  RETURN v_pr_id;
END;
$$;

-- Create sequences
CREATE SEQUENCE IF NOT EXISTS planned_pr_sequence START 1;

-- Sample data for testing
INSERT INTO demand_headers (demand_number, demand_source_type, demand_source_id, cost_object_type, cost_object_id, created_by) VALUES
('DEM-001', 'PROJECT', (SELECT id FROM projects LIMIT 1), 'WBS', (SELECT id FROM projects LIMIT 1), (SELECT id FROM users LIMIT 1));

INSERT INTO demand_lines (demand_header_id, demand_line_type, material_code, required_quantity, unit_of_measure, required_date) VALUES
((SELECT id FROM demand_headers LIMIT 1), 'ACTIVITY', 'CEMENT-OPC-53', 500.000, 'BAG', CURRENT_DATE + 10),
((SELECT id FROM demand_headers LIMIT 1), 'ACTIVITY', 'STEEL-TMT-12MM', 10.000, 'TON', CURRENT_DATE + 15);

SELECT 'MRP & PLANNED PR LOGIC IMPLEMENTED' as status;