-- Flexible Approval Levels for Any Document Type
-- Unlimited approval levels, configurable thresholds, any document type

-- 1. Flexible approval level configuration
CREATE TABLE flexible_approval_levels (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  document_type VARCHAR(20) NOT NULL CHECK (document_type IN ('MATERIAL_REQ', 'PURCHASE_REQ', 'PURCHASE_ORDER', 'RESERVATION')),
  
  -- Approval level details
  level_number INTEGER NOT NULL,
  level_name VARCHAR(100) NOT NULL,
  approver_role VARCHAR(50) NOT NULL,
  
  -- Flexible thresholds
  amount_threshold_min DECIMAL(15,2) DEFAULT 0,
  amount_threshold_max DECIMAL(15,2),
  
  -- Additional criteria (optional)
  category_filter VARCHAR(50), -- Apply only to specific categories
  department_filter VARCHAR(50), -- Apply only to specific departments
  project_type_filter VARCHAR(50), -- Apply only to specific project types
  
  -- Approval behavior
  is_mandatory BOOLEAN DEFAULT true,
  can_delegate BOOLEAN DEFAULT true,
  timeout_hours INTEGER DEFAULT 24,
  escalation_action VARCHAR(20) DEFAULT 'ESCALATE' CHECK (escalation_action IN ('ESCALATE', 'AUTO_APPROVE', 'REJECT', 'NOTIFY')),
  
  -- Parallel approval support
  requires_all_approvers BOOLEAN DEFAULT true, -- For parallel approvals
  parallel_group_id INTEGER, -- Group parallel approvers
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(customer_id, document_type, level_number),
  CHECK (amount_threshold_max IS NULL OR amount_threshold_max >= amount_threshold_min)
);

-- 2. Approval level templates for quick setup
CREATE TABLE approval_level_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_name VARCHAR(100) NOT NULL,
  template_description TEXT,
  customer_type VARCHAR(20), -- SMALL, MEDIUM, LARGE, ENTERPRISE
  industry_type VARCHAR(50), -- CONSTRUCTION, MANUFACTURING, SERVICES
  
  -- Template configuration
  template_levels JSONB NOT NULL, -- Array of level configurations
  
  -- Usage tracking
  usage_count INTEGER DEFAULT 0,
  is_public BOOLEAN DEFAULT true,
  created_by UUID,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Sample templates for different scenarios
INSERT INTO approval_level_templates (template_name, template_description, customer_type, industry_type, template_levels) VALUES
-- Simple 1-level approval
('Single Approval', 'Simple one-level approval for small organizations', 'SMALL', 'ANY', 
 '[{"level": 1, "name": "Manager Approval", "role": "MANAGER", "min": 0, "max": null}]'),

-- Standard 2-level approval
('Standard 2-Level', 'Traditional supervisor-manager approval', 'MEDIUM', 'ANY',
 '[{"level": 1, "name": "Supervisor Approval", "role": "SUPERVISOR", "min": 0, "max": 10000}, 
   {"level": 2, "name": "Manager Approval", "role": "MANAGER", "min": 10000, "max": null}]'),

-- Construction 3-level approval
('Construction 3-Level', 'Site-based approval for construction', 'MEDIUM', 'CONSTRUCTION',
 '[{"level": 1, "name": "Site Supervisor", "role": "SITE_SUPERVISOR", "min": 0, "max": 5000},
   {"level": 2, "name": "Project Manager", "role": "PROJECT_MANAGER", "min": 5000, "max": 50000},
   {"level": 3, "name": "Operations Manager", "role": "OPERATIONS_MANAGER", "min": 50000, "max": null}]'),

-- Enterprise 5-level approval
('Enterprise 5-Level', 'Complex multi-level approval for large organizations', 'ENTERPRISE', 'ANY',
 '[{"level": 1, "name": "Team Lead", "role": "TEAM_LEAD", "min": 0, "max": 2000},
   {"level": 2, "name": "Supervisor", "role": "SUPERVISOR", "min": 2000, "max": 10000},
   {"level": 3, "name": "Manager", "role": "MANAGER", "min": 10000, "max": 50000},
   {"level": 4, "name": "Director", "role": "DIRECTOR", "min": 50000, "max": 200000},
   {"level": 5, "name": "VP/CEO", "role": "EXECUTIVE", "min": 200000, "max": null}]'),

-- Department-specific approval
('Department Based', 'Different approval levels by department', 'LARGE', 'ANY',
 '[{"level": 1, "name": "Department Head", "role": "DEPT_HEAD", "min": 0, "max": 25000, "department_filter": "ANY"},
   {"level": 2, "name": "Division Manager", "role": "DIVISION_MANAGER", "min": 25000, "max": 100000},
   {"level": 3, "name": "General Manager", "role": "GENERAL_MANAGER", "min": 100000, "max": null}]'),

-- Parallel approval example
('Parallel Approval', 'Technical and financial approval in parallel', 'LARGE', 'CONSTRUCTION',
 '[{"level": 1, "name": "Technical Review", "role": "TECHNICAL_MANAGER", "min": 0, "max": null, "parallel_group": 1, "requires_all": false},
   {"level": 1, "name": "Financial Review", "role": "FINANCE_MANAGER", "min": 0, "max": null, "parallel_group": 1, "requires_all": false},
   {"level": 2, "name": "Executive Approval", "role": "GENERAL_MANAGER", "min": 50000, "max": null}]');

-- 3. Customer approval configuration
CREATE TABLE customer_approval_configuration (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  config_name VARCHAR(100) NOT NULL DEFAULT 'Default Configuration',
  
  -- Document type specific settings
  document_type VARCHAR(20) NOT NULL,
  
  -- Configuration source
  template_id UUID REFERENCES approval_level_templates(id),
  is_custom_config BOOLEAN DEFAULT false,
  
  -- Override settings
  global_timeout_hours INTEGER DEFAULT 24,
  allow_delegation BOOLEAN DEFAULT true,
  require_comments BOOLEAN DEFAULT false,
  send_notifications BOOLEAN DEFAULT true,
  
  -- Emergency/bypass settings
  emergency_bypass_enabled BOOLEAN DEFAULT false,
  emergency_bypass_role VARCHAR(50),
  emergency_bypass_limit DECIMAL(15,2),
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(customer_id, document_type, config_name)
);

-- 4. Function to apply template to customer
CREATE OR REPLACE FUNCTION apply_approval_template(
  p_customer_id UUID,
  p_document_type VARCHAR(20),
  p_template_id UUID,
  p_config_name VARCHAR(100) DEFAULT 'Default Configuration'
) RETURNS JSONB AS $$
DECLARE
  v_template RECORD;
  v_level JSONB;
  v_levels_created INTEGER := 0;
  v_config_id UUID;
BEGIN
  -- Get template
  SELECT * INTO v_template FROM approval_level_templates WHERE id = p_template_id;
  
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Template not found');
  END IF;
  
  -- Create configuration record
  INSERT INTO customer_approval_configuration (customer_id, document_type, config_name, template_id)
  VALUES (p_customer_id, p_document_type, p_config_name, p_template_id)
  RETURNING id INTO v_config_id;
  
  -- Clear existing levels for this document type
  DELETE FROM flexible_approval_levels 
  WHERE customer_id = p_customer_id AND document_type = p_document_type;
  
  -- Create approval levels from template
  FOR v_level IN SELECT * FROM jsonb_array_elements(v_template.template_levels)
  LOOP
    INSERT INTO flexible_approval_levels (
      customer_id,
      document_type,
      level_number,
      level_name,
      approver_role,
      amount_threshold_min,
      amount_threshold_max,
      category_filter,
      department_filter,
      parallel_group_id,
      requires_all_approvers
    ) VALUES (
      p_customer_id,
      p_document_type,
      (v_level->>'level')::INTEGER,
      v_level->>'name',
      v_level->>'role',
      COALESCE((v_level->>'min')::DECIMAL, 0),
      (v_level->>'max')::DECIMAL,
      v_level->>'category_filter',
      v_level->>'department_filter',
      (v_level->>'parallel_group')::INTEGER,
      COALESCE((v_level->>'requires_all')::BOOLEAN, true)
    );
    
    v_levels_created := v_levels_created + 1;
  END LOOP;
  
  -- Update template usage count
  UPDATE approval_level_templates 
  SET usage_count = usage_count + 1 
  WHERE id = p_template_id;
  
  RETURN jsonb_build_object(
    'success', true, 
    'config_id', v_config_id,
    'levels_created', v_levels_created,
    'template_name', v_template.template_name
  );
END;
$$ LANGUAGE plpgsql;

-- 5. Function to get approval path for a request
CREATE OR REPLACE FUNCTION get_approval_path(
  p_customer_id UUID,
  p_document_type VARCHAR(20),
  p_amount DECIMAL(15,2),
  p_category VARCHAR(50) DEFAULT NULL,
  p_department VARCHAR(50) DEFAULT NULL
) RETURNS TABLE (
  level_number INTEGER,
  level_name VARCHAR(100),
  approver_role VARCHAR(50),
  is_required BOOLEAN,
  parallel_group_id INTEGER,
  timeout_hours INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    fal.level_number,
    fal.level_name,
    fal.approver_role,
    fal.is_mandatory,
    fal.parallel_group_id,
    fal.timeout_hours
  FROM flexible_approval_levels fal
  WHERE fal.customer_id = p_customer_id
    AND fal.document_type = p_document_type
    AND fal.is_active = true
    AND (fal.amount_threshold_min IS NULL OR p_amount >= fal.amount_threshold_min)
    AND (fal.amount_threshold_max IS NULL OR p_amount < fal.amount_threshold_max)
    AND (fal.category_filter IS NULL OR fal.category_filter = p_category)
    AND (fal.department_filter IS NULL OR fal.department_filter = p_department)
  ORDER BY fal.level_number, fal.parallel_group_id NULLS FIRST;
END;
$$ LANGUAGE plpgsql;

-- 6. Custom approval level builder
CREATE OR REPLACE FUNCTION create_custom_approval_level(
  p_customer_id UUID,
  p_document_type VARCHAR(20),
  p_level_number INTEGER,
  p_level_name VARCHAR(100),
  p_approver_role VARCHAR(50),
  p_amount_min DECIMAL(15,2) DEFAULT 0,
  p_amount_max DECIMAL(15,2) DEFAULT NULL,
  p_category_filter VARCHAR(50) DEFAULT NULL,
  p_department_filter VARCHAR(50) DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  v_level_id UUID;
BEGIN
  INSERT INTO flexible_approval_levels (
    customer_id,
    document_type,
    level_number,
    level_name,
    approver_role,
    amount_threshold_min,
    amount_threshold_max,
    category_filter,
    department_filter
  ) VALUES (
    p_customer_id,
    p_document_type,
    p_level_number,
    p_level_name,
    p_approver_role,
    p_amount_min,
    p_amount_max,
    p_category_filter,
    p_department_filter
  ) RETURNING id INTO v_level_id;
  
  RETURN v_level_id;
END;
$$ LANGUAGE plpgsql;

-- 7. Sample customer setups using templates
SELECT 'SETTING UP FLEXIBLE APPROVAL LEVELS:' as info;

-- Small company - MR with single approval
SELECT apply_approval_template(
  '550e8400-e29b-41d4-a716-446655440001'::UUID,
  'MATERIAL_REQ',
  (SELECT id FROM approval_level_templates WHERE template_name = 'Standard 2-Level'),
  'MR Standard Approval'
) as small_company_mr;

-- Medium company - PR with 3-level approval
SELECT apply_approval_template(
  '550e8400-e29b-41d4-a716-446655440002'::UUID,
  'PURCHASE_REQ',
  (SELECT id FROM approval_level_templates WHERE template_name = 'Construction 3-Level'),
  'PR Construction Approval'
) as medium_company_pr;

-- Large company - PO with enterprise approval
SELECT apply_approval_template(
  '550e8400-e29b-41d4-a716-446655440003'::UUID,
  'PURCHASE_ORDER',
  (SELECT id FROM approval_level_templates WHERE template_name = 'Enterprise 5-Level'),
  'PO Enterprise Approval'
) as large_company_po;

-- 8. Test approval path generation
SELECT 'TESTING APPROVAL PATHS:' as info;

-- Test $15,000 Material Request for small company
SELECT * FROM get_approval_path(
  '550e8400-e29b-41d4-a716-446655440001'::UUID,
  'MATERIAL_REQ',
  15000
) as small_company_path;

-- Test $75,000 Purchase Requisition for medium company
SELECT * FROM get_approval_path(
  '550e8400-e29b-41d4-a716-446655440002'::UUID,
  'PURCHASE_REQ', 
  75000
) as medium_company_path;

-- 9. Configuration summary view
CREATE VIEW customer_approval_summary AS
SELECT 
  cac.customer_id,
  cac.document_type,
  cac.config_name,
  alt.template_name,
  COUNT(fal.id) as total_levels,
  MIN(fal.amount_threshold_min) as min_threshold,
  MAX(fal.amount_threshold_max) as max_threshold,
  STRING_AGG(fal.approver_role, ' → ' ORDER BY fal.level_number) as approval_chain,
  cac.is_active
FROM customer_approval_configuration cac
LEFT JOIN approval_level_templates alt ON cac.template_id = alt.id
LEFT JOIN flexible_approval_levels fal ON cac.customer_id = fal.customer_id 
  AND cac.document_type = fal.document_type
WHERE cac.is_active = true
GROUP BY cac.customer_id, cac.document_type, cac.config_name, alt.template_name, cac.is_active;

-- Display summary
SELECT * FROM customer_approval_summary ORDER BY customer_id, document_type;

COMMENT ON TABLE flexible_approval_levels IS 'Unlimited, flexible approval levels for any document type with configurable thresholds and criteria';
COMMENT ON TABLE approval_level_templates IS 'Pre-built approval level templates for quick customer setup';
COMMENT ON FUNCTION apply_approval_template IS 'Apply a template to create approval levels for a customer and document type';
COMMENT ON FUNCTION get_approval_path IS 'Determine the approval path for a specific request based on amount and criteria';