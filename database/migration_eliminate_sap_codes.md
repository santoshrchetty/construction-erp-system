# Migration Plan: Eliminate SAP Codes and Use Friendly Module Names

## Overview
Replace SAP module codes (AD, CF, MM, PS, FI, etc.) with friendly module names (admin, configuration, materials, projects, finance, etc.) throughout the system.

## Benefits
1. **Fixes HR Role Issue**: Separate "materials" and "procurement" modules (currently both map to "MM")
2. **Simpler Architecture**: Remove mapping layer in get_user_modules() RPC
3. **Better Clarity**: Self-documenting module names
4. **Easier Maintenance**: One less translation step

## Current State
- authorization_objects.module: Friendly names (materials, projects, finance, etc.)
- tiles.module_code: SAP codes (MM, PS, FI, etc.)
- get_user_modules() RPC: Maps friendly names → SAP codes

## Target State
- authorization_objects.module: Friendly names (unchanged)
- tiles.module_code: Friendly names (changed from SAP codes)
- get_user_modules() RPC: Direct pass-through (no mapping)

---

## STEP 1: Backup Current State

### 1.1 Backup tiles table
```sql
-- Create backup of tiles with current module_code values
CREATE TABLE tiles_backup_sap_codes AS 
SELECT * FROM tiles;

-- Verify backup
SELECT module_code, COUNT(*) 
FROM tiles_backup_sap_codes 
GROUP BY module_code 
ORDER BY module_code;
```

### 1.2 Document current mapping
```sql
-- Show current SAP code distribution
SELECT 
    module_code,
    tile_category,
    COUNT(*) as tile_count,
    STRING_AGG(title, ', ' ORDER BY title) as tiles
FROM tiles
WHERE is_active = true
GROUP BY module_code, tile_category
ORDER BY module_code, tile_category;
```

---

## STEP 2: Update tiles.module_code to Friendly Names

### 2.1 Update tiles with 1:1 mappings
```sql
-- Simple 1:1 mappings (no ambiguity)
UPDATE tiles SET module_code = 'admin' WHERE module_code = 'AD';
UPDATE tiles SET module_code = 'configuration' WHERE module_code = 'CF';
UPDATE tiles SET module_code = 'documents' WHERE module_code = 'DM';
UPDATE tiles SET module_code = 'safety' WHERE module_code = 'EH';
UPDATE tiles SET module_code = 'emergency' WHERE module_code = 'EM';
UPDATE tiles SET module_code = 'finance' WHERE module_code = 'FI';
UPDATE tiles SET module_code = 'hr' WHERE module_code = 'HR';
UPDATE tiles SET module_code = 'integration' WHERE module_code = 'IN';
UPDATE tiles SET module_code = 'user_tasks' WHERE module_code = 'MT';
UPDATE tiles SET module_code = 'projects' WHERE module_code = 'PS';
UPDATE tiles SET module_code = 'quality' WHERE module_code = 'QM';
UPDATE tiles SET module_code = 'reporting' WHERE module_code = 'RP';
UPDATE tiles SET module_code = 'warehouse' WHERE module_code = 'WM';
```

### 2.2 Split MM code into materials and procurement
```sql
-- CRITICAL: Split MM based on tile_category
UPDATE tiles 
SET module_code = 'materials' 
WHERE module_code = 'MM' 
  AND tile_category = 'Materials';

UPDATE tiles 
SET module_code = 'procurement' 
WHERE module_code = 'MM' 
  AND tile_category = 'Procurement';

-- Verify no MM codes remain
SELECT module_code, tile_category, title 
FROM tiles 
WHERE module_code = 'MM';
-- Should return 0 rows
```

### 2.3 Verify migration
```sql
-- Check new module_code distribution
SELECT 
    module_code,
    COUNT(*) as tile_count,
    STRING_AGG(tile_category, ', ' ORDER BY tile_category) as categories
FROM tiles
GROUP BY module_code
ORDER BY module_code;

-- Verify all tiles have valid module codes
SELECT COUNT(*) as tiles_with_friendly_names
FROM tiles
WHERE module_code IN (
    'admin', 'configuration', 'documents', 'safety', 'emergency',
    'finance', 'hr', 'integration', 'materials', 'procurement',
    'user_tasks', 'projects', 'quality', 'reporting', 'warehouse'
);
```

---

## STEP 3: Simplify get_user_modules() RPC Function

### 3.1 Replace function with direct pass-through
```sql
-- Drop existing function
DROP FUNCTION IF EXISTS get_user_modules(uuid);

-- Create simplified function (no CASE mapping)
CREATE OR REPLACE FUNCTION get_user_modules(p_user_id uuid)
RETURNS TABLE(module_code text)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ao.module::text
  FROM user_roles ur
  JOIN roles r ON ur.role_id = r.id
  JOIN role_authorization_objects rao ON r.id = rao.role_id
  JOIN authorization_objects ao ON rao.auth_object_id = ao.id
  WHERE ur.user_id = p_user_id
    AND r.is_active = true
    AND ao.is_active = true
    AND ao.module IS NOT NULL
    AND TRIM(ao.module) != '';
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_user_modules(uuid) TO authenticated;
```

### 3.2 Test new function
```sql
-- Test with admin user
SELECT * FROM get_user_modules('9bd339ec-9877-4d9f-b3dc-3e60048c1b15'::uuid);

-- Should return friendly module names directly:
-- admin, configuration, materials, projects, finance, etc.
```

---

## STEP 4: Update Frontend (if needed)

### 4.1 Check for hardcoded SAP codes
Search codebase for:
- 'AD', 'CF', 'DM', 'EH', 'EM', 'FI', 'HR', 'IN', 'MM', 'MT', 'PS', 'QM', 'RP', 'WM'
- Look in: components/, app/, lib/, types/

### 4.2 Replace with friendly names
If found, replace:
- 'MM' → 'materials' or 'procurement' (context-dependent)
- 'PS' → 'projects'
- 'FI' → 'finance'
- etc.

---

## STEP 5: Test Authorization Flow

### 5.1 Test HR role (should only see HR tiles now)
```sql
-- Remove materials module from HR role
DELETE FROM role_authorization_objects
WHERE role_id = (SELECT id FROM roles WHERE name = 'HR')
  AND auth_object_id IN (
    SELECT id FROM authorization_objects WHERE module = 'materials'
  );

-- Verify HR user only sees HR tiles
SELECT * FROM get_user_modules('<hr-user-id>'::uuid);
-- Should return: ['hr']

-- Check tiles visible to HR user
SELECT title, module_code, tile_category
FROM tiles
WHERE module_code IN (
  SELECT * FROM get_user_modules('<hr-user-id>'::uuid)
)
ORDER BY module_code, title;
-- Should only show HR tiles
```

### 5.2 Test Engineer role (should see all assigned modules)
```sql
-- Check Engineer modules
SELECT * FROM get_user_modules('<engineer-user-id>'::uuid);

-- Verify tiles match authorization
SELECT module_code, COUNT(*) as tile_count
FROM tiles
WHERE module_code IN (
  SELECT * FROM get_user_modules('<engineer-user-id>'::uuid)
)
GROUP BY module_code
ORDER BY module_code;
```

### 5.3 Test PlanEng role
```sql
-- Check PlanEng modules
SELECT * FROM get_user_modules('<planeng-user-id>'::uuid);

-- Should see: projects, procurement, materials (if assigned)
```

---

## STEP 6: Verify and Cleanup

### 6.1 Verify no SAP codes remain
```sql
-- Check tiles table
SELECT DISTINCT module_code FROM tiles ORDER BY module_code;
-- Should only show friendly names

-- Check for any SAP codes in tiles
SELECT * FROM tiles 
WHERE module_code IN ('AD', 'CF', 'DM', 'EH', 'EM', 'FI', 'HR', 'IN', 'MM', 'MT', 'PS', 'QM', 'RP', 'WM');
-- Should return 0 rows
```

### 6.2 Drop backup table (after verification)
```sql
-- Only after confirming everything works
-- DROP TABLE tiles_backup_sap_codes;
```

---

## Rollback Plan (if needed)

### Restore from backup
```sql
-- Restore tiles.module_code from backup
UPDATE tiles t
SET module_code = b.module_code
FROM tiles_backup_sap_codes b
WHERE t.id = b.id;

-- Restore original get_user_modules() function
-- (Re-run database/create_get_user_modules_function.sql)
```

---

## Expected Outcomes

### Before Migration
- HR user sees: HR + Materials + Procurement tiles (unwanted)
- Module codes: AD, CF, MM, PS, FI, etc.
- Mapping layer: 30+ lines of CASE statements

### After Migration
- HR user sees: Only HR tiles (correct)
- Module codes: admin, configuration, materials, projects, finance, etc.
- Mapping layer: Direct pass-through (5 lines)

---

## Execution Order

1. ✅ STEP 1: Backup (safe, reversible)
2. ✅ STEP 2: Update tiles (data migration)
3. ✅ STEP 3: Simplify RPC (logic simplification)
4. ⚠️ STEP 4: Update frontend (if needed)
5. ✅ STEP 5: Test authorization (validation)
6. ✅ STEP 6: Verify and cleanup (finalization)

---

## Risk Assessment

- **Low Risk**: Steps 1, 2, 3, 5, 6 (database only, easily reversible)
- **Medium Risk**: Step 4 (frontend changes, requires testing)
- **Mitigation**: Backup table created in Step 1, rollback plan provided
