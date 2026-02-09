# TypeScript Errors Summary

## Total Errors: ~800+

## Category Breakdown:

### 1. Zod Schema Issues (~600 errors)
**Problem**: Zod imports were commented out but actual Zod usage (z.object, z.string, etc.) remains in code

**Affected Files** (18 files):
- types/construction-authorization.ts
- types/enhanced-tiles.ts
- types/rbac.ts
- types/sap-authorization.ts
- types/schemas/dynamic-stores.schema.ts
- types/schemas/procurement-workflow.schema.ts
- types/schemas/procurement.schema.ts
- types/schemas/projects.schema.ts
- types/schemas/stores.schema.ts
- types/schemas/tasks.schema.ts
- types/schemas/tenants.schema.ts
- types/schemas/timesheet.schema.ts
- types/schemas/timesheets.schema.ts
- types/schemas/wbs.schema.ts

**Solution Options**:
A. Delete all Zod schema definitions (recommended - not being used)
B. Install Zod and uncomment imports
C. Convert Zod schemas to TypeScript interfaces

---

### 2. Missing Repository Exports (~10 errors)
**File**: types/index.ts

**Missing Exports**:
- ActivitiesRepository
- VendorsRepository (should be VendorRepository)
- PurchaseOrdersRepository
- StockItemsRepository (should be StoresRepository)
- StockBalancesRepository (should be StoresRepository)
- StockMovementsRepository
- TimesheetEntriesRepository (should be TimesheetsRepository)

**Solution**: Fix export names in types/index.ts to match actual repository names

---

### 3. Missing Database Tables (~100 errors)
**Problem**: Code references tables that don't exist in Supabase schema

**Missing Tables**:
- `timesheets` - Referenced in types/repositories/timesheets.repository.ts
- `timesheet_entries` - Referenced in types/repositories/timesheets.repository.ts
- `task_dependencies` - Referenced in types/repositories/tasks.repository.ts
- `stock_balances_fifo` - Referenced in types/repositories/dynamic-stores.repository.ts

**Solution Options**:
A. Create these tables in Supabase
B. Comment out/delete repository files that use non-existent tables
C. Update code to use existing table names

---

### 4. BaseRepository Type Issues (~50 errors)
**Problem**: Several repositories extend BaseRepository without providing required type argument

**Affected Files**:
- types/repositories/boq.repository.ts
- types/repositories/procurement-workflow.repository.ts (4 classes)
- types/repositories/timesheet.repository.ts (4 classes)
- types/repositories/timesheets.repository.ts

**Error Example**:
```typescript
// Wrong:
export class BOQRepository extends BaseRepository {

// Should be:
export class BOQRepository extends BaseRepository<'boq_items'> {
```

**Solution**: Add table name type argument to all BaseRepository extensions

---

### 5. Supabase Type Mismatches (~40 errors)
**Problem**: TypeScript strict typing issues with dynamic table names and string parameters

**Affected Files**:
- types/repositories/base.repository.ts
- types/repositories/dynamic-stores.repository.ts
- types/repositories/tasks.repository.ts
- types/repositories/timesheets.repository.ts

**Common Errors**:
- `.from(tableName)` - tableName is string but expects specific table literal
- `.eq('id', value)` - 'id' is string but expects specific column literal
- `.insert(data)` - data type mismatch

**Current Workaround**: Using `as any` type assertions (already applied in some files)

---

### 6. Missing Module Import (~1 error)
**File**: types/repositories/rbac.ts
**Error**: Cannot find module '../types/rbac'

**Solution**: 
- File is trying to import from '../types/rbac' but should be './rbac' or '../rbac'
- Or delete the import if not needed

---

### 7. Missing Property (~1 error)
**File**: types/forms.ts
**Error**: Property 'request_number' is missing in MaterialRequest type

**Solution**: Add request_number property or make it optional

---

### 8. Vendor Rating Property (~1 error)
**File**: types/repositories/procurement.repository.ts
**Error**: 'rating' does not exist in vendor type

**Solution**: Remove rating property from vendor update or add it to vendor type

---

## Recommended Fix Priority:

### HIGH PRIORITY (Blocks Build):
1. **Fix Zod Issues** - Delete all Zod schema code or install Zod
2. **Fix Repository Exports** - Update types/index.ts
3. **Fix Missing Tables** - Comment out repositories for non-existent tables

### MEDIUM PRIORITY:
4. **Fix BaseRepository Types** - Add type arguments
5. **Fix Missing Module** - Fix rbac import path

### LOW PRIORITY (Already Has Workarounds):
6. **Supabase Type Mismatches** - Already using `as any` in many places
7. **Missing Properties** - Minor type issues

---

## Quick Fix Commands:

### Option 1: Delete All Zod Schema Files (Fastest)
```bash
# Delete all schema files
del types\schemas\*.ts

# Delete Zod usage from other files
# (Manual edit needed for 4 files in types/ root)
```

### Option 2: Install Zod
```bash
npm install zod
# Then uncomment all Zod imports
```

### Option 3: Comment Out Problem Repositories
```bash
# Comment out these files:
# - types/repositories/timesheets.repository.ts
# - types/repositories/timesheet.repository.ts
# - types/repositories/boq.repository.ts
# - types/repositories/procurement-workflow.repository.ts
```

---

## Files That Need Manual Review:

1. **types/index.ts** - Fix repository export names
2. **types/forms.ts** - Add request_number property
3. **types/repositories/rbac.ts** - Fix import path
4. **types/repositories/procurement.repository.ts** - Remove rating property
5. **All 18 Zod schema files** - Delete or fix

---

## Estimated Time to Fix:

- **Quick Fix (Delete Zod schemas)**: 30 minutes
- **Proper Fix (Install Zod + fix all issues)**: 3-4 hours
- **Complete Fix (All 800 errors)**: 8-10 hours
