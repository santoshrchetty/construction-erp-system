# Authorization Fields Migration - CORRECTED Steps

## Issue Found
The `authorization_fields` table doesn't exist in the database yet. We need to CREATE it, not rename it.

## Step 1: Create authorization_object_fields Table

Run this SQL in Supabase SQL Editor:

```sql
-- ============================================================================
-- Create authorization_object_fields Table (Junction Table)
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

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_auth_object_fields_auth_object_id 
  ON authorization_object_fields(auth_object_id);

CREATE INDEX IF NOT EXISTS idx_auth_object_fields_tenant_id 
  ON authorization_object_fields(tenant_id);

CREATE INDEX IF NOT EXISTS idx_auth_object_fields_field_code 
  ON authorization_object_fields(field_code);

-- Enable RLS
ALTER TABLE authorization_object_fields ENABLE ROW LEVEL SECURITY;

-- RLS Policies
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
```

## Step 2: Verify Table Creation

Run this to confirm:

```sql
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns
WHERE table_name = 'authorization_object_fields'
ORDER BY ordinal_position;
```

Expected output:
- id (uuid)
- auth_object_id (uuid)
- field_code (character varying)
- is_required (boolean)
- tenant_id (uuid)
- created_at (timestamp with time zone)
- updated_at (timestamp with time zone)

## Step 3: Test the API

After table creation, test the fields API:

```bash
# The API endpoints should now work:
POST   /api/authorization-objects/fields
PUT    /api/authorization-objects/fields
DELETE /api/authorization-objects/fields
```

## Step 4: Frontend Updates (Already Done)

The frontend code has been updated to use:
- `field_code` instead of `field_name`
- No `field_description` or `field_values` in the form
- Simplified AuthField interface

## Next: Add Sample Data (Optional)

After table creation, you can add sample fields:

```sql
-- Example: Add ACTVT field to an authorization object
INSERT INTO authorization_object_fields (auth_object_id, field_code, is_required, tenant_id)
VALUES (
  'your-auth-object-id',
  'ACTVT',
  true,
  'your-tenant-id'
);
```

## Architecture Summary

```
authorization_field_config (global)
  └─ Defines: ACTVT, COMP_CODE, PLANT, etc.

authorization_object_fields (tenant-specific)
  └─ Links: MATERIAL_MASTER_READ → [ACTVT, COMP_CODE, PLANT]

role_authorization_objects (tenant-specific)
  └─ Values: {"ACTVT": ["01","02"], "COMP_CODE": ["1000"]}
```
