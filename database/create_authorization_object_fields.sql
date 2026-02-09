-- ============================================================================
-- Create authorization_object_fields Table (Junction Table)
-- ============================================================================
-- This table links authorization objects to field configurations
-- ============================================================================

-- STEP 1: Create the table
-- ============================================================================
CREATE TABLE IF NOT EXISTS authorization_object_fields (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_object_id UUID NOT NULL REFERENCES authorization_objects(id) ON DELETE CASCADE,
  field_code VARCHAR(50) NOT NULL,
  is_required BOOLEAN DEFAULT false,
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- STEP 2: Add indexes for performance
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_auth_object_fields_auth_object_id 
  ON authorization_object_fields(auth_object_id);

CREATE INDEX IF NOT EXISTS idx_auth_object_fields_tenant_id 
  ON authorization_object_fields(tenant_id);

CREATE INDEX IF NOT EXISTS idx_auth_object_fields_field_code 
  ON authorization_object_fields(field_code);

-- STEP 3: Enable RLS
-- ============================================================================
ALTER TABLE authorization_object_fields ENABLE ROW LEVEL SECURITY;

-- STEP 4: Create RLS policies
-- ============================================================================
CREATE POLICY "Users can view fields for their tenant"
  ON authorization_object_fields FOR SELECT
  TO authenticated
  USING (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can insert fields for their tenant"
  ON authorization_object_fields FOR INSERT
  TO authenticated
  WITH CHECK (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can update fields for their tenant"
  ON authorization_object_fields FOR UPDATE
  TO authenticated
  USING (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()))
  WITH CHECK (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can delete fields for their tenant"
  ON authorization_object_fields FOR DELETE
  TO authenticated
  USING (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

-- STEP 5: Verify table structure
-- ============================================================================
SELECT 
  column_name, 
  data_type, 
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_name = 'authorization_object_fields'
ORDER BY ordinal_position;

-- Expected columns:
-- id, auth_object_id, field_code, is_required, tenant_id, created_at, updated_at
