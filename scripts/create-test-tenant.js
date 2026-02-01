/**
 * Tenant Creation Helper Script
 * 
 * Usage: node scripts/create-test-tenant.js
 * 
 * This script creates a complete test tenant with:
 * - Tenant record
 * - Admin role
 * - Test user (must be created in Supabase Auth first)
 * - Sample data
 */

const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(query) {
  return new Promise(resolve => rl.question(query, resolve));
}

async function createTestTenant() {
  console.log('\n=== Tenant Creation Helper ===\n');
  
  // Collect tenant information
  const tenantCode = await question('Enter tenant code (e.g., ABC): ');
  const tenantName = await question('Enter tenant name (e.g., ABC Construction): ');
  const userEmail = await question('Enter admin email (e.g., admin@abc.com): ');
  const firstName = await question('Enter first name: ');
  const lastName = await question('Enter last name: ');
  const employeeCode = await question('Enter employee code (e.g., ABC0001): ');
  
  console.log('\n=== Summary ===');
  console.log(`Tenant Code: ${tenantCode}`);
  console.log(`Tenant Name: ${tenantName}`);
  console.log(`Admin Email: ${userEmail}`);
  console.log(`Admin Name: ${firstName} ${lastName}`);
  console.log(`Employee Code: ${employeeCode}`);
  
  const confirm = await question('\nProceed with creation? (yes/no): ');
  
  if (confirm.toLowerCase() !== 'yes') {
    console.log('Cancelled.');
    rl.close();
    return;
  }
  
  console.log('\n=== SQL Script Generated ===\n');
  console.log('Copy and run this in Supabase SQL Editor:\n');
  
  const sql = `
-- Step 1: Create Tenant
INSERT INTO tenants (id, tenant_code, tenant_name, is_active, created_at, updated_at)
VALUES (
  gen_random_uuid(),
  '${tenantCode}',
  '${tenantName}',
  true,
  NOW(),
  NOW()
)
RETURNING id, tenant_code, tenant_name;

-- Copy the tenant ID from above and replace {TENANT_ID} below

-- Step 2: Create Admin Role
INSERT INTO roles (id, tenant_id, name, description, permissions, is_active, created_at)
VALUES (
  gen_random_uuid(),
  '{TENANT_ID}',  -- Replace with tenant ID from Step 1
  'Admin',
  'System Administrator for ${tenantName}',
  '{"all": true}'::jsonb,
  true,
  NOW()
)
RETURNING id, name;

-- Copy the role ID from above and replace {ROLE_ID} below

-- Step 3: Create User in Supabase Auth Dashboard
-- Go to: Authentication → Users → Add User
-- Email: ${userEmail}
-- Password: Test@123456
-- Auto-confirm: Yes
-- Copy the generated User ID and replace {USER_ID} below

-- Step 4: Create User Profile
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
  '{USER_ID}',  -- Replace with Supabase auth user ID
  '${userEmail}',
  '${firstName}',
  '${lastName}',
  '{ROLE_ID}',  -- Replace with role ID from Step 2
  '${employeeCode}',
  'Administration',
  '{TENANT_ID}',  -- Replace with tenant ID from Step 1
  true,
  NOW(),
  NOW()
);

-- Step 5: Create Company Code
INSERT INTO company_codes (tenant_id, company_code, company_name, is_active)
VALUES (
  '{TENANT_ID}',
  '${tenantCode}001',
  '${tenantName} HQ',
  true
);

-- Step 6: Verify Creation
SELECT 
  t.tenant_code,
  t.tenant_name,
  u.email,
  u.first_name,
  u.last_name,
  r.name as role_name
FROM tenants t
LEFT JOIN users u ON u.tenant_id = t.id
LEFT JOIN roles r ON r.id = u.role_id
WHERE t.tenant_code = '${tenantCode}';
`;
  
  console.log(sql);
  
  console.log('\n=== Next Steps ===');
  console.log('1. Copy the SQL script above');
  console.log('2. Go to Supabase Dashboard → SQL Editor');
  console.log('3. Run Step 1, copy the tenant ID');
  console.log('4. Replace {TENANT_ID} in the script');
  console.log('5. Run Step 2, copy the role ID');
  console.log('6. Replace {ROLE_ID} in the script');
  console.log('7. Go to Authentication → Users → Add User');
  console.log(`   Email: ${userEmail}`);
  console.log('   Password: Test@123456');
  console.log('8. Copy the user ID, replace {USER_ID}');
  console.log('9. Run Steps 4-6');
  console.log('10. Test login with the new credentials\n');
  
  rl.close();
}

createTestTenant().catch(console.error);
