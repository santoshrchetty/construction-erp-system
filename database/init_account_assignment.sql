  -- Initialize account assignment tables
  -- Run this via Supabase SQL Editor

  -- 1. Create account_assignment_types table
  CREATE TABLE IF NOT EXISTS account_assignment_types (
    code VARCHAR(2) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    requires_cost_center BOOLEAN DEFAULT FALSE,
    requires_wbs_element BOOLEAN DEFAULT FALSE,
    requires_activity_code BOOLEAN DEFAULT FALSE,
    requires_asset_number BOOLEAN DEFAULT FALSE,
    requires_order_number BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INTEGER
  );

  -- 2. Insert account assignment types
  INSERT INTO account_assignment_types (code, name, description, requires_cost_center, requires_wbs_element, requires_activity_code, requires_asset_number, requires_order_number, display_order) VALUES
  ('CC', 'Cost Center', 'General overhead expenses', TRUE, FALSE, FALSE, FALSE, FALSE, 1),
  ('WB', 'Project (WBS)', 'Project-related expenses', FALSE, TRUE, FALSE, FALSE, FALSE, 2),
  ('AS', 'Asset', 'Capital expenditure for assets', FALSE, FALSE, FALSE, TRUE, FALSE, 3),
  ('WA', 'WBS + Activity', 'Project with activity tracking', FALSE, TRUE, TRUE, FALSE, FALSE, 4),
  ('OP', 'Production Order', 'Manufacturing production', FALSE, FALSE, FALSE, FALSE, TRUE, 5),
  ('OM', 'Maintenance Order', 'Equipment maintenance', FALSE, FALSE, FALSE, FALSE, TRUE, 6),
  ('OQ', 'Quality Order', 'Quality inspection', FALSE, FALSE, FALSE, FALSE, TRUE, 7)
  ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    requires_cost_center = EXCLUDED.requires_cost_center,
    requires_wbs_element = EXCLUDED.requires_wbs_element,
    requires_activity_code = EXCLUDED.requires_activity_code,
    requires_asset_number = EXCLUDED.requires_asset_number,
    requires_order_number = EXCLUDED.requires_order_number;

  -- 3. Create MR type mapping table
  CREATE TABLE IF NOT EXISTS mr_type_account_assignment_mapping (
    id UUID PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    mr_type VARCHAR(20) NOT NULL,
    account_assignment_code VARCHAR(2) NOT NULL REFERENCES account_assignment_types(code),
    is_default BOOLEAN DEFAULT FALSE,
    is_allowed BOOLEAN DEFAULT TRUE,
    display_order INTEGER,
    tenant_id UUID NOT NULL DEFAULT '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid,
    UNIQUE(mr_type, account_assignment_code, tenant_id)
  );

  -- 4. Insert MR type mappings
  INSERT INTO mr_type_account_assignment_mapping (mr_type, account_assignment_code, is_default, is_allowed, display_order, tenant_id) VALUES
  ('PROJECT', 'WB', TRUE, TRUE, 1, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('PROJECT', 'WA', FALSE, TRUE, 2, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('MAINTENANCE', 'OM', TRUE, TRUE, 1, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('MAINTENANCE', 'CC', FALSE, TRUE, 2, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('GENERAL', 'CC', TRUE, TRUE, 1, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('ASSET', 'AS', TRUE, TRUE, 1, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('OFFICE', 'CC', TRUE, TRUE, 1, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('SAFETY', 'CC', TRUE, TRUE, 1, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('SAFETY', 'WB', FALSE, TRUE, 2, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('EQUIPMENT', 'AS', TRUE, TRUE, 1, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid),
  ('EQUIPMENT', 'OM', FALSE, TRUE, 2, '9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid)
  ON CONFLICT (mr_type, account_assignment_code, tenant_id) DO UPDATE SET
    is_default = EXCLUDED.is_default,
    is_allowed = EXCLUDED.is_allowed,
    display_order = EXCLUDED.display_order;

  -- 5. Add account assignment columns to material_request_items
  ALTER TABLE material_request_items
  ADD COLUMN IF NOT EXISTS account_assignment_code VARCHAR(2) REFERENCES account_assignment_types(code),
  ADD COLUMN IF NOT EXISTS cost_center VARCHAR(10),
  ADD COLUMN IF NOT EXISTS wbs_element VARCHAR(24),
  ADD COLUMN IF NOT EXISTS activity_code VARCHAR(12),
  ADD COLUMN IF NOT EXISTS asset_number VARCHAR(12),
  ADD COLUMN IF NOT EXISTS order_number VARCHAR(12);

  -- 6. Add indexes
  CREATE INDEX IF NOT EXISTS idx_mr_items_account_assignment ON material_request_items(account_assignment_code);
  CREATE INDEX IF NOT EXISTS idx_mr_items_wbs ON material_request_items(wbs_element);
  CREATE INDEX IF NOT EXISTS idx_mr_items_cost_center ON material_request_items(cost_center);

  -- Verify tables
  SELECT 'account_assignment_types' as table_name, COUNT(*) as row_count FROM account_assignment_types
  UNION ALL
  SELECT 'mr_type_account_assignment_mapping', COUNT(*) FROM mr_type_account_assignment_mapping;
