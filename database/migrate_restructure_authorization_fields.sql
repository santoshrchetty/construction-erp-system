-- ============================================================================
-- Migration: Restructure authorization_fields as Junction Table
-- ============================================================================
-- authorization_fields should link auth objects to field configs
-- NOT store field definitions (that's in authorization_field_config)
-- ============================================================================

-- STEP 1: Rename and restructure the table
-- ============================================================================
ALTER TABLE authorization_fields RENAME TO authorization_object_fields;

-- STEP 2: Drop redundant columns (field definitions now in config table)
-- ============================================================================
ALTER TABLE authorization_object_fields 
  DROP COLUMN IF EXISTS field_description,
  DROP COLUMN IF EXISTS field_values,
  DROP COLUMN IF EXISTS is_organizational;

-- STEP 3: Add field_code to reference authorization_field_config
-- ============================================================================
ALTER TABLE authorization_object_fields 
  ADD COLUMN IF NOT EXISTS field_code VARCHAR(50);

-- STEP 4: Migrate existing field_name to field_code
-- ============================================================================
UPDATE authorization_object_fields 
SET field_code = field_name 
WHERE field_code IS NULL;

-- STEP 5: Make field_code NOT NULL after migration
-- ============================================================================
ALTER TABLE authorization_object_fields 
  ALTER COLUMN field_code SET NOT NULL;

-- STEP 6: Drop old field_name column
-- ============================================================================
ALTER TABLE authorization_object_fields 
  DROP COLUMN IF EXISTS field_name;

-- STEP 7: Add foreign key to authorization_field_config (optional - no FK since config has no tenant)
-- ============================================================================
-- We can't add FK because authorization_field_config has no tenant_id
-- But we can add a check constraint to ensure field_code exists

-- STEP 8: Final structure
-- ============================================================================
-- authorization_object_fields now has:
-- - id (uuid)
-- - auth_object_id (uuid) → references authorization_objects
-- - field_code (varchar) → references authorization_field_config.field_code
-- - is_required (boolean)
-- - tenant_id (uuid)
-- - created_at, updated_at

-- ============================================================================
-- RESULT: Clean junction table
-- ============================================================================
-- authorization_field_config (global) → defines WHAT fields exist
-- authorization_object_fields (tenant) → defines WHICH fields each object has
-- role_authorization_objects.field_values → defines actual VALUES per role
