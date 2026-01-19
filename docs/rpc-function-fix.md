# RPC Function Fix - Tiles Authorization

## Problem
The tiles authorization was using a direct database query instead of the RPC function `get_user_modules`. The previous attempt to use RPC failed with "No API key found in request" error.

## Root Cause
The RPC function was created correctly in the database, but the API route was not calling it. Instead, it was using a direct query to `role_authorization_objects` table with inline module mapping logic.

## Solution
Fixed the `/api/tiles` route to properly call the RPC function using Supabase's `.rpc()` method.

### Changes Made

**File**: `app/api/tiles/route.ts`

**Before** (Direct Query - 25 lines):
```typescript
const { data: roleAuthObjects, error: modulesError } = await supabase
  .from('role_authorization_objects')
  .select('authorization_objects!inner(module)')
  .eq('role_id', profile.role_id)
  .eq('is_active', true)

const authModules = roleAuthObjects?.map((rao: any) => rao.authorization_objects.module).filter(Boolean) || []

const authorizedModuleCodes = authModules.map(module => {
  switch(module) {
    case 'Finance': return 'FI'
    case 'ADMIN': return 'AD'
    // ... 10 more cases
  }
}).filter((v, i, a) => a.indexOf(v) === i)
```

**After** (RPC Call - 10 lines):
```typescript
const { data: moduleCodes, error: modulesError } = await supabase
  .rpc('get_user_modules', { user_id: user.id })

const authorizedModuleCodes = moduleCodes?.map((row: any) => row.module_code).filter(Boolean) || []
```

## Benefits

### 1. Performance
- **Single database call** instead of multiple joins
- Database-side processing is faster than application-side
- Reduced network overhead

### 2. Maintainability
- Module mapping logic centralized in database
- No need to update API code when adding new modules
- Single source of truth for authorization logic

### 3. Security
- `SECURITY DEFINER` ensures consistent execution context
- Logic cannot be bypassed by client manipulation
- Easier to audit and test

### 4. Code Quality
- Reduced code complexity (25 lines → 10 lines)
- Cleaner, more readable code
- Follows database best practices

## Testing

### 1. Verify RPC Function Exists
Run: `database/test-rpc-function.sql`

### 2. Test with Different Users
```sql
-- Test with admin user
SELECT * FROM get_user_modules('admin-user-id'::uuid);

-- Test with engineer user
SELECT * FROM get_user_modules('engineer-user-id'::uuid);
```

### 3. Test API Endpoint
```bash
# Should return only authorized tiles
curl http://localhost:3000/api/tiles
```

## Module Mapping Reference

| Authorization Object Module | Tile Module Code |
|----------------------------|------------------|
| Finance                    | FI               |
| ADMIN                      | AD               |
| CG / configuration         | CF               |
| materials / procurement    | MM               |
| reporting                  | RP               |
| user_tasks                 | MT               |
| emergency                  | EM               |
| integration                | IN               |
| DOCS                       | DM               |

## Files Modified
- ✅ `app/api/tiles/route.ts` - Replaced direct query with RPC call

## Files Referenced
- `database/create-get-user-modules-function.sql` - RPC function definition
- `database/test-rpc-function.sql` - Testing script
- `lib/supabase/server.ts` - Service client with SERVICE_ROLE_KEY

## Next Steps
1. Test the RPC function in Supabase dashboard
2. Verify tiles load correctly for different user roles
3. Monitor performance improvements
4. Consider adding caching for frequently accessed module lists
