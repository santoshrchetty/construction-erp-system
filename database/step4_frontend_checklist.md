# STEP 4: Frontend Code Review Checklist

## Purpose
Identify and replace any hardcoded SAP module codes in the frontend codebase.

## SAP Codes to Search For
- 'AD' → 'admin'
- 'CF' → 'configuration'
- 'DM' → 'documents'
- 'EH' → 'safety'
- 'EM' → 'emergency'
- 'FI' → 'finance'
- 'HR' → 'hr'
- 'IN' → 'integration'
- 'MM' → 'materials' OR 'procurement' (context-dependent)
- 'MT' → 'user_tasks'
- 'PS' → 'projects'
- 'QM' → 'quality'
- 'RP' → 'reporting'
- 'WM' → 'warehouse'

## Files to Check

### Priority 1: Tile/Module Related Components
- [ ] components/layout/ConstructionTiles.tsx
- [ ] components/layout/EnhancedConstructionTiles.tsx
- [ ] components/features/configuration/ERPConfigurationTile.tsx
- [ ] app/api/tiles/route.ts

### Priority 2: Authorization Components
- [ ] components/features/administration/AuthorizationObjects.tsx
- [ ] lib/services/authorizationService.ts
- [ ] app/api/authorization-objects/route.ts

### Priority 3: Type Definitions
- [ ] types/index.ts
- [ ] types/supabase/database.types.ts
- [ ] types/forms.ts

### Priority 4: Other API Routes
- [ ] app/api/*/route.ts (all API routes)

## Search Commands

### Windows (PowerShell)
```powershell
# Search for SAP codes in TypeScript/JavaScript files
Get-ChildItem -Path . -Include *.ts,*.tsx,*.js,*.jsx -Recurse | Select-String -Pattern "'(AD|CF|DM|EH|EM|FI|HR|IN|MM|MT|PS|QM|RP|WM)'" | Select-Object Path, LineNumber, Line

# Search for module_code references
Get-ChildItem -Path . -Include *.ts,*.tsx -Recurse | Select-String -Pattern "module_code" | Select-Object Path, LineNumber
```

### Unix/Linux/Mac
```bash
# Search for SAP codes
grep -r "'AD'\|'CF'\|'DM'\|'EH'\|'EM'\|'FI'\|'HR'\|'IN'\|'MM'\|'MT'\|'PS'\|'QM'\|'RP'\|'WM'" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" .

# Search for module_code references
grep -r "module_code" --include="*.ts" --include="*.tsx" .
```

## Expected Findings

### Likely Safe (No Changes Needed)
- Database type definitions (auto-generated from Supabase)
- Comments or documentation
- Test data or mock data

### Likely Needs Changes
- Hardcoded module filters: `module_code === 'MM'`
- Module comparisons in conditionals
- Module-specific routing logic
- Module validation arrays

## Replacement Strategy

### Example 1: Simple Replacement
```typescript
// BEFORE
if (tile.module_code === 'MM') {
  // Materials logic
}

// AFTER
if (tile.module_code === 'materials') {
  // Materials logic
}
```

### Example 2: MM Split (Context-Dependent)
```typescript
// BEFORE
const materialsTiles = tiles.filter(t => t.module_code === 'MM');

// AFTER - Option A: Materials only
const materialsTiles = tiles.filter(t => t.module_code === 'materials');

// AFTER - Option B: Both materials and procurement
const materialsTiles = tiles.filter(t => 
  t.module_code === 'materials' || t.module_code === 'procurement'
);
```

### Example 3: Module Arrays
```typescript
// BEFORE
const validModules = ['AD', 'CF', 'MM', 'PS', 'FI'];

// AFTER
const validModules = ['admin', 'configuration', 'materials', 'procurement', 'projects', 'finance'];
```

## Testing After Changes

### 1. TypeScript Compilation
```bash
npm run build
# or
tsc --noEmit
```

### 2. Runtime Testing
- [ ] Login as different users (Admin, Engineer, HR, PlanEng)
- [ ] Verify correct tiles are visible
- [ ] Check module filtering works
- [ ] Test authorization checks
- [ ] Verify routing works

### 3. Browser Console
- [ ] No errors related to module_code
- [ ] API responses show friendly module names
- [ ] Tile filtering works correctly

## Notes

- **Database types**: If using Supabase CLI, regenerate types after database changes:
  ```bash
  npx supabase gen types typescript --project-id <project-id> > types/supabase/database.types.ts
  ```

- **MM Code**: Pay special attention to 'MM' replacements - determine from context whether it should be 'materials' or 'procurement'

- **Backward Compatibility**: If you need to support both old and new codes temporarily, use:
  ```typescript
  const isMatch = ['MM', 'materials', 'procurement'].includes(tile.module_code);
  ```

## Completion Criteria

- [ ] All SAP codes replaced with friendly names
- [ ] TypeScript compiles without errors
- [ ] All tests pass
- [ ] Manual testing confirms correct behavior
- [ ] No console errors in browser
- [ ] Authorization works correctly for all roles
