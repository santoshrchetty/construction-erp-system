-- ============================================
-- MULTI-TENANT TEST SETUP SCRIPT
-- ============================================
-- Purpose: Create a second tenant with user and test data
-- to validate tenant isolation and authentication
-- ============================================

-- Step 1: Create Second Tenant
-- ============================================
INSERT INTO tenants (id, tenant_code, tenant_name, is_active, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  'ABC',
  'ABC Construction Company',
  true,
  NOW(),
  NOW()
)
RETURNING id, tenant_code, tenant_name;

-- Save the returned tenant ID for next steps
-- Example: abc_tenant_id = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'


-- Step 2: Create Admin Role for Second Tenant
-- ============================================
-- Replace {ABC_TENANT_ID} with the ID from Step 1
INSERT INTO roles (id, tenant_id, name, description, permissions, is_active, created_at)
VALUES (
  gen_random_uuid(),
  '{ABC_TENANT_ID}',  -- Replace with actual tenant ID
  'Admin',
  'System Administrator for ABC Construction',
  '{"all": true}'::jsonb,
  true,
  NOW()
)
RETURNING id, name;

-- Save the returned role ID
-- Example: abc_admin_role_id = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'


-- Step 3: Create Test User in Supabase Auth
-- ============================================
-- This must be done via Supabase Dashboard or API:
-- Email: admin@abcconstruction.com
-- Password: Test@123456
-- After creating, get the user's UUID from auth.users table


-- Step 4: Create User Profile
-- ============================================
-- Replace {ABC_USER_ID} with the UUID from Supabase auth.users
-- Replace {ABC_TENANT_ID} with tenant ID from Step 1
-- Replace {ABC_ADMIN_ROLE_ID} with role ID from Step 2
INSERT INTO users (
  id,
  email,
  first_name,
  last_name,
  role_id,
  employee_code,
  department,
  tenant_id,
  is_active,
  created_at,
  updated_at
)
VALUES (
  '{ABC_USER_ID}',  -- Replace with Supabase auth user ID
  'admin@abcconstruction.com',
  'John',
  'Smith',
  '{ABC_ADMIN_ROLE_ID}',  -- Replace with role ID
  'ABC0001',
  'Administration',
  '{ABC_TENANT_ID}',  -- Replace with tenant ID
  true,
  NOW(),
  NOW()
);


-- Step 5: Create Test Data for ABC Tenant
-- ============================================

-- Create Company Code
INSERT INTO company_codes (tenant_id, company_code, company_name, is_active)
VALUES (
  '{ABC_TENANT_ID}',
  'ABC001',
  'ABC Construction HQ',
  true
);

-- Create Test Project
INSERT INTO projects (
  tenant_id,
  project_code,
  project_name,
  company_code,
  status,
  is_active
)
VALUES (
  '{ABC_TENANT_ID}',
  'ABC-PRJ-001',
  'ABC Office Building',
  'ABC001',
  'active',
  true
);

-- Create Test Material
INSERT INTO materials (
  tenant_id,
  material_code,
  material_name,
  description,
  base_uom,
  material_group,
  category,
  is_active
)
VALUES (
  '{ABC_TENANT_ID}',
  'ABC-MAT-001',
  'ABC Cement Bags',
  'Portland Cement 50kg',
  'BAG',
  'CONSTRUCTION',
  'RAW_MATERIAL',
  true
);


-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Verify Tenant Created
SELECT id, tenant_code, tenant_name, is_active 
FROM tenants 
WHERE tenant_code = 'ABC';

-- Verify Role Created
SELECT r.id, r.name, r.tenant_id, t.tenant_name
FROM roles r
JOIN tenants t ON r.tenant_id = t.id
WHERE t.tenant_code = 'ABC';

-- Verify User Created
SELECT u.id, u.email, u.first_name, u.last_name, u.tenant_id, t.tenant_name
FROM users u
JOIN tenants t ON u.tenant_id = t.id
WHERE u.email = 'admin@abcconstruction.com';

-- Count Data by Tenant
SELECT 
  t.tenant_name,
  COUNT(DISTINCT p.id) as projects,
  COUNT(DISTINCT m.id) as materials
FROM tenants t
LEFT JOIN projects p ON p.tenant_id = t.id
LEFT JOIN materials m ON m.tenant_id = t.id
GROUP BY t.id, t.tenant_name
ORDER BY t.tenant_name;


-- ============================================
-- CLEANUP (if needed)
-- ============================================
-- Uncomment to remove test tenant

-- DELETE FROM users WHERE email = 'admin@abcconstruction.com';
-- DELETE FROM roles WHERE tenant_id = '{ABC_TENANT_ID}';
-- DELETE FROM projects WHERE tenant_id = '{ABC_TENANT_ID}';
-- DELETE FROM materials WHERE tenant_id = '{ABC_TENANT_ID}';
-- DELETE FROM company_codes WHERE tenant_id = '{ABC_TENANT_ID}';
-- DELETE FROM tenants WHERE tenant_code = 'ABC';
