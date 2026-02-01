# Quick Start: Create & Test Second Tenant

## Option 1: Using Helper Script (Recommended)

```bash
node scripts/create-test-tenant.js
```

Follow the prompts and it will generate the SQL for you.

## Option 2: Manual Creation

### Step 1: Create Tenant (Supabase SQL Editor)

```sql
INSERT INTO tenants (id, tenant_code, tenant_name, is_active)
VALUES (gen_random_uuid(), 'ABC', 'ABC Construction', true)
RETURNING id;
```

**Copy the returned ID** → This is your `TENANT_ID`

### Step 2: Create Admin Role

```sql
INSERT INTO roles (id, tenant_id, name, description, permissions, is_active)
VALUES (
  gen_random_uuid(),
  'YOUR_TENANT_ID_HERE',  -- Paste tenant ID from Step 1
  'Admin',
  'Administrator',
  '{"all": true}'::jsonb,
  true
)
RETURNING id;
```

**Copy the returned ID** → This is your `ROLE_ID`

### Step 3: Create User in Supabase Auth

1. Go to **Supabase Dashboard** → **Authentication** → **Users**
2. Click **"Add User"**
3. Fill in:
   - Email: `admin@abcconstruction.com`
   - Password: `Test@123456`
   - Auto Confirm User: **Yes** ✅
4. Click **"Create User"**
5. **Copy the User ID** from the users list

### Step 4: Create User Profile

```sql
INSERT INTO users (id, email, first_name, last_name, role_id, employee_code, department, tenant_id, is_active)
VALUES (
  'YOUR_USER_ID_HERE',      -- Paste user ID from Step 3
  'admin@abcconstruction.com',
  'John',
  'Smith',
  'YOUR_ROLE_ID_HERE',      -- Paste role ID from Step 2
  'ABC0001',
  'Administration',
  'YOUR_TENANT_ID_HERE',    -- Paste tenant ID from Step 1
  true
);
```

### Step 5: Verify Creation

```sql
SELECT 
  t.tenant_code,
  t.tenant_name,
  u.email,
  u.first_name || ' ' || u.last_name as full_name,
  r.name as role
FROM tenants t
JOIN users u ON u.tenant_id = t.id
JOIN roles r ON r.id = u.role_id
WHERE t.tenant_code = 'ABC';
```

## Testing the New Tenant

### Test 1: Valid Login ✅

1. Navigate to `http://localhost:3000/login`
2. Select **"ABC Construction"** from dropdown
3. Enter:
   - Email: `admin@abcconstruction.com`
   - Password: `Test@123456`
4. Click **"Sign In"**

**Expected:** Login successful, redirected to `/erp-modules`

### Test 2: Wrong Tenant ❌

1. Navigate to `http://localhost:3000/login`
2. Select **"NTT Demo"** (wrong tenant)
3. Enter ABC user credentials
4. Click **"Sign In"**

**Expected:** Error: "You do not have access to the selected organization"

### Test 3: Data Isolation ✅

**As NTT User:**
1. Login as `admin@nttdemo.com` with NTT tenant
2. Note the data you see (projects, materials, etc.)

**As ABC User:**
1. Logout
2. Login as `admin@abcconstruction.com` with ABC tenant
3. Verify you see DIFFERENT data (or empty if no data created yet)

**Expected:** Each user sees only their tenant's data

### Test 4: Cookie Tampering ❌

1. Login as ABC user
2. Open DevTools (F12) → Application → Cookies
3. Find `tenant-id` cookie
4. Change its value to NTT tenant ID
5. Refresh the page

**Expected:** Redirected to login, cookie cleared

## Quick Verification Queries

### Check All Tenants
```sql
SELECT id, tenant_code, tenant_name, is_active 
FROM tenants 
ORDER BY tenant_name;
```

### Check Users by Tenant
```sql
SELECT 
  t.tenant_name,
  u.email,
  u.first_name || ' ' || u.last_name as name,
  r.name as role
FROM users u
JOIN tenants t ON u.tenant_id = t.id
JOIN roles r ON r.id = u.role_id
ORDER BY t.tenant_name, u.email;
```

### Check Data Distribution
```sql
SELECT 
  t.tenant_name,
  COUNT(DISTINCT p.id) as projects,
  COUNT(DISTINCT m.id) as materials,
  COUNT(DISTINCT u.id) as users
FROM tenants t
LEFT JOIN projects p ON p.tenant_id = t.id
LEFT JOIN materials m ON m.tenant_id = t.id
LEFT JOIN users u ON u.tenant_id = t.id
GROUP BY t.id, t.tenant_name
ORDER BY t.tenant_name;
```

## Troubleshooting

### Issue: "User profile not found"
**Solution:** Make sure you created the user profile in Step 4 with the correct user ID from Supabase Auth.

### Issue: "Tenant access denied"
**Solution:** Verify the `tenant_id` in the users table matches the tenant you're trying to login to.

### Issue: Can't see tenant in dropdown
**Solution:** Check that `is_active = true` in the tenants table.

### Issue: Login works but no data visible
**Solution:** This is expected if you haven't created any data for the new tenant yet. The isolation is working correctly!

## Creating Test Data for New Tenant

```sql
-- Replace {TENANT_ID} with your tenant ID

-- Create a test project
INSERT INTO projects (tenant_id, project_code, project_name, company_code, status, is_active)
VALUES (
  '{TENANT_ID}',
  'ABC-PRJ-001',
  'ABC Office Building',
  'ABC001',
  'active',
  true
);

-- Create a test material
INSERT INTO materials (tenant_id, material_code, material_name, description, base_uom, material_group, category, is_active)
VALUES (
  '{TENANT_ID}',
  'ABC-MAT-001',
  'Cement Bags',
  'Portland Cement 50kg',
  'BAG',
  'CONSTRUCTION',
  'RAW_MATERIAL',
  true
);
```

## Summary

✅ **Created:** Second tenant with admin user
✅ **Tested:** Login with correct tenant
✅ **Tested:** Login with wrong tenant (should fail)
✅ **Verified:** Data isolation between tenants
✅ **Verified:** Cookie tampering protection

**Next:** Run the full test suite from `TENANT_TESTING_PLAN.md`
