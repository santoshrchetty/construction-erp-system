-- MINIMAL DEPLOYMENT SCRIPT - Universal Approval Engine Context Fields

-- Step 1: Add context fields
ALTER TABLE approval_policies ADD COLUMN IF NOT EXISTS selected_countries JSONB;
ALTER TABLE approval_policies ADD COLUMN IF NOT EXISTS selected_departments JSONB;
ALTER TABLE approval_policies ADD COLUMN IF NOT EXISTS selected_plants JSONB;
ALTER TABLE approval_policies ADD COLUMN IF NOT EXISTS selected_storage_locations JSONB;
ALTER TABLE approval_policies ADD COLUMN IF NOT EXISTS selected_purchase_orgs JSONB;
ALTER TABLE approval_policies ADD COLUMN IF NOT EXISTS selected_projects JSONB;

-- Step 2: Create field tables
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
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Step 3: Clean existing data (delete child records first)
DELETE FROM approval_field_options WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001';
DELETE FROM approval_field_definitions WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001';

INSERT INTO approval_field_definitions (customer_id, field_name, field_label, field_type, field_category, is_required, display_order) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'country_code', 'Countries', 'MULTI_SELECT', 'GEOGRAPHIC', false, 1),
('550e8400-e29b-41d4-a716-446655440001', 'department_code', 'Departments', 'MULTI_SELECT', 'ORGANIZATIONAL', false, 2),
('550e8400-e29b-41d4-a716-446655440001', 'plant_code', 'Plants', 'MULTI_SELECT', 'ORGANIZATIONAL', false, 3),
('550e8400-e29b-41d4-a716-446655440001', 'storage_location_code', 'Storage Locations', 'MULTI_SELECT', 'OPERATIONAL', false, 4),
('550e8400-e29b-41d4-a716-446655440001', 'purchase_org', 'Purchase Organizations', 'MULTI_SELECT', 'OPERATIONAL', false, 5),
('550e8400-e29b-41d4-a716-446655440001', 'project_code', 'Projects', 'MULTI_SELECT', 'PROJECT', false, 6);

-- Step 4: Insert field options

-- Countries
INSERT INTO approval_field_options (customer_id, field_definition_id, option_value, option_label, option_description, display_order)
SELECT '550e8400-e29b-41d4-a716-446655440001', id, 'USA', 'United States', 'US operations', 1
FROM approval_field_definitions WHERE field_name = 'country_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';

INSERT INTO approval_field_options (customer_id, field_definition_id, option_value, option_label, option_description, display_order)
SELECT '550e8400-e29b-41d4-a716-446655440001', id, 'CAN', 'Canada', 'Canadian operations', 2
FROM approval_field_definitions WHERE field_name = 'country_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';

-- Departments
INSERT INTO approval_field_options (customer_id, field_definition_id, option_value, option_label, option_description, display_order)
SELECT '550e8400-e29b-41d4-a716-446655440001', id, 'FINANCE', 'Finance Department', 'Financial operations', 1
FROM approval_field_definitions WHERE field_name = 'department_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';

INSERT INTO approval_field_options (customer_id, field_definition_id, option_value, option_label, option_description, display_order)
SELECT '550e8400-e29b-41d4-a716-446655440001', id, 'SAFETY', 'Safety Department', 'Safety operations', 2
FROM approval_field_definitions WHERE field_name = 'department_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';

-- Plants
INSERT INTO approval_field_options (customer_id, field_definition_id, option_value, option_label, option_description, display_order)
SELECT '550e8400-e29b-41d4-a716-446655440001', id, 'PLANT_NYC', 'NYC Plant - Manhattan', 'NYC facility', 1
FROM approval_field_definitions WHERE field_name = 'plant_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';

INSERT INTO approval_field_options (customer_id, field_definition_id, option_value, option_label, option_description, display_order)
SELECT '550e8400-e29b-41d4-a716-446655440001', id, 'PLANT_CHI', 'Chicago Plant', 'Chicago facility', 2
FROM approval_field_definitions WHERE field_name = 'plant_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';

-- Storage Locations
INSERT INTO approval_field_options (customer_id, field_definition_id, option_value, option_label, option_description, display_order)
SELECT '550e8400-e29b-41d4-a716-446655440001', id, 'YARD_A', 'Yard A - General Storage', 'Main storage', 1
FROM approval_field_definitions WHERE field_name = 'storage_location_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';

INSERT INTO approval_field_options (customer_id, field_definition_id, option_value, option_label, option_description, display_order)
SELECT '550e8400-e29b-41d4-a716-446655440001', id, 'HAZMAT_1', 'Hazmat Storage 1', 'Hazardous materials', 2
FROM approval_field_definitions WHERE field_name = 'storage_location_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';

-- Purchase Organizations
INSERT INTO approval_field_options (customer_id, field_definition_id, option_value, option_label, option_description, display_order)
SELECT '550e8400-e29b-41d4-a716-446655440001', id, 'PO_CONSTRUCTION', 'Construction Procurement', 'Main construction purchasing', 1
FROM approval_field_definitions WHERE field_name = 'purchase_org' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';

INSERT INTO approval_field_options (customer_id, field_definition_id, option_value, option_label, option_description, display_order)
SELECT '550e8400-e29b-41d4-a716-446655440001', id, 'PO_SAFETY', 'Safety Procurement', 'Safety equipment', 2
FROM approval_field_definitions WHERE field_name = 'purchase_org' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';

-- Projects
INSERT INTO approval_field_options (customer_id, field_definition_id, option_value, option_label, option_description, display_order)
SELECT '550e8400-e29b-41d4-a716-446655440001', id, 'PROJ_ALPHA_2024', 'Project Alpha 2024', 'Office complex project', 1
FROM approval_field_definitions WHERE field_name = 'project_code' AND customer_id = '550e8400-e29b-41d4-a716-446655440001';

-- Step 5: Add context specificity (simple version)
ALTER TABLE approval_policies DROP COLUMN IF EXISTS context_specificity;
ALTER TABLE approval_policies ADD COLUMN context_specificity INTEGER DEFAULT 0;

-- Step 6: Create index
CREATE INDEX IF NOT EXISTS idx_policies_context ON approval_policies (customer_id, approval_object_type, context_specificity DESC);

-- Step 7: Insert test policies
INSERT INTO approval_policies (
    id, customer_id, policy_name, approval_object_type, approval_object_document_type,
    object_category, approval_strategy, approval_pattern, amount_thresholds,
    company_code, country_code, selected_countries, selected_departments,
    is_active, created_at, context_specificity
) VALUES 
(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Global PO Policy', 'PO', 'NB', 'FINANCIAL', 'ROLE_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 1000000, "currency": "USD"}',
 'C001', 'USA', NULL, NULL, true, NOW(), 0),

(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'US Operations Policy', 'PO', 'NB', 'FINANCIAL', 'HYBRID', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 750000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', NULL, true, NOW(), 6),

(gen_random_uuid(), '550e8400-e29b-41d4-a716-446655440001',
 'Safety Department Policy', 'PO', 'NB', 'FINANCIAL', 'AMOUNT_BASED', 'HIERARCHY_ONLY',
 '{"min": 0, "max": 500000, "currency": "USD"}',
 'C001', 'USA', '["USA"]', '["SAFETY"]', true, NOW(), 11)
ON CONFLICT DO NOTHING;

-- Step 8: Verification
SELECT policy_name, selected_countries, selected_departments, context_specificity
FROM approval_policies 
WHERE customer_id = '550e8400-e29b-41d4-a716-446655440001'
ORDER BY context_specificity DESC;