# Authorization Fields Migration - Step by Step

## Step 1: Run Migration SQL in Supabase

Copy and paste this SQL into Supabase SQL Editor:

```sql
-- ============================================================================
-- STEP 1: Backup existing data
-- ============================================================================
CREATE TABLE IF NOT EXISTS authorization_fields_backup AS 
SELECT * FROM authorization_fields;

-- ============================================================================
-- STEP 2: Rename table
-- ============================================================================
ALTER TABLE authorization_fields RENAME TO authorization_object_fields;

-- ============================================================================
-- STEP 3: Drop redundant columns
-- ============================================================================
ALTER TABLE authorization_object_fields 
  DROP COLUMN IF EXISTS field_description,
  DROP COLUMN IF EXISTS field_values,
  DROP COLUMN IF EXISTS is_organizational;

-- ============================================================================
-- STEP 4: Add field_code column
-- ============================================================================
ALTER TABLE authorization_object_fields 
  ADD COLUMN IF NOT EXISTS field_code VARCHAR(50);

-- ============================================================================
-- STEP 5: Migrate data from field_name to field_code
-- ============================================================================
UPDATE authorization_object_fields 
SET field_code = field_name 
WHERE field_code IS NULL;

-- ============================================================================
-- STEP 6: Make field_code NOT NULL
-- ============================================================================
ALTER TABLE authorization_object_fields 
  ALTER COLUMN field_code SET NOT NULL;

-- ============================================================================
-- STEP 7: Drop old field_name column
-- ============================================================================
ALTER TABLE authorization_object_fields 
  DROP COLUMN IF EXISTS field_name;

-- ============================================================================
-- STEP 8: Verify migration
-- ============================================================================
SELECT 
  'authorization_object_fields' as table_name,
  COUNT(*) as record_count,
  COUNT(DISTINCT field_code) as unique_fields
FROM authorization_object_fields;

-- Show sample data
SELECT * FROM authorization_object_fields LIMIT 5;
```

## Step 2: Verify Migration Success

Run this query to confirm:

```sql
-- Check table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'authorization_object_fields'
ORDER BY ordinal_position;

-- Expected columns:
-- id, auth_object_id, field_code, is_required, tenant_id, created_at, updated_at
```

## Step 3: Code Changes (Automated)

After SQL migration succeeds, the following code changes will be applied automatically:

1. ✅ Restore `/api/authorization-objects/fields` endpoint
2. ✅ Update main API to join with `authorization_object_fields`
3. ✅ Update frontend to use `field_code` instead of `field_name`

## Rollback (if needed)

```sql
-- Restore from backup
DROP TABLE IF EXISTS authorization_object_fields;
ALTER TABLE authorization_fields_backup RENAME TO authorization_fields;
```
