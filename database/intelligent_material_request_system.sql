-- Intelligent Material Request System
-- Addresses construction industry pain points: excessive procurement, unused stock, unnecessary reservations

-- 1. Material demand intelligence and forecasting
CREATE TABLE material_demand_patterns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  material_code VARCHAR(50) NOT NULL,
  project_type VARCHAR(50), -- RESIDENTIAL, COMMERCIAL, INFRASTRUCTURE
  project_phase VARCHAR(30), -- FOUNDATION, STRUCTURE, FINISHING
  seasonal_factor DECIMAL(5,2) DEFAULT 1.0,
  lead_time_days INTEGER NOT NULL,
  minimum_order_qty DECIMAL(15,3),
  optimal_order_qty DECIMAL(15,3),
  shelf_life_days INTEGER, -- For perishable materials
  storage_cost_per_unit DECIMAL(10,2),
  wastage_percentage DECIMAL(5,2) DEFAULT 0,
  historical_usage_pattern JSONB, -- Monthly usage data
  created_at TIMESTAMP DEFAULT NOW()
);

-- 2. Real-time inventory availability with aging analysis
CREATE TABLE inventory_aging_analysis (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  material_code VARCHAR(50) NOT NULL,
  plant_code VARCHAR(31) NOT NULL,
  storage_location VARCHAR(31),
  batch_number VARCHAR(50),
  receipt_date DATE NOT NULL,
  quantity_available DECIMAL(15,3) NOT NULL,
  aging_days INTEGER GENERATED ALWAYS AS (CURRENT_DATE - receipt_date) STORED,
  aging_category VARCHAR(20) GENERATED ALWAYS AS (
    CASE 
      WHEN CURRENT_DATE - receipt_date <= 30 THEN 'FRESH'
      WHEN CURRENT_DATE - receipt_date <= 90 THEN 'AGING'
      WHEN CURRENT_DATE - receipt_date <= 180 THEN 'OLD'
      ELSE 'OBSOLETE'
    END
  ) STORED,
  estimated_value DECIMAL(15,2),
  last_movement_date DATE,
  movement_frequency INTEGER DEFAULT 0, -- Times moved in last 6 months
  is_reserved BOOLEAN DEFAULT false,
  reservation_expiry DATE
);

-- 3. Intelligent request validation rules
CREATE TABLE request_validation_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rule_name VARCHAR(100) NOT NULL,
  rule_type VARCHAR(30) NOT NULL CHECK (rule_type IN ('AVAILABILITY_CHECK', 'USAGE_PATTERN', 'BUDGET_CONTROL', 'WASTE_PREVENTION', 'TIMING_OPTIMIZATION')),
  material_category VARCHAR(50),
  project_type VARCHAR(50),
  validation_logic TEXT NOT NULL, -- SQL-like expression
  action_on_violation VARCHAR(20) NOT NULL CHECK (action_on_violation IN ('BLOCK', 'WARN', 'SUGGEST_ALTERNATIVE', 'REQUIRE_JUSTIFICATION')),
  message_template TEXT,
  is_active BOOLEAN DEFAULT true,
  priority INTEGER DEFAULT 1
);

-- Sample validation rules
INSERT INTO request_validation_rules (rule_name, rule_type, validation_logic, action_on_violation, message_template) VALUES
('Excessive Quantity Check', 'USAGE_PATTERN', 'requested_quantity > (historical_monthly_avg * 3)', 'REQUIRE_JUSTIFICATION', 'Requested quantity is 3x higher than historical average. Please justify the requirement.'),
('Existing Stock Check', 'AVAILABILITY_CHECK', 'available_stock > (requested_quantity * 0.8)', 'WARN', 'Similar materials available in inventory. Consider using existing stock first.'),
('Aging Stock Priority', 'WASTE_PREVENTION', 'aging_stock_available > 0 AND aging_days > 60', 'SUGGEST_ALTERNATIVE', 'Aging stock available. Using older stock first prevents waste.'),
('Budget Threshold Check', 'BUDGET_CONTROL', 'estimated_cost > monthly_budget_remaining', 'BLOCK', 'Request exceeds remaining monthly budget. Approval from Finance required.'),
('Seasonal Timing Check', 'TIMING_OPTIMIZATION', 'is_off_season = true AND material_category = "SEASONAL"', 'WARN', 'Off-season procurement may result in better pricing.');

-- 4. Smart material request workflow with intelligence
CREATE TABLE intelligent_material_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_number VARCHAR(50) UNIQUE NOT NULL,
  request_type VARCHAR(20) NOT NULL CHECK (request_type IN ('IMMEDIATE', 'PLANNED', 'EMERGENCY', 'BULK_ORDER')),
  
  -- Request details
  requested_by UUID NOT NULL,
  project_code VARCHAR(31),
  project_phase VARCHAR(30),
  required_date DATE NOT NULL,
  priority VARCHAR(10) NOT NULL DEFAULT 'MEDIUM',
  
  -- Intelligence flags
  has_alternatives BOOLEAN DEFAULT false,
  aging_stock_available BOOLEAN DEFAULT false,
  over_budget BOOLEAN DEFAULT false,
  unusual_quantity BOOLEAN DEFAULT false,
  
  -- Recommendations
  system_recommendations JSONB,
  cost_optimization_suggestions JSONB,
  timing_recommendations JSONB,
  
  -- Approval workflow
  requires_special_approval BOOLEAN DEFAULT false,
  approval_reason TEXT,
  
  -- Status tracking
  status VARCHAR(20) DEFAULT 'DRAFT',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 5. Request line items with intelligence
CREATE TABLE intelligent_request_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES intelligent_material_requests(id) ON DELETE CASCADE,
  line_number INTEGER NOT NULL,
  
  -- Material details
  material_code VARCHAR(50) NOT NULL,
  requested_quantity DECIMAL(15,3) NOT NULL,
  base_uom VARCHAR(10) NOT NULL,
  
  -- Intelligence analysis
  available_in_inventory DECIMAL(15,3) DEFAULT 0,
  aging_stock_qty DECIMAL(15,3) DEFAULT 0,
  historical_monthly_avg DECIMAL(15,3) DEFAULT 0,
  last_procurement_date DATE,
  last_procurement_qty DECIMAL(15,3),
  
  -- Cost analysis
  current_market_price DECIMAL(15,2),
  inventory_carrying_cost DECIMAL(15,2),
  procurement_lead_time INTEGER,
  
  -- Recommendations
  recommended_action VARCHAR(30) CHECK (recommended_action IN ('APPROVE', 'USE_EXISTING', 'REDUCE_QUANTITY', 'DEFER', 'FIND_ALTERNATIVE')),
  recommended_quantity DECIMAL(15,3),
  alternative_materials JSONB,
  cost_savings_potential DECIMAL(15,2),
  
  -- Validation results
  validation_status VARCHAR(20) DEFAULT 'PENDING',
  validation_warnings TEXT[],
  validation_errors TEXT[],
  
  UNIQUE(request_id, line_number)
);

-- 6. Material usage tracking and learning
CREATE TABLE material_usage_tracking (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  material_code VARCHAR(50) NOT NULL,
  project_code VARCHAR(31) NOT NULL,
  project_phase VARCHAR(30),
  
  -- Usage details
  planned_quantity DECIMAL(15,3),
  actual_quantity_used DECIMAL(15,3),
  wastage_quantity DECIMAL(15,3) DEFAULT 0,
  returned_quantity DECIMAL(15,3) DEFAULT 0,
  
  -- Performance metrics
  usage_efficiency DECIMAL(5,2) GENERATED ALWAYS AS (
    CASE WHEN planned_quantity > 0 
    THEN (actual_quantity_used / planned_quantity) * 100 
    ELSE 0 END
  ) STORED,
  
  wastage_percentage DECIMAL(5,2) GENERATED ALWAYS AS (
    CASE WHEN actual_quantity_used > 0 
    THEN (wastage_quantity / actual_quantity_used) * 100 
    ELSE 0 END
  ) STORED,
  
  -- Learning data
  usage_date DATE NOT NULL,
  weather_conditions VARCHAR(50),
  crew_size INTEGER,
  equipment_used VARCHAR(100),
  
  created_at TIMESTAMP DEFAULT NOW()
);

-- 7. Intelligent approval workflow function
CREATE OR REPLACE FUNCTION get_intelligent_approval_path(
  p_request_id UUID,
  p_total_amount DECIMAL(15,2),
  p_has_warnings BOOLEAN,
  p_unusual_quantity BOOLEAN,
  p_over_budget BOOLEAN
) RETURNS TABLE (
  approval_level INTEGER,
  approver_role VARCHAR(50),
  approval_reason TEXT,
  is_mandatory BOOLEAN
) AS $$
BEGIN
  -- Standard approval path
  RETURN QUERY SELECT 1, 'SUPERVISOR'::VARCHAR(50), 'Standard approval'::TEXT, true::BOOLEAN;
  
  -- Additional approvals based on intelligence flags
  IF p_unusual_quantity THEN
    RETURN QUERY SELECT 2, 'PROCUREMENT_MANAGER'::VARCHAR(50), 'Unusual quantity requires procurement review'::TEXT, true::BOOLEAN;
  END IF;
  
  IF p_over_budget THEN
    RETURN QUERY SELECT 3, 'FINANCE_MANAGER'::VARCHAR(50), 'Over budget requires finance approval'::TEXT, true::BOOLEAN;
  END IF;
  
  IF p_total_amount > 100000 THEN
    RETURN QUERY SELECT 4, 'GENERAL_MANAGER'::VARCHAR(50), 'High value requires executive approval'::TEXT, true::BOOLEAN;
  END IF;
  
  -- Emergency fast-track
  IF EXISTS (SELECT 1 FROM intelligent_material_requests WHERE id = p_request_id AND request_type = 'EMERGENCY') THEN
    RETURN QUERY SELECT 1, 'DUTY_MANAGER'::VARCHAR(50), 'Emergency fast-track approval'::TEXT, true::BOOLEAN;
    RETURN;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- 8. Cost optimization recommendations
CREATE TABLE cost_optimization_opportunities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  material_code VARCHAR(50) NOT NULL,
  opportunity_type VARCHAR(30) NOT NULL CHECK (opportunity_type IN ('BULK_DISCOUNT', 'SEASONAL_PRICING', 'ALTERNATIVE_MATERIAL', 'INVENTORY_OPTIMIZATION', 'SUPPLIER_CONSOLIDATION')),
  current_cost DECIMAL(15,2),
  optimized_cost DECIMAL(15,2),
  potential_savings DECIMAL(15,2) GENERATED ALWAYS AS (current_cost - optimized_cost) STORED,
  savings_percentage DECIMAL(5,2) GENERATED ALWAYS AS (
    CASE WHEN current_cost > 0 
    THEN ((current_cost - optimized_cost) / current_cost) * 100 
    ELSE 0 END
  ) STORED,
  recommendation_details JSONB,
  valid_until DATE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 9. Sample data for testing intelligence
INSERT INTO material_demand_patterns (material_code, project_type, project_phase, lead_time_days, minimum_order_qty, optimal_order_qty, wastage_percentage) VALUES
('CEMENT-OPC-53', 'COMMERCIAL', 'FOUNDATION', 7, 100, 500, 2.5),
('STEEL-TMT-12MM', 'RESIDENTIAL', 'STRUCTURE', 14, 5, 25, 1.0),
('CONCRETE-M25', 'INFRASTRUCTURE', 'STRUCTURE', 3, 10, 50, 5.0);

INSERT INTO inventory_aging_analysis (material_code, plant_code, storage_location, batch_number, receipt_date, quantity_available, estimated_value) VALUES
('CEMENT-OPC-53', 'P001', 'SL01', 'BATCH001', '2024-01-15', 150.000, 75000),
('STEEL-TMT-12MM', 'P001', 'SL02', 'BATCH002', '2023-11-20', 8.500, 552500),
('CONCRETE-M25', 'P001', 'SL01', 'BATCH003', '2024-01-10', 25.000, 125000);

-- 10. Performance monitoring views
CREATE VIEW material_procurement_efficiency AS
SELECT 
  m.material_code,
  COUNT(DISTINCT ir.id) as total_requests,
  AVG(iri.requested_quantity) as avg_requested_qty,
  AVG(mut.actual_quantity_used) as avg_actual_usage,
  AVG(mut.usage_efficiency) as avg_efficiency,
  AVG(mut.wastage_percentage) as avg_wastage,
  SUM(CASE WHEN iri.recommended_action = 'USE_EXISTING' THEN 1 ELSE 0 END) as inventory_utilization_suggestions,
  SUM(iri.cost_savings_potential) as total_potential_savings
FROM materials m
LEFT JOIN intelligent_request_items iri ON m.material_code = iri.material_code
LEFT JOIN intelligent_material_requests ir ON iri.request_id = ir.id
LEFT JOIN material_usage_tracking mut ON m.material_code = mut.material_code
GROUP BY m.material_code;

-- Summary of intelligent approach
SELECT 'INTELLIGENT MATERIAL REQUEST SYSTEM BENEFITS:' as info;

SELECT 
  'WASTE REDUCTION' as benefit,
  'Aging stock alerts, usage pattern analysis, optimal quantity suggestions' as implementation;

SELECT 
  'COST OPTIMIZATION' as benefit,
  'Bulk discount opportunities, seasonal pricing, alternative material suggestions' as implementation;

SELECT 
  'INVENTORY OPTIMIZATION' as benefit,
  'Real-time availability, aging analysis, carrying cost calculations' as implementation;

SELECT 
  'INTELLIGENT APPROVALS' as benefit,
  'Risk-based approval routing, automatic validation, exception handling' as implementation;

COMMENT ON TABLE intelligent_material_requests IS 'Smart material requests with AI-driven recommendations and validation';
COMMENT ON TABLE request_validation_rules IS 'Configurable rules to prevent common procurement mistakes';
COMMENT ON TABLE material_usage_tracking IS 'Learning system to improve future procurement decisions';