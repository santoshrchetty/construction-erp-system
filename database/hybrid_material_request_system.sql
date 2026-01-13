-- Configurable Material Request System
-- Supports both Traditional and Intelligent approaches based on customer preference

-- 1. Customer configuration for material request modes
CREATE TABLE customer_material_request_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  config_name VARCHAR(100) NOT NULL DEFAULT 'Default Configuration',
  
  -- Mode selection
  request_mode VARCHAR(20) NOT NULL DEFAULT 'TRADITIONAL' CHECK (request_mode IN ('TRADITIONAL', 'INTELLIGENT', 'HYBRID')),
  
  -- Intelligence features (can be enabled individually)
  enable_availability_check BOOLEAN DEFAULT false,
  enable_usage_pattern_analysis BOOLEAN DEFAULT false,
  enable_cost_optimization BOOLEAN DEFAULT false,
  enable_aging_stock_alerts BOOLEAN DEFAULT false,
  enable_budget_validation BOOLEAN DEFAULT false,
  enable_quantity_validation BOOLEAN DEFAULT false,
  enable_alternative_suggestions BOOLEAN DEFAULT false,
  enable_timing_optimization BOOLEAN DEFAULT false,
  
  -- Traditional mode settings
  simple_approval_workflow BOOLEAN DEFAULT true,
  skip_validations BOOLEAN DEFAULT true,
  auto_approve_threshold DECIMAL(15,2) DEFAULT 0,
  
  -- Hybrid mode settings
  intelligence_level VARCHAR(20) DEFAULT 'BASIC' CHECK (intelligence_level IN ('BASIC', 'STANDARD', 'ADVANCED')),
  user_can_override BOOLEAN DEFAULT true,
  show_recommendations BOOLEAN DEFAULT true,
  enforce_recommendations BOOLEAN DEFAULT false,
  
  -- Migration settings
  migration_phase VARCHAR(20) DEFAULT 'NONE' CHECK (migration_phase IN ('NONE', 'PILOT', 'GRADUAL', 'COMPLETE')),
  pilot_user_groups TEXT[], -- Array of user groups in pilot
  migration_start_date DATE,
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(customer_id, config_name)
);

-- 2. Mode-specific request processing
CREATE TABLE material_request_processing_modes (
  mode_name VARCHAR(20) PRIMARY KEY,
  description TEXT,
  features_enabled JSONB,
  approval_complexity VARCHAR(20),
  user_experience VARCHAR(20),
  implementation_effort VARCHAR(20)
);

INSERT INTO material_request_processing_modes VALUES
('TRADITIONAL', 'Simple request-approve-procure workflow', 
 '{"validations": false, "intelligence": false, "recommendations": false, "simple_ui": true}',
 'LOW', 'SIMPLE', 'MINIMAL'),

('INTELLIGENT', 'Full AI-driven optimization and validation',
 '{"validations": true, "intelligence": true, "recommendations": true, "learning": true, "advanced_ui": true}',
 'HIGH', 'GUIDED', 'SIGNIFICANT'),

('HYBRID', 'Traditional workflow with optional intelligence features',
 '{"validations": "optional", "intelligence": "advisory", "recommendations": "optional", "flexible_ui": true}',
 'MEDIUM', 'FLEXIBLE', 'MODERATE');

-- 3. Feature-specific configuration
CREATE TABLE intelligence_feature_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_config_id UUID NOT NULL REFERENCES customer_material_request_config(id) ON DELETE CASCADE,
  feature_name VARCHAR(50) NOT NULL,
  is_enabled BOOLEAN DEFAULT false,
  enforcement_level VARCHAR(20) DEFAULT 'ADVISORY' CHECK (enforcement_level IN ('DISABLED', 'ADVISORY', 'WARNING', 'BLOCKING')),
  configuration_params JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 4. Migration pathway configuration
CREATE TABLE migration_pathways (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  pathway_name VARCHAR(100) NOT NULL,
  current_phase VARCHAR(20) NOT NULL,
  target_phase VARCHAR(20) NOT NULL,
  
  -- Phase definitions
  phase_1_config JSONB, -- Traditional
  phase_2_config JSONB, -- Hybrid Basic
  phase_3_config JSONB, -- Hybrid Advanced
  phase_4_config JSONB, -- Full Intelligent
  
  -- Timeline
  phase_duration_weeks INTEGER DEFAULT 4,
  current_phase_start_date DATE,
  estimated_completion_date DATE,
  
  -- Success criteria
  success_metrics JSONB,
  rollback_criteria JSONB,
  
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 5. Unified request processing function
CREATE OR REPLACE FUNCTION process_material_request(
  p_request_data JSONB,
  p_customer_id UUID,
  p_user_id UUID
) RETURNS TABLE (
  request_id UUID,
  processing_mode VARCHAR(20),
  validations_applied JSONB,
  recommendations JSONB,
  approval_path JSONB,
  next_steps TEXT[]
) AS $$
DECLARE
  v_config RECORD;
  v_request_id UUID;
  v_validations JSONB := '{}';
  v_recommendations JSONB := '{}';
  v_approval_path JSONB := '{}';
  v_next_steps TEXT[] := '{}';
BEGIN
  -- Get customer configuration
  SELECT * INTO v_config 
  FROM customer_material_request_config 
  WHERE customer_id = p_customer_id AND is_active = true
  LIMIT 1;
  
  -- Create base request
  INSERT INTO material_requests (request_number, request_type, requested_by, created_by)
  VALUES (
    'REQ-' || to_char(NOW(), 'YYYYMMDD') || '-' || LPAD(nextval('request_sequence')::TEXT, 4, '0'),
    (p_request_data->>'request_type')::VARCHAR,
    p_user_id,
    p_user_id
  ) RETURNING id INTO v_request_id;
  
  -- Process based on mode
  CASE v_config.request_mode
    WHEN 'TRADITIONAL' THEN
      -- Simple processing
      v_validations := '{"mode": "traditional", "checks": "basic"}';
      v_approval_path := '{"levels": 2, "complexity": "simple"}';
      v_next_steps := ARRAY['Submit for supervisor approval'];
      
    WHEN 'INTELLIGENT' THEN
      -- Full intelligence processing
      v_validations := perform_intelligent_validations(v_request_id, p_request_data);
      v_recommendations := generate_intelligent_recommendations(v_request_id, p_request_data);
      v_approval_path := determine_intelligent_approval_path(v_request_id, p_request_data);
      v_next_steps := ARRAY['Review recommendations', 'Address validations', 'Submit for approval'];
      
    WHEN 'HYBRID' THEN
      -- Selective intelligence based on enabled features
      IF v_config.enable_availability_check THEN
        v_validations := v_validations || check_availability(p_request_data);
      END IF;
      
      IF v_config.enable_cost_optimization THEN
        v_recommendations := v_recommendations || suggest_cost_optimizations(p_request_data);
      END IF;
      
      v_approval_path := '{"levels": 3, "complexity": "moderate", "intelligence": "advisory"}';
      v_next_steps := ARRAY['Review suggestions (optional)', 'Submit for approval'];
  END CASE;
  
  RETURN QUERY SELECT 
    v_request_id,
    v_config.request_mode,
    v_validations,
    v_recommendations,
    v_approval_path,
    v_next_steps;
END;
$$ LANGUAGE plpgsql;

-- 6. Customer onboarding templates
CREATE TABLE customer_onboarding_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_name VARCHAR(100) NOT NULL,
  customer_type VARCHAR(50), -- SMALL, MEDIUM, LARGE, ENTERPRISE
  industry_focus VARCHAR(50), -- RESIDENTIAL, COMMERCIAL, INFRASTRUCTURE
  recommended_mode VARCHAR(20),
  template_config JSONB,
  migration_plan JSONB,
  description TEXT,
  is_active BOOLEAN DEFAULT true
);

INSERT INTO customer_onboarding_templates VALUES
-- Small construction companies
('Small Company - Traditional', 'SMALL', 'RESIDENTIAL', 'TRADITIONAL',
 '{"request_mode": "TRADITIONAL", "simple_approval_workflow": true, "auto_approve_threshold": 5000}',
 '{"phases": ["traditional_only"], "timeline": "immediate"}',
 'Simple workflow for small residential contractors'),

-- Medium companies - gradual adoption
('Medium Company - Hybrid Start', 'MEDIUM', 'COMMERCIAL', 'HYBRID',
 '{"request_mode": "HYBRID", "intelligence_level": "BASIC", "enable_availability_check": true, "enable_budget_validation": true}',
 '{"phases": ["traditional", "hybrid_basic", "hybrid_advanced"], "timeline": "12_weeks"}',
 'Gradual intelligence adoption for medium commercial builders'),

-- Large companies - full intelligence
('Large Company - Full Intelligence', 'LARGE', 'INFRASTRUCTURE', 'INTELLIGENT',
 '{"request_mode": "INTELLIGENT", "all_features": true, "enforcement_level": "WARNING"}',
 '{"phases": ["pilot", "gradual_rollout", "full_deployment"], "timeline": "16_weeks"}',
 'Complete intelligent system for large infrastructure projects'),

-- Enterprise - customized approach
('Enterprise - Customized', 'ENTERPRISE', 'MIXED', 'HYBRID',
 '{"request_mode": "HYBRID", "intelligence_level": "ADVANCED", "user_can_override": true, "department_specific": true}',
 '{"phases": ["pilot_departments", "phased_rollout", "full_deployment"], "timeline": "24_weeks"}',
 'Flexible approach for enterprise customers with multiple divisions');

-- 7. Feature adoption tracking
CREATE TABLE feature_adoption_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  feature_name VARCHAR(50) NOT NULL,
  adoption_date DATE NOT NULL,
  usage_frequency INTEGER DEFAULT 0, -- Times used per month
  user_satisfaction_score DECIMAL(3,2), -- 1-5 rating
  business_impact_score DECIMAL(3,2), -- 1-5 rating
  issues_reported INTEGER DEFAULT 0,
  rollback_requested BOOLEAN DEFAULT false,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 8. Configuration management API structure
CREATE VIEW customer_configuration_summary AS
SELECT 
  c.customer_id,
  c.config_name,
  c.request_mode,
  c.intelligence_level,
  
  -- Count enabled features
  (CASE WHEN c.enable_availability_check THEN 1 ELSE 0 END +
   CASE WHEN c.enable_usage_pattern_analysis THEN 1 ELSE 0 END +
   CASE WHEN c.enable_cost_optimization THEN 1 ELSE 0 END +
   CASE WHEN c.enable_aging_stock_alerts THEN 1 ELSE 0 END +
   CASE WHEN c.enable_budget_validation THEN 1 ELSE 0 END +
   CASE WHEN c.enable_quantity_validation THEN 1 ELSE 0 END +
   CASE WHEN c.enable_alternative_suggestions THEN 1 ELSE 0 END +
   CASE WHEN c.enable_timing_optimization THEN 1 ELSE 0 END) as features_enabled_count,
   
  -- Migration status
  c.migration_phase,
  c.migration_start_date,
  
  -- Adoption metrics
  COALESCE(AVG(fam.user_satisfaction_score), 0) as avg_satisfaction,
  COALESCE(AVG(fam.business_impact_score), 0) as avg_business_impact,
  COALESCE(SUM(fam.usage_frequency), 0) as total_monthly_usage
  
FROM customer_material_request_config c
LEFT JOIN feature_adoption_metrics fam ON c.customer_id = fam.customer_id
WHERE c.is_active = true
GROUP BY c.customer_id, c.config_name, c.request_mode, c.intelligence_level, 
         c.migration_phase, c.migration_start_date,
         c.enable_availability_check, c.enable_usage_pattern_analysis, c.enable_cost_optimization,
         c.enable_aging_stock_alerts, c.enable_budget_validation, c.enable_quantity_validation,
         c.enable_alternative_suggestions, c.enable_timing_optimization;

-- 9. Sample customer configurations
INSERT INTO customer_material_request_config (customer_id, config_name, request_mode, intelligence_level) VALUES
-- Traditional customer
('550e8400-e29b-41d4-a716-446655440001', 'Simple Traditional', 'TRADITIONAL', 'BASIC'),

-- Hybrid customer
('550e8400-e29b-41d4-a716-446655440002', 'Gradual Adoption', 'HYBRID', 'STANDARD'),

-- Advanced customer  
('550e8400-e29b-41d4-a716-446655440003', 'Full Intelligence', 'INTELLIGENT', 'ADVANCED');

-- Enable selective features for hybrid customer
INSERT INTO intelligence_feature_config (customer_config_id, feature_name, is_enabled, enforcement_level) 
SELECT id, 'availability_check', true, 'WARNING' FROM customer_material_request_config WHERE config_name = 'Gradual Adoption'
UNION ALL
SELECT id, 'budget_validation', true, 'BLOCKING' FROM customer_material_request_config WHERE config_name = 'Gradual Adoption'
UNION ALL
SELECT id, 'cost_optimization', true, 'ADVISORY' FROM customer_material_request_config WHERE config_name = 'Gradual Adoption';

-- 10. Implementation summary
SELECT 'IMPLEMENTATION APPROACH SUMMARY:' as info;

SELECT 
  'TRADITIONAL MODE' as approach,
  'Simple request-approve workflow, minimal validations, familiar UX' as description,
  'Immediate deployment, no training required' as benefits,
  'Small companies, change-resistant users' as target_customers;

SELECT 
  'HYBRID MODE' as approach,
  'Traditional workflow with optional intelligence features' as description,
  'Gradual adoption, user choice, flexible migration' as benefits,
  'Medium companies, gradual adopters' as target_customers;

SELECT 
  'INTELLIGENT MODE' as approach,
  'Full AI-driven optimization, comprehensive validations' as description,
  'Maximum cost savings, waste reduction, optimal decisions' as benefits,
  'Large companies, innovation-focused organizations' as target_customers;

COMMENT ON TABLE customer_material_request_config IS 'Customer-specific configuration for traditional vs intelligent material request processing';
COMMENT ON TABLE migration_pathways IS 'Structured migration paths from traditional to intelligent approaches';
COMMENT ON FUNCTION process_material_request IS 'Unified processing function that adapts behavior based on customer configuration';