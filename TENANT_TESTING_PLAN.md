# Multi-Tenant Testing Plan

## Overview
This document outlines the testing strategy to validate tenant isolation and authentication security.

## Test Environment Setup

### Existing Tenant (Tenant A)
- **Tenant Code:** NTT
- **Tenant Name:** NTT Demo
- **Tenant ID:** `9bd339ec-9877-4d9f-b3dc-3e60048c1b15`
- **User:** admin@nttdemo.com
- **Password:** (existing)

### New Test Tenant (Tenant B)
- **Tenant Code:** ABC
- **Tenant Name:** ABC Construction Company
- **Tenant ID:** (generated during setup)
- **User:** admin@abcconstruction.com
- **Password:** Test@123456

## Setup Steps

### 1. Create Test Tenant via Supabase Dashboard

**Option A: Using SQL Editor**
```sql
-- Run the script: scripts/setup-test-tenant.sql
-- Follow the steps in the script
```

**Option B: Using API Route**
```bash
# Create tenant via API
curl -X POST http://localhost:3000/api/tenants \
  -H "Content-Type: application/json" \
  -d '{
    "tenant_code": "ABC",
    "tenant_name": "ABC Construction Company"
  }'
```

### 2. Create User in Supabase Auth
1. Go to Supabase Dashboard → Authentication → Users
2. Click "Add User"
3. Email: `admin@abcconstruction.com`
4. Password: `Test@123456`
5. Auto-confirm user: Yes
6. Copy the generated User ID

### 3. Create User Profile
```sql
-- Replace {USER_ID}, {TENANT_ID}, {ROLE_ID} with actual values
INSERT INTO users (id, email, first_name, last_name, role_id, employee_code, department, tenant_id, is_active)
VALUES (
  '{USER_ID}',
  'admin@abcconstruction.com',
  'John',
  'Smith',
  '{ROLE_ID}',
  'ABC0001',
  'Administration',
  '{TENANT_ID}',
  true
);
```

## Test Cases

### Test Suite 1: Authentication & Login

#### TC1.1: Valid Login with Correct Tenant
**Steps:**
1. Navigate to `/login`
2. Select "ABC Construction Company" from dropdown
3. Enter: admin@abcconstruction.com / Test@123456
4. Click "Sign In"

**Expected Result:**
- ✅ Login successful
- ✅ Redirected to `/erp-modules`
- ✅ Cookie `tenant-id` set with ABC tenant ID
- ✅ User profile loaded

**Validation:**
```javascript
// Check in browser DevTools → Application → Cookies
// Should see: tenant-id = {ABC_TENANT_ID}
```

#### TC1.2: Login with Wrong Tenant
**Steps:**
1. Navigate to `/login`
2. Select "NTT Demo" (wrong tenant)
3. Enter: admin@abcconstruction.com / Test@123456
4. Click "Sign In"

**Expected Result:**
- ❌ Login fails
- ❌ Error: "You do not have access to the selected organization"
- ❌ User remains on login page
- ❌ No session created

#### TC1.3: Login Without Selecting Tenant
**Steps:**
1. Navigate to `/login`
2. Leave tenant dropdown at "Select Organization *"
3. Enter credentials
4. Click "Sign In"

**Expected Result:**
- ❌ Submit button disabled
- ❌ Error: "Please select an organization to continue"

#### TC1.4: Cross-Tenant Login Attempt
**Steps:**
1. Login as admin@nttdemo.com with NTT tenant
2. Logout
3. Login as admin@abcconstruction.com with ABC tenant

**Expected Result:**
- ✅ Both logins successful
- ✅ Each user sees only their tenant's data
- ✅ No data leakage between sessions

---

### Test Suite 2: Middleware Protection

#### TC2.1: Access Protected Route Without Session
**Steps:**
1. Clear all cookies
2. Navigate to `/erp-modules`

**Expected Result:**
- ❌ Redirected to `/login?redirectTo=/erp-modules`
- ❌ Cannot access protected route

#### TC2.2: Access Protected Route Without Tenant Cookie
**Steps:**
1. Login successfully
2. Delete `tenant-id` cookie in DevTools
3. Refresh page or navigate to `/erp-modules`

**Expected Result:**
- ❌ Redirected to `/login`
- ❌ Session cleared

#### TC2.3: Tamper with Tenant Cookie
**Steps:**
1. Login as ABC user
2. In DevTools, change `tenant-id` cookie to NTT tenant ID
3. Refresh page

**Expected Result:**
- ❌ Middleware detects mismatch
- ❌ Redirected to `/login`
- ❌ Cookie cleared

---

### Test Suite 3: Data Isolation

#### TC3.1: View Projects - Tenant A
**Steps:**
1. Login as admin@nttdemo.com (NTT tenant)
2. Navigate to projects page
3. Note the projects displayed

**Expected Result:**
- ✅ Only NTT tenant projects visible
- ❌ ABC tenant projects NOT visible

#### TC3.2: View Projects - Tenant B
**Steps:**
1. Login as admin@abcconstruction.com (ABC tenant)
2. Navigate to projects page
3. Note the projects displayed

**Expected Result:**
- ✅ Only ABC tenant projects visible
- ❌ NTT tenant projects NOT visible

#### TC3.3: View Materials - Tenant A
**Steps:**
1. Login as admin@nttdemo.com
2. Navigate to materials page
3. Search for materials

**Expected Result:**
- ✅ Only NTT tenant materials visible
- ❌ ABC tenant materials NOT visible

#### TC3.4: View Materials - Tenant B
**Steps:**
1. Login as admin@abcconstruction.com
2. Navigate to materials page
3. Search for materials

**Expected Result:**
- ✅ Only ABC tenant materials visible
- ❌ NTT tenant materials NOT visible

---

### Test Suite 4: API Route Protection

#### TC4.1: API Call Without Authentication
**Steps:**
```bash
curl http://localhost:3000/api/materials
```

**Expected Result:**
- ❌ Status: 401 Unauthorized
- ❌ Response: `{"error": "Unauthorized"}`

#### TC4.2: API Call Without Tenant Cookie
**Steps:**
```bash
# Get session token but no tenant cookie
curl http://localhost:3000/api/materials \
  -H "Cookie: sb-xxx-auth-token=<token>"
```

**Expected Result:**
- ❌ Status: 401 Unauthorized
- ❌ Response: `{"error": "No tenant context"}`

#### TC4.3: API Call with Valid Tenant - Tenant A
**Steps:**
1. Login as NTT user in browser
2. Open DevTools → Network tab
3. Make API call to `/api/materials`
4. Check response data

**Expected Result:**
- ✅ Status: 200 OK
- ✅ Only NTT tenant materials returned
- ✅ `tenant_id` in all records matches NTT tenant ID

#### TC4.4: API Call with Valid Tenant - Tenant B
**Steps:**
1. Login as ABC user in browser
2. Open DevTools → Network tab
3. Make API call to `/api/materials`
4. Check response data

**Expected Result:**
- ✅ Status: 200 OK
- ✅ Only ABC tenant materials returned
- ✅ `tenant_id` in all records matches ABC tenant ID

---

### Test Suite 5: Session Management

#### TC5.1: Logout Clears Tenant Context
**Steps:**
1. Login successfully
2. Verify `tenant-id` cookie exists
3. Click logout
4. Check cookies

**Expected Result:**
- ✅ `tenant-id` cookie deleted
- ✅ Session cleared
- ✅ Redirected to `/login`

#### TC5.2: Session Persistence
**Steps:**
1. Login successfully
2. Close browser tab
3. Open new tab and navigate to app
4. Check if still logged in

**Expected Result:**
- ✅ Still logged in (session persisted)
- ✅ Tenant cookie still valid
- ✅ Can access protected routes

#### TC5.3: Concurrent Sessions - Different Tenants
**Steps:**
1. Open browser window 1 → Login as NTT user
2. Open browser window 2 (incognito) → Login as ABC user
3. Verify both sessions work independently

**Expected Result:**
- ✅ Both sessions active
- ✅ Each sees only their tenant's data
- ✅ No interference between sessions

---

## Automated Test Script

Create a test file to automate some checks:

```typescript
// tests/tenant-isolation.test.ts

describe('Tenant Isolation Tests', () => {
  
  test('User can only login to their assigned tenant', async () => {
    // Test TC1.2
  })
  
  test('Middleware blocks access without tenant cookie', async () => {
    // Test TC2.2
  })
  
  test('API returns only tenant-specific data', async () => {
    // Test TC4.3, TC4.4
  })
  
  test('Cookie tampering is detected', async () => {
    // Test TC2.3
  })
})
```

## Security Checklist

After running all tests, verify:

- [ ] Users cannot login to wrong tenant
- [ ] Tenant selection is mandatory
- [ ] Middleware validates tenant on every request
- [ ] API routes filter by tenant_id
- [ ] Cookie tampering is detected and blocked
- [ ] Logout clears all tenant context
- [ ] No data leakage between tenants
- [ ] Cross-tenant access attempts are logged
- [ ] Session cookies are httpOnly and secure

## Performance Testing

### Load Test Scenarios
1. **Concurrent Logins:** 100 users across 10 tenants
2. **API Throughput:** 1000 requests/sec with tenant filtering
3. **Session Validation:** Middleware overhead measurement

## Monitoring & Logging

### What to Monitor
1. Failed tenant validation attempts
2. Cookie tampering attempts
3. Cross-tenant access attempts
4. API response times with tenant filtering
5. Session creation/destruction rates

### Log Examples
```
[SECURITY] User abc123 attempted to access tenant XYZ (assigned: ABC)
[AUTH] Tenant validation failed: cookie mismatch
[API] Query filtered by tenant_id: ABC returned 150 records
```

## Rollback Plan

If issues are found:
1. Disable tenant validation in middleware (temporary)
2. Revert to localStorage-based tenant selection
3. Fix issues in development
4. Re-deploy with fixes
5. Re-run test suite

## Success Criteria

✅ All test cases pass
✅ No data leakage between tenants
✅ Performance impact < 50ms per request
✅ Zero security vulnerabilities found
✅ Documentation complete

## Next Steps After Testing

1. **Enable Row-Level Security (RLS)** in database
2. **Add audit logging** for tenant access
3. **Implement rate limiting** per tenant
4. **Add monitoring dashboards**
5. **Document findings** and update security policies
