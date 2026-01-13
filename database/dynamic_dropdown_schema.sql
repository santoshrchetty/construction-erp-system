-- Enhanced schema for dynamic dropdown management
-- Master data tables for all dropdown values

-- 1. Dropdown field definitions
CREATE TABLE IF NOT EXISTS approval_field_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    field_name VARCHAR(50) NOT NULL, -- plant_code, purchase_org, project_code, etc.
    field_label VARCHAR(100) NOT NULL, -- "Plant Code", "Purchase Organization"
    field_type VARCHAR(20) NOT NULL, -- SINGLE_SELECT, MULTI_SELECT, TEXT, CUSTOM
    field_category VARCHAR(30), -- ORGANIZATIONAL, PROJECT, CUSTOM
    is_required BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Dropdown option values
CREATE TABLE IF NOT EXISTS approval_field_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    field_definition_id UUID NOT NULL REFERENCES approval_field_definitions(id),
    option_value VARCHAR(100) NOT NULL, -- PLANT_NYC, PO_CONSTRUCTION
    option_label VARCHAR(200) NOT NULL, -- "NYC Plant - Manhattan", "Construction Procurement"
    option_description TEXT,
    parent_option_id UUID REFERENCES approval_field_options(id), -- For hierarchical options
    is_active BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Enhanced approval policies with multi-selection support
ALTER TABLE approval_policies 
ADD COLUMN IF NOT EXISTS selected_plants JSONB, -- ["PLANT_NYC", "PLANT_CHI"]
ADD COLUMN IF NOT EXISTS selected_purchase_orgs JSONB, -- ["PO_CONSTRUCTION", "PO_MAINTENANCE"]
ADD COLUMN IF NOT EXISTS selected_projects JSONB, -- ["PROJ_ALPHA_2024", "PROJ_BETA_2024"]
ADD COLUMN IF NOT EXISTS custom_fields JSONB; -- {"cost_center": ["CC001", "CC002"], "department": ["FINANCE"]}

-- 4. Custom field values for organization-specific needs
CREATE TABLE IF NOT EXISTS approval_custom_fields (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    field_name VARCHAR(50) NOT NULL,
    field_label VARCHAR(100) NOT NULL,
    field_type VARCHAR(20) NOT NULL, -- TEXT, NUMBER, DATE, SELECT, MULTI_SELECT
    field_options JSONB, -- For select types: [{"value": "CC001", "label": "Cost Center 001"}]
    validation_rules JSONB, -- {"required": true, "min_length": 3, "max_value": 1000000}
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Populate field definitions
INSERT INTO approval_field_definitions (
    customer_id, field_name, field_label, field_type, field_category, is_required, display_order
) VALUES
-- Organizational fields
('550e8400-e29b-41d4-a716-446655440001', 'company_code', 'Company Code', 'SINGLE_SELECT', 'ORGANIZATIONAL', true, 1),
('550e8400-e29b-41d4-a716-446655440001', 'country_code', 'Country Code', 'SINGLE_SELECT', 'ORGANIZATIONAL', true, 2),
('550e8400-e29b-41d4-a716-446655440001', 'plant_code', 'Plant Code', 'MULTI_SELECT', 'ORGANIZATIONAL', false, 3),
('550e8400-e29b-41d4-a716-446655440001', 'purchase_org', 'Purchase Organization', 'MULTI_SELECT', 'ORGANIZATIONAL', false, 4),
('550e8400-e29b-41d4-a716-446655440001', 'department_code', 'Department', 'MULTI_SELECT', 'ORGANIZATIONAL', false, 5),

-- Project fields
('550e8400-e29b-41d4-a716-446655440001', 'project_code', 'Project Code', 'MULTI_SELECT', 'PROJECT', false, 6),
('550e8400-e29b-41d4-a716-446655440001', 'cost_center', 'Cost Center', 'MULTI_SELECT', 'PROJECT', false, 7),

-- Storage fields
('550e8400-e29b-41d4-a716-446655440001', 'storage_type', 'Storage Type', 'SINGLE_SELECT', 'STORAGE', false, 8),
('550e8400-e29b-41d4-a716-446655440001', 'storage_location', 'Storage Location', 'MULTI_SELECT', 'STORAGE', false, 9);

-- Populate field options
INSERT INTO approval_field_options (
    customer_id, field_definition_id, option_value, option_label, option_description, display_order
) VALUES
-- Company codes
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'company_code'), 
 'C001', 'Construction Corp USA', 'Main construction company', 1),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'company_code'), 
 'C002', 'Construction Corp Canada', 'Canadian subsidiary', 2),

-- Plant codes
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'plant_code'), 
 'PLANT_NYC', 'NYC Plant - Manhattan', 'Main NYC construction facility', 1),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'plant_code'), 
 'PLANT_CHI', 'Chicago Plant - Downtown', 'Chicago construction facility', 2),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'plant_code'), 
 'PLANT_LA', 'Los Angeles Plant - West Coast', 'West coast operations', 3),

-- Purchase organizations
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'purchase_org'), 
 'PO_CONSTRUCTION', 'Construction Procurement', 'Main construction purchasing', 1),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'purchase_org'), 
 'PO_MAINTENANCE', 'Maintenance Procurement', 'Equipment maintenance purchasing', 2),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'purchase_org'), 
 'PO_SERVICES', 'Services Procurement', 'Professional services purchasing', 3),

-- Project codes
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'project_code'), 
 'PROJ_ALPHA_2024', 'Project Alpha 2024 - Office Complex', 'Downtown office complex project', 1),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'project_code'), 
 'PROJ_BETA_2024', 'Project Beta 2024 - Residential Tower', 'High-rise residential project', 2),
('550e8400-e29b-41d4-a716-446655440001', 
 (SELECT id FROM approval_field_definitions WHERE field_name = 'project_code'), 
 'PROJ_GAMMA_2024', 'Project Gamma 2024 - Infrastructure', 'Infrastructure development project', 3);

-- Sample custom fields
INSERT INTO approval_custom_fields (
    customer_id, field_name, field_label, field_type, field_options, validation_rules
) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'priority_level', 'Priority Level', 'SELECT', 
 '[{"value": "LOW", "label": "Low Priority"}, {"value": "MEDIUM", "label": "Medium Priority"}, {"value": "HIGH", "label": "High Priority"}, {"value": "CRITICAL", "label": "Critical Priority"}]',
 '{"required": false}'),
 
('550e8400-e29b-41d4-a716-446655440001', 'budget_code', 'Budget Code', 'MULTI_SELECT',
 '[{"value": "CAPEX", "label": "Capital Expenditure"}, {"value": "OPEX", "label": "Operational Expenditure"}, {"value": "MAINT", "label": "Maintenance Budget"}]',
 '{"required": false}'),

('550e8400-e29b-41d4-a716-446655440001', 'approval_deadline', 'Approval Deadline', 'DATE',
 'null', '{"required": false, "min_date": "today"}');

-- Verify dynamic field structure
SELECT 
    fd.field_name,
    fd.field_label,
    fd.field_type,
    fd.field_category,
    COUNT(fo.id) as option_count,
    STRING_AGG(fo.option_label, ', ' ORDER BY fo.display_order) as available_options
FROM approval_field_definitions fd
LEFT JOIN approval_field_options fo ON fd.id = fo.field_definition_id
WHERE fd.customer_id = '550e8400-e29b-41d4-a716-446655440001'
GROUP BY fd.field_name, fd.field_label, fd.field_type, fd.field_category, fd.display_order
ORDER BY fd.display_order;