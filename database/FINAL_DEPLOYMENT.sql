-- FINAL DEPLOYMENT SCRIPT - Run each file separately
-- Universal Approval Engine 100% Implementation

-- Step 1: Enhanced approval policies with organizational context (safe version)
-- Add columns only if they don't exist
DO $$ 
BEGIN
    -- Add company_code if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='company_code') THEN
        ALTER TABLE approval_policies ADD COLUMN company_code VARCHAR(10);
    END IF;
    
    -- Add country_code if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='country_code') THEN
        ALTER TABLE approval_policies ADD COLUMN country_code VARCHAR(3);
    END IF;
    
    -- Add plant_code if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='plant_code') THEN
        ALTER TABLE approval_policies ADD COLUMN plant_code VARCHAR(20);
    END IF;
    
    -- Add purchase_org if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='purchase_org') THEN
        ALTER TABLE approval_policies ADD COLUMN purchase_org VARCHAR(20);
    END IF;
    
    -- Add project_code if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='project_code') THEN
        ALTER TABLE approval_policies ADD COLUMN project_code VARCHAR(30);
    END IF;
    
    -- Add location_code if not exists
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='location_code') THEN
        ALTER TABLE approval_policies ADD COLUMN location_code VARCHAR(20);
    END IF;
    
    -- Add new context fields
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='selected_countries') THEN
        ALTER TABLE approval_policies ADD COLUMN selected_countries JSONB;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='selected_departments') THEN
        ALTER TABLE approval_policies ADD COLUMN selected_departments JSONB;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='selected_storage_locations') THEN
        ALTER TABLE approval_policies ADD COLUMN selected_storage_locations JSONB;
    END IF;
    
    -- Add multi-selection fields
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='selected_plants') THEN
        ALTER TABLE approval_policies ADD COLUMN selected_plants JSONB;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='selected_purchase_orgs') THEN
        ALTER TABLE approval_policies ADD COLUMN selected_purchase_orgs JSONB;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='selected_projects') THEN
        ALTER TABLE approval_policies ADD COLUMN selected_projects JSONB;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='custom_fields') THEN
        ALTER TABLE approval_policies ADD COLUMN custom_fields JSONB;
    END IF;
END $$;

-- Step 2: Create dynamic field tables
CREATE TABLE IF NOT EXISTS approval_field_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    field_name VARCHAR(50) NOT NULL,
    field_label VARCHAR(100) NOT NULL,
    field_type VARCHAR(20) NOT NULL,
    field_category VARCHAR(30),
    is_required BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS approval_field_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    field_definition_id UUID NOT NULL REFERENCES approval_field_definitions(id),
    option_value VARCHAR(100) NOT NULL,
    option_label VARCHAR(200) NOT NULL,
    option_description TEXT,
    parent_option_id UUID REFERENCES approval_field_options(id),
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 3: Enhanced field definitions with proper hierarchy
INSERT INTO approval_field_definitions (
    customer_id, field_name, field_label, field_type, field_category, is_required, display_order
) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'country_code', 'Countries', 'MULTI_SELECT', 'GEOGRAPHIC', false, 1),
('550e8400-e29b-41d4-a716-446655440001', 'department_code', 'Departments', 'MULTI_SELECT', 'ORGANIZATIONAL', false, 2),
('550e8400-e29b-41d4-a716-446655440001', 'plant_code', 'Plants', 'MULTI_SELECT', 'ORGANIZATIONAL', false, 3),
('550e8400-e29b-41d4-a716-446655440001', 'storage_location_code', 'Storage Locations', 'MULTI_SELECT', 'OPERATIONAL', false, 4),
('550e8400-e29b-41d4-a716-446655440001', 'purchase_org', 'Purchase Organizations', 'MULTI_SELECT', 'OPERATIONAL', false, 5),
('550e8400-e29b-41d4-a716-446655440001', 'project_code', 'Projects', 'MULTI_SELECT', 'PROJECT', false, 6)
ON CONFLICT DO NOTHING;

-- Step 4: Enhanced field options with full hierarchy
INSERT INTO approval_field_options (
    customer_id, field_definition_id, option_value, option_label, option_description, display_order
) VALUES
-- Countries
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'country_code'), 
 'USA', 'United States', 'US operations and facilities', 1),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'country_code'), 
 'CAN', 'Canada', 'Canadian operations and facilities', 2),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'country_code'), 
 'MEX', 'Mexico', 'Mexican operations and facilities', 3),

-- Departments
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'department_code'), 
 'FINANCE', 'Finance Department', 'Financial operations and procurement', 1),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'department_code'), 
 'OPERATIONS', 'Operations Department', 'Construction and field operations', 2),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'department_code'), 
 'SAFETY', 'Safety Department', 'Safety and compliance operations', 3),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'department_code'), 
 'QUALITY', 'Quality Department', 'Quality assurance and control', 4),

-- Plants
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'plant_code'), 
 'PLANT_NYC', 'NYC Plant - Manhattan', 'Main NYC construction facility', 1),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'plant_code'), 
 'PLANT_CHI', 'Chicago Plant - Downtown', 'Chicago construction facility', 2),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'plant_code'), 
 'PLANT_LA', 'Los Angeles Plant - West Coast', 'West coast operations', 3),

-- Storage Locations
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'storage_location_code'), 
 'YARD_A', 'Yard A - General Storage', 'Main material storage yard', 1),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'storage_location_code'), 
 'SECURE_1', 'Secure Storage 1', 'High-value equipment storage', 2),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'storage_location_code'), 
 'HAZMAT_1', 'Hazmat Storage 1', 'Hazardous materials storage', 3),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'storage_location_code'), 
 'WAREHOUSE_A', 'Warehouse A', 'Indoor warehouse storage', 4),

-- Purchase Organizations
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'purchase_org'), 
 'PO_CONSTRUCTION', 'Construction Procurement', 'Main construction purchasing', 1),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'purchase_org'), 
 'PO_MAINTENANCE', 'Maintenance Procurement', 'Equipment maintenance purchasing', 2),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'purchase_org'), 
 'PO_SERVICES', 'Services Procurement', 'Professional services purchasing', 3),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'purchase_org'), 
 'PO_SAFETY', 'Safety Procurement', 'Safety equipment and services', 4),

-- Projects
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'project_code'), 
 'PROJ_ALPHA_2024', 'Project Alpha 2024 - Office Complex', 'Downtown office complex project', 1),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'project_code'), 
 'PROJ_BETA_2024', 'Project Beta 2024 - Residential Tower', 'High-rise residential project', 2),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'project_code'), 
 'PROJ_GAMMA_2024', 'Project Gamma 2024 - Infrastructure', 'Infrastructure development project', 3)
ON CONFLICT DO NOTHING;

-- Step 5: Add missing object types
INSERT INTO approval_object_types (
    customer_id, object_type, object_category, object_name, description,
    default_strategy, required_fields, validation_rules, form_config
) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'PR', 'FINANCIAL', 'Purchase Requisition', 'Purchase requisitions for procurement requests', 'ROLE_BASED',
 '[]', '{}', '{}'),
('550e8400-e29b-41d4-a716-446655440001', 'CLAIM', 'FINANCIAL', 'Claims Processing', 'Insurance and warranty claims processing', 'AMOUNT_BASED',
 '[]', '{}', '{}')
ON CONFLICT DO NOTHING;

-- Step 6: Update existing policies with object categories
UPDATE approval_policies 
SET object_category = 'FINANCIAL',
    object_subtype = CASE 
        WHEN approval_object_type = 'PO' THEN 'PROCUREMENT'
        WHEN approval_object_type = 'MR' THEN 'MATERIAL_REQUEST'
        WHEN approval_object_type = 'PR' THEN 'PURCHASE_REQUISITION'
        WHEN approval_object_type = 'CLAIM' THEN 'CLAIMS_PROCESSING'
        ELSE 'STANDARD'
    END
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
  AND object_category IS NULL;

-- Step 7: Enhanced context specificity with weighted hierarchy
DO $$
BEGIN
    -- Drop existing context_specificity if exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='context_specificity') THEN
        ALTER TABLE approval_policies DROP COLUMN context_specificity;
    END IF;
    
    -- Add weighted context specificity calculation
    ALTER TABLE approval_policies ADD COLUMN context_specificity INTEGER GENERATED ALWAYS AS (
        COALESCE(jsonb_array_length(selected_countries), 0) * 6 +
        COALESCE(jsonb_array_length(selected_departments), 0) * 5 +
        COALESCE(jsonb_array_length(selected_plants), 0) * 4 +
        COALESCE(jsonb_array_length(selected_storage_locations), 0) * 3 +
        COALESCE(jsonb_array_length(selected_purchase_orgs), 0) * 2 +
        COALESCE(jsonb_array_length(selected_projects), 0) * 1
    ) STORED;
END $$;

-- Step 8: Create optimized index for hierarchical context lookup
DROP INDEX IF EXISTS idx_policies_sparse_context;
CREATE INDEX IF NOT EXISTS idx_policies_hierarchical_context ON approval_policies 
(customer_id, approval_object_type, approval_object_document_type, context_specificity DESC, priority_order ASC);

-- Step 9: Test policies with enhanced context hierarchy
INSERT INTO approval_policies (
    id, customer_id, policy_name, approval_object_type, approval_object_document_type,
    object_category, approval_strategy, approval_pattern, amount_thresholds,
    company_code, country_code, 
    selected_countries, selected_departments, selected_plants, 
    selected_storage_locations, selected_purchase_orgs, selected_projects,
    is_active, created_at
) VALUES 
-- Global Policy (NULL context = applies everywhere)
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Global PO Policy', 'PO', 'NB', 'FINANCIAL', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 1000000, "currency": "USD"}',
 'C001', 'USA', NULL, NULL, NULL, NULL, NULL, NULL, true, NOW()),

-- US Operations Policy
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'US Operations PO Policy', 'PO', 'NB', 'FINANCIAL', 'HYBRID', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 750000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', NULL, NULL, NULL, NULL, NULL, true, NOW()),

-- Safety Department Policy
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Safety Department PO Policy', 'PO', 'NB', 'FINANCIAL', 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 500000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', '["SAFETY"]', NULL, NULL, '["PO_SAFETY"]', NULL, true, NOW())
ON CONFLICT DO NOTHING;

-- Step 10: Verify enhanced context hierarchy
SELECT 
    policy_name,
    approval_object_type,
    CASE WHEN selected_countries IS NULL THEN 'Global' ELSE selected_countries::text END as countries,
    CASE WHEN selected_departments IS NULL THEN 'All Depts' ELSE selected_departments::text END as departments,
    CASE WHEN selected_plants IS NULL THEN 'All Plants' ELSE selected_plants::text END as plants,
    context_specificity
FROM approval_policies 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
  AND approval_object_type = 'PO'
ORDER BY context_specificity DESC, policy_name;itions WHERE field_name = 'purchase_org'), 
 'PO_CONSTRUCTION', 'Construction Procurement', 'Main construction purchasing', 1),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'purchase_org'), 
 'PO_MAINTENANCE', 'Maintenance Procurement', 'Equipment maintenance purchasing', 2),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'purchase_org'), 
 'PO_SERVICES', 'Services Procurement', 'Professional services purchasing', 3),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'purchase_org'), 
 'PO_SAFETY', 'Safety Procurement', 'Safety equipment and services', 4),

-- Projects
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'project_code'), 
 'PROJ_ALPHA_2024', 'Project Alpha 2024 - Office Complex', 'Downtown office complex project', 1),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'project_code'), 
 'PROJ_BETA_2024', 'Project Beta 2024 - Residential Tower', 'High-rise residential project', 2),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'project_code'), 
 'PROJ_GAMMA_2024', 'Project Gamma 2024 - Infrastructure', 'Infrastructure development project', 3)
ON CONFLICT DO NOTHING;

-- Step 5: Add missing object types
INSERT INTO approval_object_types (
    customer_id, object_type, object_category, object_name, description,
    default_strategy, required_fields, validation_rules, form_config
) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'PR', 'FINANCIAL', 'Purchase Requisition', 'Purchase requisitions for procurement requests', 'ROLE_BASED',
 '[]', '{}', '{}'),
('550e8400-e29b-41d4-a716-446655440001', 'CLAIM', 'FINANCIAL', 'Claims Processing', 'Insurance and warranty claims processing', 'AMOUNT_BASED',
 '[]', '{}', '{}')
ON CONFLICT DO NOTHING;

-- Step 6: Update existing policies with object categories
UPDATE approval_policies 
SET object_category = 'FINANCIAL',
    object_subtype = CASE 
        WHEN approval_object_type = 'PO' THEN 'PROCUREMENT'
        WHEN approval_object_type = 'MR' THEN 'MATERIAL_REQUEST'
        WHEN approval_object_type = 'PR' THEN 'PURCHASE_REQUISITION'
        WHEN approval_object_type = 'CLAIM' THEN 'CLAIMS_PROCESSING'
        ELSE 'STANDARD'
    END
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
  AND object_category IS NULL;
-- Step 7: Verify implementation
SELECT 'Dynamic Fields' as component, COUNT(*) as count FROM approval_field_definitions WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
UNION ALL
SELECT 'Field Options' as component, COUNT(*) as count FROM approval_field_options WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
UNION ALL
SELECT 'Object Types' as component, COUNT(*) as count FROM approval_object_types WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
UNION ALL
SELECT 'Approval Policies' as component, COUNT(*) as count FROM approval_policies WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001';

-- Step 8: Test multi-selection policy creation
INSERT INTO approval_policies (
    id, customer_id, policy_name, approval_object_type, approval_object_document_type,
    object_category, approval_strategy, approval_pattern, amount_thresholds,
    company_code, country_code, selected_plants, selected_purchase_orgs, selected_projects,
    is_active, created_at
) VALUES (
    gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
    'Multi-Plant PO Policy', 'PO', 'NB', 'FINANCIAL', 'ROLE_BASED', 'HIERARCHY_ONLY',
    '{"min": 0, "max": 500000, "currency": "USD"}',
    'C001', 'USA', 
    '["PLANT_NYC", "PLANT_CHI"]', 
    '["PO_CONSTRUCTION", "PO_MAINTENANCE"]', 
    '["PROJ_ALPHA_2024"]',
    true, NOW()
);

-- Step 10: Enhanced context specificity with weighted hierarchy
DO $$
BEGIN
    -- Drop existing context_specificity if exists
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='context_specificity') THEN
        ALTER TABLE approval_policies DROP COLUMN context_specificity;
    END IF;
    
    -- Add weighted context specificity calculation
    ALTER TABLE approval_policies ADD COLUMN context_specificity INTEGER GENERATED ALWAYS AS (
        COALESCE(jsonb_array_length(selected_countries), 0) * 6 +
        COALESCE(jsonb_array_length(selected_departments), 0) * 5 +
        COALESCE(jsonb_array_length(selected_plants), 0) * 4 +
        COALESCE(jsonb_array_length(selected_storage_locations), 0) * 3 +
        COALESCE(jsonb_array_length(selected_purchase_orgs), 0) * 2 +
        COALESCE(jsonb_array_length(selected_projects), 0) * 1
    ) STORED;
END $$;

-- Create optimized index for hierarchical context lookup
DROP INDEX IF EXISTS idx_policies_sparse_context;
CREATE INDEX idx_policies_hierarchical_context ON approval_policies 
(customer_id, approval_object_type, approval_object_document_type, context_specificity DESC, priority_order ASC);

-- Step 11: Test policies with enhanced context hierarchy
INSERT INTO approval_policies (
    id, customer_id, policy_name, approval_object_type, approval_object_document_type,
    object_category, approval_strategy, approval_pattern, amount_thresholds,
    company_code, country_code, 
    selected_countries, selected_departments, selected_plants, 
    selected_storage_locations, selected_purchase_orgs, selected_projects,
    is_active, created_at
) VALUES 
-- Global Policy (NULL context = applies everywhere)
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Global PO Policy', 'PO', 'NB', 'FINANCIAL', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 1000000, "currency": "USD"}',
 'C001', 'USA', NULL, NULL, NULL, NULL, NULL, NULL, true, NOW()),

-- US Operations Policy
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'US Operations PO Policy', 'PO', 'NB', 'FINANCIAL', 'HYBRID', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 750000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', NULL, NULL, NULL, NULL, NULL, true, NOW()),

-- Safety Department Policy
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Safety Department PO Policy', 'PO', 'NB', 'FINANCIAL', 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 500000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', '["SAFETY"]', NULL, NULL, '["PO_SAFETY"]', NULL, true, NOW()),

-- NYC Plant Specific Policy
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'NYC Plant PO Policy', 'PO', 'NB', 'FINANCIAL', 'HYBRID', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 250000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', NULL, '["PLANT_NYC"]', NULL, NULL, NULL, true, NOW()),

-- Hazmat Storage Policy
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Hazmat Storage PO Policy', 'PO', 'NB', 'FINANCIAL', 'HYBRID', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 100000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', '["SAFETY"]', NULL, '["HAZMAT_1"]', '["PO_SAFETY"]', NULL, true, NOW()),

-- Project Alpha Specific Policy
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Project Alpha PO Policy', 'PO', 'NB', 'FINANCIAL', 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 50000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', NULL, '["PLANT_NYC"]', NULL, '["PO_CONSTRUCTION"]', '["PROJ_ALPHA_2024"]', true, NOW())
ON CONFLICT DO NOTHING;

-- Step 12: Verify enhanced context hierarchy
SELECT 
    policy_name,
    approval_object_type,
    CASE WHEN selected_countries IS NULL THEN 'Global' ELSE selected_countries::text END as countries,
    CASE WHEN selected_departments IS NULL THEN 'All Depts' ELSE selected_departments::text END as departments,
    CASE WHEN selected_plants IS NULL THEN 'All Plants' ELSE selected_plants::text END as plants,
    CASE WHEN selected_storage_locations IS NULL THEN 'All Storage' ELSE selected_storage_locations::text END as storage,
    CASE WHEN selected_purchase_orgs IS NULL THEN 'All POs' ELSE selected_purchase_orgs::text END as purchase_orgs,
    CASE WHEN selected_projects IS NULL THEN 'All Projects' ELSE selected_projects::text END as projects,
    context_specificity
FROM approval_policies 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
  AND approval_object_type = 'PO'
ORDER BY context_specificity DESC, policy_name;g for policy optimization
ALTER TABLE approval_policies 
ADD COLUMN IF NOT EXISTS context_specificity INTEGER GENERATED ALWAYS AS (
    COALESCE(jsonb_array_length(selected_plants), 0) +
    COALESCE(jsonb_array_length(selected_purchase_orgs), 0) +
    COALESCE(jsonb_array_length(selected_projects), 0)
) STORED;

-- Create optimized index for sparse context policy lookup
CREATE INDEX IF NOT EXISTS idx_policies_sparse_context ON approval_policies 
(customer_id, approval_object_type, approval_object_document_type, context_specificity DESC, priority_order ASC);

-- Step 11: Insert test policies with sparse context
INSERT INTO approval_policies (
    id, customer_id, policy_name, approval_object_type, approval_object_document_type,
    object_category, approval_strategy, approval_pattern, amount_thresholds,
    company_code, country_code, selected_plants, selected_purchase_orgs, selected_projects,
    is_active, created_at
) VALUES 
-- Global PO Policy (NULL context = applies to all)
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Global PO Policy', 'PO', 'NB', 'FINANCIAL', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 1000000, "currency": "USD"}',
 'C001', 'USA', NULL, NULL, NULL, true, NOW()),

-- NYC Plants Only Policy
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'NYC Plants PO Policy', 'PO', 'NB', 'FINANCIAL', 'HYBRID', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 500000, "currency": "USD"}',
 'C001', 'USA', '["PLANT_NYC"]', NULL, NULL, true, NOW()),

-- Construction Org Specific Policy
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Construction PO Policy', 'PO', 'NB', 'FINANCIAL', 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 250000, "currency": "USD"}',
 'C001', 'USA', NULL, '["PO_CONSTRUCTION"]', NULL, true, NOW()),

-- Project Alpha Specific Policy
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Project Alpha PO Policy', 'PO', 'NB', 'FINANCIAL', 'HYBRID', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 100000, "currency": "USD"}',
 'C001', 'USA', NULL, NULL, '["PROJ_ALPHA_2024"]', true, NOW())
ON CONFLICT DO NOTHING;

-- Step 12: Verify sparse context implementation
SELECT 
    policy_name,
    approval_object_type,
    CASE 
        WHEN selected_plants IS NULL THEN 'Global Plants'
        WHEN jsonb_array_length(selected_plants) = 0 THEN 'No Plants'
        ELSE selected_plants::text
    END as plants_context,
    CASE 
        WHEN selected_purchase_orgs IS NULL THEN 'Global Purchase Orgs'
        WHEN jsonb_array_length(selected_purchase_orgs) = 0 THEN 'No Purchase Orgs'
        ELSE selected_purchase_orgs::text
    END as purchase_orgs_context,
    CASE 
        WHEN selected_projects IS NULL THEN 'Global Projects'
        WHEN jsonb_array_length(selected_projects) = 0 THEN 'No Projects'
        ELSE selected_projects::text
    END as projects_context,
    context_specificity
FROM approval_policies 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
ORDER BY context_specificity DESC, policy_name;ELECT 
    policy_name,
    approval_object_type,
    object_category,
    selected_plants,
    selected_purchase_orgs,
    selected_projects
FROM approval_policies 
WHERE policy_name = 'Multi-Plant PO Policy';

COMMIT;