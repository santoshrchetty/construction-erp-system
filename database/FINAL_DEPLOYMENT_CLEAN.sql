-- FINAL DEPLOYMENT SCRIPT - Universal Approval Engine
-- Enhanced Context Hierarchy Implementation

-- Step 1: Add context fields to approval_policies
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='selected_countries') THEN
        ALTER TABLE approval_policies ADD COLUMN selected_countries JSONB;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='selected_departments') THEN
        ALTER TABLE approval_policies ADD COLUMN selected_departments JSONB;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='selected_plants') THEN
        ALTER TABLE approval_policies ADD COLUMN selected_plants JSONB;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='selected_storage_locations') THEN
        ALTER TABLE approval_policies ADD COLUMN selected_storage_locations JSONB;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='selected_purchase_orgs') THEN
        ALTER TABLE approval_policies ADD COLUMN selected_purchase_orgs JSONB;
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='selected_projects') THEN
        ALTER TABLE approval_policies ADD COLUMN selected_projects JSONB;
    END IF;
END $$;

-- Step 2: Create field definitions table
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

-- Step 3: Create field options table
CREATE TABLE IF NOT EXISTS approval_field_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    field_definition_id UUID NOT NULL REFERENCES approval_field_definitions(id),
    option_value VARCHAR(100) NOT NULL,
    option_label VARCHAR(200) NOT NULL,
    option_description TEXT,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 4: Insert field definitions with unique constraint
DELETE FROM approval_field_definitions WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001';

INSERT INTO approval_field_definitions (
    customer_id, field_name, field_label, field_type, field_category, is_required, display_order
) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'country_code', 'Countries', 'MULTI_SELECT', 'GEOGRAPHIC', false, 1),
('550e8400-e29b-41d4-a716-446655440001', 'department_code', 'Departments', 'MULTI_SELECT', 'ORGANIZATIONAL', false, 2),
('550e8400-e29b-41d4-a716-446655440001', 'plant_code', 'Plants', 'MULTI_SELECT', 'ORGANIZATIONAL', false, 3),
('550e8400-e29b-41d4-a716-446655440001', 'storage_location_code', 'Storage Locations', 'MULTI_SELECT', 'OPERATIONAL', false, 4),
('550e8400-e29b-41d4-a716-446655440001', 'purchase_org', 'Purchase Organizations', 'MULTI_SELECT', 'OPERATIONAL', false, 5),
('550e8400-e29b-41d4-a716-446655440001', 'project_code', 'Projects', 'MULTI_SELECT', 'PROJECT', false, 6);

-- Step 5: Insert field options with variables
DO $$
DECLARE
    country_field_id UUID;
    dept_field_id UUID;
    plant_field_id UUID;
    storage_field_id UUID;
    purchase_field_id UUID;
    project_field_id UUID;
BEGIN
    -- Get field IDs
    SELECT id INTO country_field_id FROM approval_field_definitions WHERE field_name = 'country_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';
    SELECT id INTO dept_field_id FROM approval_field_definitions WHERE field_name = 'department_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';
    SELECT id INTO plant_field_id FROM approval_field_definitions WHERE field_name = 'plant_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';
    SELECT id INTO storage_field_id FROM approval_field_definitions WHERE field_name = 'storage_location_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';
    SELECT id INTO purchase_field_id FROM approval_field_definitions WHERE field_name = 'purchase_org' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';
    SELECT id INTO project_field_id FROM approval_field_definitions WHERE field_name = 'project_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';
    
    -- Delete existing options
    DELETE FROM approval_field_options WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001';
    
    -- Insert field options
    INSERT INTO approval_field_options (customer_id, field_definition_id, option_value, option_label, option_description, display_order) VALUES
    -- Countries
    ('550e8400-e29b-41d4-a716-446655440001', country_field_id, 'USA', 'United States', 'US operations', 1),
    ('550e8400-e29b-41d4-a716-446655440001', country_field_id, 'CAN', 'Canada', 'Canadian operations', 2),
    ('550e8400-e29b-41d4-a716-446655440001', country_field_id, 'MEX', 'Mexico', 'Mexican operations', 3),
    
    -- Departments
    ('550e8400-e29b-41d4-a716-446655440001', dept_field_id, 'FINANCE', 'Finance Department', 'Financial operations', 1),
    ('550e8400-e29b-41d4-a716-446655440001', dept_field_id, 'OPERATIONS', 'Operations Department', 'Construction operations', 2),
    ('550e8400-e29b-41d4-a716-446655440001', dept_field_id, 'SAFETY', 'Safety Department', 'Safety operations', 3),
    ('550e8400-e29b-41d4-a716-446655440001', dept_field_id, 'QUALITY', 'Quality Department', 'Quality assurance', 4),
    
    -- Plants
    ('550e8400-e29b-41d4-a716-446655440001', plant_field_id, 'PLANT_NYC', 'NYC Plant - Manhattan', 'NYC construction facility', 1),
    ('550e8400-e29b-41d4-a716-446655440001', plant_field_id, 'PLANT_CHI', 'Chicago Plant - Downtown', 'Chicago facility', 2),
    ('550e8400-e29b-41d4-a716-446655440001', plant_field_id, 'PLANT_LA', 'Los Angeles Plant', 'West coast operations', 3),
    
    -- Storage Locations
    ('550e8400-e29b-41d4-a716-446655440001', storage_field_id, 'YARD_A', 'Yard A - General Storage', 'Main storage yard', 1),
    ('550e8400-e29b-41d4-a716-446655440001', storage_field_id, 'SECURE_1', 'Secure Storage 1', 'High-value storage', 2),
    ('550e8400-e29b-41d4-a716-446655440001', storage_field_id, 'HAZMAT_1', 'Hazmat Storage 1', 'Hazardous materials', 3),
    
    -- Purchase Organizations
    ('550e8400-e29b-41d4-a716-446655440001', purchase_field_id, 'PO_CONSTRUCTION', 'Construction Procurement', 'Main construction purchasing', 1),
    ('550e8400-e29b-41d4-a716-446655440001', purchase_field_id, 'PO_MAINTENANCE', 'Maintenance Procurement', 'Equipment maintenance', 2),
    ('550e8400-e29b-41d4-a716-446655440001', purchase_field_id, 'PO_SAFETY', 'Safety Procurement', 'Safety equipment', 3),
    
    -- Projects
    ('550e8400-e29b-41d4-a716-446655440001', project_field_id, 'PROJ_ALPHA_2024', 'Project Alpha 2024', 'Office complex project', 1),
    ('550e8400-e29b-41d4-a716-446655440001', project_field_id, 'PROJ_BETA_2024', 'Project Beta 2024', 'Residential tower', 2),
    ('550e8400-e29b-41d4-a716-446655440001', project_field_id, 'PROJ_GAMMA_2024', 'Project Gamma 2024', 'Infrastructure project', 3);
END $$;

-- Step 6: Add context specificity calculation
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='approval_policies' AND column_name='context_specificity') THEN
        ALTER TABLE approval_policies DROP COLUMN context_specificity;
    END IF;
    
    ALTER TABLE approval_policies ADD COLUMN context_specificity INTEGER GENERATED ALWAYS AS (
        COALESCE(jsonb_array_length(selected_countries), 0) * 6 +
        COALESCE(jsonb_array_length(selected_departments), 0) * 5 +
        COALESCE(jsonb_array_length(selected_plants), 0) * 4 +
        COALESCE(jsonb_array_length(selected_storage_locations), 0) * 3 +
        COALESCE(jsonb_array_length(selected_purchase_orgs), 0) * 2 +
        COALESCE(jsonb_array_length(selected_projects), 0) * 1
    ) STORED;
END $$;

-- Step 7: Create optimized index
CREATE INDEX IF NOT EXISTS idx_policies_hierarchical_context ON approval_policies 
(customer_id, approval_object_type, approval_object_document_type, context_specificity DESC);

-- Step 8: Insert test policies
INSERT INTO approval_policies (
    id, customer_id, policy_name, approval_object_type, approval_object_document_type,
    object_category, approval_strategy, approval_pattern, amount_thresholds,
    company_code, country_code, 
    selected_countries, selected_departments, selected_plants, 
    selected_storage_locations, selected_purchase_orgs, selected_projects,
    is_active, created_at
) VALUES 
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Global PO Policy', 'PO', 'NB', 'FINANCIAL', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 1000000, "currency": "USD"}',
 'C001', 'USA', NULL, NULL, NULL, NULL, NULL, NULL, true, NOW()),

(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'US Operations Policy', 'PO', 'NB', 'FINANCIAL', 'HYBRID', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 750000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', NULL, NULL, NULL, NULL, NULL, true, NOW()),

(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Safety Department Policy', 'PO', 'NB', 'FINANCIAL', 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 500000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', '["SAFETY"]', NULL, NULL, '["PO_SAFETY"]', NULL, true, NOW())
ON CONFLICT DO NOTHING;

-- Step 9: Verification query
SELECT 
    policy_name,
    CASE WHEN selected_countries IS NULL THEN 'Global' ELSE selected_countries::text END as countries,
    CASE WHEN selected_departments IS NULL THEN 'All Depts' ELSE selected_departments::text END as departments,
    context_specificity
FROM approval_policies 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
ORDER BY context_specificity DESC;
        COALESCE(jsonb_array_length(selected_purchase_orgs), 0) * 2 +
        COALESCE(jsonb_array_length(selected_projects), 0) * 1
    ) STORED;
END $$;

-- Step 7: Create optimized index
CREATE INDEX IF NOT EXISTS idx_policies_hierarchical_context ON approval_policies 
(customer_id, approval_object_type, approval_object_document_type, context_specificity DESC);

-- Step 8: Insert test policies
INSERT INTO approval_policies (
    id, customer_id, policy_name, approval_object_type, approval_object_document_type,
    object_category, approval_strategy, approval_pattern, amount_thresholds,
    company_code, country_code, 
    selected_countries, selected_departments, selected_plants, 
    selected_storage_locations, selected_purchase_orgs, selected_projects,
    is_active, created_at
) VALUES 
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Global PO Policy', 'PO', 'NB', 'FINANCIAL', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 1000000, "currency": "USD"}',
 'C001', 'USA', NULL, NULL, NULL, NULL, NULL, NULL, true, NOW()),

(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'US Operations Policy', 'PO', 'NB', 'FINANCIAL', 'HYBRID', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 750000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', NULL, NULL, NULL, NULL, NULL, true, NOW()),

(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Safety Department Policy', 'PO', 'NB', 'FINANCIAL', 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 500000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', '["SAFETY"]', NULL, NULL, '["PO_SAFETY"]', NULL, true, NOW())
ON CONFLICT DO NOTHING;

-- Step 9: Verification query
SELECT 
    policy_name,
    CASE WHEN selected_countries IS NULL THEN 'Global' ELSE selected_countries::text END as countries,
    CASE WHEN selected_departments IS NULL THEN 'All Depts' ELSE selected_departments::text END as departments,
    context_specificity
FROM approval_policies 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
ORDER BY context_specificity DESC;