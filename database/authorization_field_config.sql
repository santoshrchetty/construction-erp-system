-- ============================================================================
-- Authorization Field Configuration Table
-- ============================================================================
-- This table allows adding new authorization fields without code changes
-- ============================================================================

CREATE TABLE IF NOT EXISTS authorization_field_config (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  field_code VARCHAR(50) UNIQUE NOT NULL,
  field_name VARCHAR(100) NOT NULL,
  field_category VARCHAR(50) NOT NULL CHECK (field_category IN ('Activity', 'Organizational', 'Business')),
  data_source_type VARCHAR(50) NOT NULL CHECK (data_source_type IN ('static', 'table', 'enum')),
  source_table VARCHAR(100),
  source_value_column VARCHAR(100),
  source_display_column VARCHAR(100),
  static_values JSONB,
  default_value VARCHAR(10) DEFAULT '*',
  is_active BOOLEAN DEFAULT true,
  display_order INTEGER,
  help_text TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE authorization_field_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to all authenticated users"
  ON authorization_field_config FOR SELECT
  TO authenticated
  USING (is_active = true);

-- Insert existing fields
INSERT INTO authorization_field_config 
  (field_code, field_name, field_category, data_source_type, static_values, display_order, help_text) 
VALUES 
  ('ACTVT', 'Activity', 'Activity', 'static', 
   '[{"value":"01","label":"01 - Create"},{"value":"02","label":"02 - Change"},{"value":"03","label":"03 - Display"},{"value":"06","label":"06 - Delete"},{"value":"*","label":"* - All"}]'::jsonb,
   1, 'Standard activity codes for authorization checks');

INSERT INTO authorization_field_config 
  (field_code, field_name, field_category, data_source_type, source_table, source_value_column, source_display_column, display_order, help_text) 
VALUES 
  ('COMP_CODE', 'Company Code', 'Organizational', 'table', 'company_codes', 'company_code', 'company_name', 10, 'From: company_codes table'),
  ('PLANT', 'Plant', 'Organizational', 'table', 'plants', 'plant_code', 'plant_name', 20, 'From: plants table'),
  ('STORAGE_LOC', 'Storage Location', 'Organizational', 'table', 'storage_locations', 'sloc_code', 'sloc_name', 30, 'From: storage_locations table'),
  ('DEPT', 'Department', 'Organizational', 'table', 'departments', 'dept_code', 'name', 40, 'From: departments table'),
  ('COST_CENTER', 'Cost Center', 'Organizational', 'table', 'cost_centers', 'cost_center_code', 'cost_center_name', 50, 'From: cost_centers table'),
  ('PURCH_ORG', 'Purchasing Organization', 'Organizational', 'table', 'purchasing_organizations', 'porg_code', 'porg_name', 60, 'From: purchasing_organizations table'),
  ('PROJ_TYPE', 'Project Type', 'Organizational', 'enum', 'projects', 'project_type', 'project_type', 70, 'From: projects.project_type (distinct values)'),
  ('MR_TYPE', 'Material Request Type', 'Organizational', 'enum', 'material_requests', 'mr_type', 'mr_type', 80, 'From: material_requests.mr_type (distinct values)'),
  ('PR_TYPE', 'Purchase Requisition Type', 'Organizational', 'enum', 'purchase_requisitions', 'pr_type', 'pr_type', 90, 'From: purchase_requisitions.pr_type (distinct values)'),
  ('MAT_TYPE', 'Material Type', 'Organizational', 'enum', 'materials', 'material_type', 'material_type', 100, 'From: materials.material_type (distinct values)');

INSERT INTO authorization_field_config 
  (field_code, field_name, field_category, data_source_type, static_values, display_order, help_text) 
VALUES 
  ('PO_TYPE', 'Purchase Order Type', 'Business', 'static',
   '[{"value":"STANDARD","label":"Standard PO"},{"value":"BLANKET","label":"Blanket PO"},{"value":"CONTRACT","label":"Contract PO"},{"value":"SUBCONTRACT","label":"Subcontract PO"},{"value":"EMERGENCY","label":"Emergency PO"},{"value":"*","label":"* - All"}]'::jsonb,
   200, 'Static values: Purchase Order types (for future PO table)'),
  ('PO_VALUE', 'PO Value Limit', 'Business', 'static', NULL, 210, 'Custom: Value limits'),
  ('GL_ACCT', 'GL Account Range', 'Business', 'static', NULL, 220, 'Custom: GL account ranges');

-- ============================================================================
-- EXAMPLE: How to add a new field (e.g., SUPPLIER)
-- ============================================================================
-- Just run this INSERT - no code changes needed!
-- 
-- INSERT INTO authorization_field_config 
--   (field_code, field_name, field_category, data_source_type, source_table, source_value_column, source_display_column, display_order, help_text) 
-- VALUES 
--   ('SUPPLIER', 'Supplier', 'Organizational', 'table', 'suppliers', 'supplier_code', 'supplier_name', 110, 'From: suppliers table');
