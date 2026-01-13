-- Complete Context Fields Deployment Script
-- This script creates tables and inserts field definitions with options

-- Create tables for field definitions and options if they don't exist
CREATE TABLE IF NOT EXISTS approval_field_definitions (
  id VARCHAR(50) PRIMARY KEY,
  customer_id UUID NOT NULL,
  field_name VARCHAR(100) NOT NULL,
  field_label VARCHAR(200) NOT NULL,
  field_type VARCHAR(50) NOT NULL DEFAULT 'MULTI_SELECT',
  is_required BOOLEAN DEFAULT false,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(customer_id, field_name)
);

CREATE TABLE IF NOT EXISTS approval_field_options (
  id VARCHAR(50) PRIMARY KEY,
  customer_id UUID NOT NULL,
  field_definition_id VARCHAR(50) NOT NULL,
  option_value VARCHAR(100) NOT NULL,
  option_label VARCHAR(200) NOT NULL,
  option_description VARCHAR(500),
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  FOREIGN KEY (field_definition_id) REFERENCES approval_field_definitions(id) ON DELETE CASCADE,
  UNIQUE(field_definition_id, option_value)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_field_definitions_customer ON approval_field_definitions(customer_id);
CREATE INDEX IF NOT EXISTS idx_field_options_customer ON approval_field_options(customer_id);
CREATE INDEX IF NOT EXISTS idx_field_options_definition ON approval_field_options(field_definition_id);

-- Insert field definitions
INSERT INTO approval_field_definitions (id, customer_id, field_name, field_label, field_type, is_required, display_order, is_active, created_at, updated_at) VALUES 
('fd_countries_001', '550e8400-e29b-41d4-a716-446655440001', 'country_code', 'Countries', 'MULTI_SELECT', false, 1, true, NOW(), NOW()),
('fd_departments_001', '550e8400-e29b-41d4-a716-446655440001', 'department_code', 'Departments', 'MULTI_SELECT', false, 2, true, NOW(), NOW()),
('fd_plants_001', '550e8400-e29b-41d4-a716-446655440001', 'plant_code', 'Plants', 'MULTI_SELECT', false, 3, true, NOW(), NOW()),
('fd_storage_001', '550e8400-e29b-41d4-a716-446655440001', 'storage_location_code', 'Storage Locations', 'MULTI_SELECT', false, 4, true, NOW(), NOW()),
('fd_purchase_001', '550e8400-e29b-41d4-a716-446655440001', 'purchase_org', 'Purchase Organizations', 'MULTI_SELECT', false, 5, true, NOW(), NOW()),
('fd_projects_001', '550e8400-e29b-41d4-a716-446655440001', 'project_code', 'Projects', 'MULTI_SELECT', false, 6, true, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET field_label = EXCLUDED.field_label, updated_at = NOW();

-- Insert field options
INSERT INTO approval_field_options (id, customer_id, field_definition_id, option_value, option_label, option_description, display_order, is_active, created_at, updated_at) VALUES
-- Countries
('opt_country_usa', '550e8400-e29b-41d4-a716-446655440001', 'fd_countries_001', 'USA', 'United States', 'United States operations', 1, true, NOW(), NOW()),
('opt_country_can', '550e8400-e29b-41d4-a716-446655440001', 'fd_countries_001', 'CAN', 'Canada', 'Canadian operations', 2, true, NOW(), NOW()),
('opt_country_mex', '550e8400-e29b-41d4-a716-446655440001', 'fd_countries_001', 'MEX', 'Mexico', 'Mexican operations', 3, true, NOW(), NOW()),
-- Departments
('opt_dept_finance', '550e8400-e29b-41d4-a716-446655440001', 'fd_departments_001', 'FINANCE', 'Finance', 'Financial operations', 1, true, NOW(), NOW()),
('opt_dept_operations', '550e8400-e29b-41d4-a716-446655440001', 'fd_departments_001', 'OPERATIONS', 'Operations', 'Operational activities', 2, true, NOW(), NOW()),
('opt_dept_construction', '550e8400-e29b-41d4-a716-446655440001', 'fd_departments_001', 'CONSTRUCTION', 'Construction', 'Construction projects', 3, true, NOW(), NOW()),
('opt_dept_safety', '550e8400-e29b-41d4-a716-446655440001', 'fd_departments_001', 'SAFETY', 'Safety', 'Safety management', 4, true, NOW(), NOW()),
('opt_dept_hr', '550e8400-e29b-41d4-a716-446655440001', 'fd_departments_001', 'HR', 'Human Resources', 'HR operations', 5, true, NOW(), NOW()),
-- Plants
('opt_plant_nyc', '550e8400-e29b-41d4-a716-446655440001', 'fd_plants_001', 'PLANT_NYC', 'New York Plant', 'NYC manufacturing facility', 1, true, NOW(), NOW()),
('opt_plant_chi', '550e8400-e29b-41d4-a716-446655440001', 'fd_plants_001', 'PLANT_CHI', 'Chicago Plant', 'Chicago distribution center', 2, true, NOW(), NOW()),
('opt_plant_la', '550e8400-e29b-41d4-a716-446655440001', 'fd_plants_001', 'PLANT_LA', 'Los Angeles Plant', 'LA west coast operations', 3, true, NOW(), NOW()),
('opt_plant_mia', '550e8400-e29b-41d4-a716-446655440001', 'fd_plants_001', 'PLANT_MIA', 'Miami Plant', 'Miami southeast operations', 4, true, NOW(), NOW()),
-- Storage Locations
('opt_storage_wh01', '550e8400-e29b-41d4-a716-446655440001', 'fd_storage_001', 'WH01', 'Main Warehouse', 'Primary storage facility', 1, true, NOW(), NOW()),
('opt_storage_wh02', '550e8400-e29b-41d4-a716-446655440001', 'fd_storage_001', 'WH02', 'Secondary Warehouse', 'Overflow storage', 2, true, NOW(), NOW()),
('opt_storage_yard', '550e8400-e29b-41d4-a716-446655440001', 'fd_storage_001', 'YARD', 'Construction Yard', 'Outdoor storage area', 3, true, NOW(), NOW()),
('opt_storage_hazmat', '550e8400-e29b-41d4-a716-446655440001', 'fd_storage_001', 'HAZMAT', 'Hazmat Storage', 'Hazardous materials storage', 4, true, NOW(), NOW()),
-- Purchase Organizations
('opt_porg_1000', '550e8400-e29b-41d4-a716-446655440001', 'fd_purchase_001', 'PORG_1000', 'Corporate Purchasing', 'Central procurement office', 1, true, NOW(), NOW()),
('opt_porg_2000', '550e8400-e29b-41d4-a716-446655440001', 'fd_purchase_001', 'PORG_2000', 'Regional East', 'Eastern region procurement', 2, true, NOW(), NOW()),
('opt_porg_3000', '550e8400-e29b-41d4-a716-446655440001', 'fd_purchase_001', 'PORG_3000', 'Regional West', 'Western region procurement', 3, true, NOW(), NOW()),
('opt_porg_4000', '550e8400-e29b-41d4-a716-446655440001', 'fd_purchase_001', 'PORG_4000', 'Emergency Procurement', 'Emergency purchasing unit', 4, true, NOW(), NOW()),
-- Projects
('opt_proj_alpha', '550e8400-e29b-41d4-a716-446655440001', 'fd_projects_001', 'PROJ_ALPHA_2024', 'Project Alpha 2024', 'Major infrastructure project', 1, true, NOW(), NOW()),
('opt_proj_beta', '550e8400-e29b-41d4-a716-446655440001', 'fd_projects_001', 'PROJ_BETA_2024', 'Project Beta 2024', 'Commercial development', 2, true, NOW(), NOW()),
('opt_proj_gamma', '550e8400-e29b-41d4-a716-446655440001', 'fd_projects_001', 'PROJ_GAMMA_2024', 'Project Gamma 2024', 'Residential complex', 3, true, NOW(), NOW()),
('opt_proj_delta', '550e8400-e29b-41d4-a716-446655440001', 'fd_projects_001', 'PROJ_DELTA_2024', 'Project Delta 2024', 'Bridge construction', 4, true, NOW(), NOW())
ON CONFLICT (id) DO UPDATE SET option_label = EXCLUDED.option_label, updated_at = NOW();