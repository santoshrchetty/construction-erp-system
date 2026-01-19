# Resource Planning - Production Deployment Checklist

## ⚠️ CRITICAL: Complete These Steps Before Production

### 1. Run Database Migration
```bash
# In Supabase SQL Editor, execute:
database/00-resource-planning-complete.sql
```

This creates:
- activity_materials table
- activity_equipment table  
- activity_manpower table
- activity_services table
- activity_subcontractors table
- All triggers, indexes, and materialized view

### 2. Regenerate TypeScript Types
```bash
npx supabase gen types typescript --project-id tpngnqukhvgrkokleirx > types/supabase/database.types.ts
```

**Why this is critical:**
- Removes need for `as any` type assertions
- Provides full type safety
- Enables IDE autocomplete
- Catches errors at compile time

### 3. Remove Type Assertions
After regenerating types, remove `as any` from:
- `app/api/activities/route.ts` (lines with activity_materials queries)

### 4. Verify Build
```bash
npm run build
```

Should complete with NO TypeScript errors.

### 5. Test Endpoints
- GET /api/activities?action=materials&activityId=xxx
- POST /api/activities?action=attach-materials
- GET /api/activities?action=services&activityId=xxx
- POST /api/activities?action=attach-services
- GET /api/activities?action=subcontractors&activityId=xxx
- POST /api/activities?action=attach-subcontractors

## Current Status

✅ All code implemented
✅ All components created
✅ All build errors fixed (26 → 0)
⚠️ Temporary type assertions in place (MUST remove after migration)
❌ Database migration not run yet
❌ Types not regenerated from actual schema

## Why Type Assertions Are Temporary

The `as any` assertions in `app/api/activities/route.ts` are a **temporary workaround** because:
1. The new tables don't exist in the database yet
2. TypeScript types were generated before the migration
3. Once migration runs, regenerating types will provide proper type safety

**This is acceptable for development but MUST be fixed before production.**
