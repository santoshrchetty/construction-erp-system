# Tenant Authentication & Isolation Implementation

## Overview
This document explains the multi-tenant authentication and data isolation implementation in the Construction App.

## Architecture

### 1. Tenant Session Management (Server-Side)

**Location:** `/app/api/auth/tenant/route.ts`

- Tenant context stored in **httpOnly cookie** (`tenant-id`)
- Cookie is secure, cannot be modified by client-side JavaScript
- Validated on every request by middleware and API routes

**Flow:**
```
Login → Validate Tenant Access → Set httpOnly Cookie → Redirect
```

### 2. Login Flow with Tenant Validation

**Location:** `/app/login/page.tsx` + `/lib/contexts/AuthContext.tsx`

**Steps:**
1. User enters credentials and optionally selects tenant
2. `signIn()` authenticates with Supabase
3. Fetch user profile from `users` table
4. **Validate:** If tenant selected, check `profile.tenant_id === selectedTenantId`
5. If validation fails, sign out and show error
6. If validation passes, call `/api/auth/tenant` to set server-side cookie
7. Redirect to protected route

**Code:**
```typescript
const { session, profile } = await signIn(email, password, tenantId)
// Tenant validation happens inside signIn()
```

### 3. Middleware Enforcement

**Location:** `/middleware.ts`

**Checks on Every Request:**
1. Verify user has valid session
2. Check `tenant-id` cookie exists
3. Fetch user profile and validate `profile.tenant_id === cookie.tenant_id`
4. If mismatch, clear cookie and redirect to login
5. Set `x-tenant-id` header for downstream use

**Protected Routes:**
- `/erp-modules`
- `/admin`
- `/projects`
- `/finance`
- `/materials`
- `/inventory`

### 4. API Route Protection

**Location:** `/lib/authMiddleware.ts`

All API routes using `withAuth()` automatically:
1. Verify authentication
2. Validate tenant access from `tenant-id` cookie
3. Check user belongs to tenant
4. Provide `context.tenantId` to handler

**Usage Example:**
```typescript
export const GET = withAuth(async (request, context) => {
  const { tenantId, user, isAdmin } = context
  
  // Query automatically filtered by tenant
  const { data } = await supabase
    .from('materials')
    .select('*')
    .eq('tenant_id', tenantId)  // ✅ Tenant isolation
    
  return NextResponse.json(data)
}, ['MATERIAL_MASTER_READ'])
```

### 5. Tenant Validation Utility

**Location:** `/lib/tenant-auth.ts`

For API routes NOT using `withAuth()`:
```typescript
import { validateTenantAccess } from '@/lib/tenant-auth'

export async function GET(request: NextRequest) {
  const { tenantId, userId, supabase } = await validateTenantAccess(request)
  
  // Use tenantId to filter queries
  const { data } = await supabase
    .from('materials')
    .eq('tenant_id', tenantId)
    .select('*')
    
  return NextResponse.json(data)
}
```

## Security Features

### ✅ Implemented

1. **Server-Side Tenant Storage**
   - Tenant ID stored in httpOnly cookie
   - Cannot be modified by client JavaScript
   - Validated on every request

2. **Login Validation**
   - User can only access their assigned tenant
   - Attempting to select wrong tenant = login fails
   - Error message: "You do not have access to the selected organization"

3. **Middleware Enforcement**
   - Every protected route validates tenant access
   - Tenant mismatch = automatic logout + redirect
   - No way to bypass via URL manipulation

4. **API Route Protection**
   - All routes using `withAuth()` validate tenant
   - Tenant ID provided in context for query filtering
   - 401/403 errors if validation fails

5. **Logout Cleanup**
   - Clears tenant cookie
   - Clears localStorage
   - Invalidates session

### 🔄 Recommended Next Steps

1. **Database Row-Level Security (RLS)**
   ```sql
   -- Enable RLS on all tables
   ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
   
   -- Create policy
   CREATE POLICY tenant_isolation ON materials
     USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
   ```

2. **Audit Logging**
   - Log all tenant access attempts
   - Track cross-tenant access attempts
   - Monitor for suspicious activity

3. **Rate Limiting**
   - Prevent brute force tenant enumeration
   - Limit login attempts per tenant

4. **Tenant Switching (Optional)**
   - Allow users with multi-tenant access
   - Validate each tenant in user's allowed list
   - Re-authenticate when switching

## Testing Checklist

### ✅ Test Scenarios

1. **Valid Login**
   - [ ] User logs in without selecting tenant → Uses profile.tenant_id
   - [ ] User logs in with correct tenant selected → Success
   - [ ] User redirected to requested page after login

2. **Invalid Login**
   - [ ] User selects wrong tenant → Error: "You do not have access..."
   - [ ] User session cleared after failed tenant validation
   - [ ] Cannot access protected routes without tenant cookie

3. **Middleware Protection**
   - [ ] Unauthenticated user redirected to login
   - [ ] Authenticated user without tenant cookie redirected to login
   - [ ] Tenant cookie mismatch clears session and redirects

4. **API Protection**
   - [ ] API calls without auth return 401
   - [ ] API calls without tenant return 401
   - [ ] API calls with wrong tenant return 403
   - [ ] API calls return only tenant's data

5. **Logout**
   - [ ] Tenant cookie cleared
   - [ ] Cannot access protected routes after logout
   - [ ] Cannot access API routes after logout

6. **Cookie Tampering**
   - [ ] Modifying tenant-id cookie in DevTools → Validation fails
   - [ ] User redirected to login
   - [ ] No data leakage

## Migration Guide

### For Existing API Routes

**Before:**
```typescript
export async function GET(request: NextRequest) {
  const { data } = await supabase
    .from('materials')
    .select('*')  // ❌ Returns all tenants' data
    
  return NextResponse.json(data)
}
```

**After:**
```typescript
export const GET = withAuth(async (request, context) => {
  const { tenantId } = context
  
  const { data } = await supabase
    .from('materials')
    .select('*')
    .eq('tenant_id', tenantId)  // ✅ Filtered by tenant
    
  return NextResponse.json(data)
}, ['MATERIAL_MASTER_READ'])
```

### For Client Components

**Before:**
```typescript
const tenantId = localStorage.getItem('selectedTenant')  // ❌ Insecure
```

**After:**
```typescript
const { profile } = useAuth()
const tenantId = profile?.tenant_id  // ✅ From validated profile
```

## Troubleshooting

### Issue: "No tenant context" error

**Cause:** Tenant cookie not set or expired

**Solution:**
1. Log out completely
2. Clear browser cookies
3. Log in again

### Issue: "Tenant access denied" error

**Cause:** User trying to access tenant they don't belong to

**Solution:**
1. Verify user's `tenant_id` in database
2. Ensure user logging into correct tenant
3. Check for cookie tampering

### Issue: API returns empty data

**Cause:** Queries not filtered by tenant

**Solution:**
1. Add `.eq('tenant_id', context.tenantId)` to all queries
2. Use `withAuth()` middleware
3. Verify tenant_id column exists in table

## Summary

**Before Implementation:**
- ❌ Tenant stored in localStorage (client-side)
- ❌ No validation during login
- ❌ No middleware enforcement
- ❌ API routes not filtered by tenant
- ❌ Users could access any tenant's data

**After Implementation:**
- ✅ Tenant stored in httpOnly cookie (server-side)
- ✅ Validation during login
- ✅ Middleware enforces tenant access
- ✅ API routes validate and filter by tenant
- ✅ Users can only access their tenant's data

**Security Level:** 🔒 **High** (with RLS: 🔒 **Very High**)
