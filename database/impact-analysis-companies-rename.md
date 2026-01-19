# Impact Analysis: Rename companies.company_name to grpcompany_name

## Overview
Renaming `companies.company_name` to `companies.grpcompany_name` to distinguish group/parent company names from individual company names in `company_codes.company_name`.

---

## Database Impact

### Tables Affected
✅ **companies** table only
- Column: `company_name` → `grpcompany_name`
- No other tables reference this column directly

### Foreign Key Relationships
✅ **No impact** - `company_codes.company_id` references `companies.company_id` (not the name column)

---

## SQL Files That Need Updates

### 1. `database/discover-all-company-codes.sql`
**Lines to update:**
```sql
-- BEFORE:
c.company_name as parent_company

-- AFTER:
c.grpcompany_name as parent_company
```

**Occurrences:** 2 places
- Line 17: CREATE TABLE definition
- Line 35: UPDATE WHERE clause
- Line 40: UPDATE WHERE clause  
- Line 49: SELECT statement

### 2. `database/consolidate-abc-companies.sql`
**Lines to update:**
```sql
-- BEFORE:
WHERE company_name = 'ABC Construction Group'
WHERE company_name = 'ABC Group'
c.company_name as parent_company

-- AFTER:
WHERE grpcompany_name = 'ABC Construction Group'
WHERE grpcompany_name = 'ABC Group'
c.grpcompany_name as parent_company
```

**Occurrences:** 4 places
- Line 6: UPDATE WHERE clause
- Line 10: DELETE WHERE clause
- Line 82: SELECT statement (GROUP BY)
- Line 87: SELECT statement (ORDER BY)

### 3. `database/setup-existing-companies.sql`
**Need to check this file for references**

---

## Application Code Impact

### TypeScript/JavaScript Files
✅ **No direct impact found** - Application code currently only uses `company_codes` table, not `companies` table

**Files checked:**
- ✅ `app/api/erp-config/companies/route.ts` - Uses `company_codes` table only
- ✅ `domains/projects/projectCrudService.ts` - Uses `company_codes` table only
- ✅ `components/tiles/ManageProjectsComponent.tsx` - Uses `company_codes` table only

---

## Migration Steps

### Step 1: Backup Database
```bash
# Create backup in Supabase Dashboard
Dashboard → Database → Backups → Create Backup
```

### Step 2: Run Migration SQL
```sql
-- Run: database/rename-companies-company-name.sql
ALTER TABLE companies RENAME COLUMN company_name TO grpcompany_name;
```

### Step 3: Update SQL Files
Update the 2-3 SQL files that reference `companies.company_name`

### Step 4: Verify
```sql
-- Check column was renamed
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'companies';

-- Should show 'grpcompany_name' not 'company_name'
```

---

## Risk Assessment

| Risk Level | Area | Impact |
|------------|------|--------|
| 🟢 LOW | Application Code | No TypeScript/JavaScript files use companies table |
| 🟡 MEDIUM | SQL Scripts | 2-3 SQL files need manual updates |
| 🟢 LOW | Database | Only 1 table affected, no FK constraints |
| 🟢 LOW | Rollback | Simple column rename rollback available |

---

## Rollback Plan

If issues occur:
```sql
-- Run: database/rollback-companies-rename.sql
ALTER TABLE companies RENAME COLUMN grpcompany_name TO company_name;
```

---

## Summary

✅ **Safe to proceed** - Minimal impact
- Only affects `companies` table
- No application code changes needed
- 2-3 SQL files need updates
- Easy rollback available

**Estimated Time:** 10-15 minutes
**Downtime Required:** None (column rename is instant)
