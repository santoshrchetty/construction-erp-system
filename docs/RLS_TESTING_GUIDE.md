# RLS Testing with Sample Users

## Overview

Test script creates 4 sample users and verifies RLS policies work correctly.

## Sample Users Created

| User | Email | Organization | Role | Type |
|------|-------|--------------|------|------|
| Internal User | internal@abc.com | ABC Construction | ADMIN | Internal |
| Customer User | customer@acme.com | Acme Manufacturing | VIEWER | External |
| Vendor User | vendor@steel.com | Steel Supply Inc | CONTRIBUTOR | External |
| Contractor User | contractor@elite.com | Elite Electrical | CONTRIBUTOR | External |

## Test Script

**File**: `database/test_rls_with_users.sql`

## How to Run

```sql
\i database/test_rls_with_users.sql
```

## Tests Performed

### Test 1: Customer User Isolation
- Sets context to customer user
- Queries organizations and access grants
- **Expected**: See only 1 organization (Acme Manufacturing)

### Test 2: Vendor User Isolation
- Sets context to vendor user
- Queries organizations and access grants
- **Expected**: See only 1 organization (Steel Supply Inc)

### Test 3: Contractor User Isolation
- Sets context to contractor user
- Queries organizations and access grants
- **Expected**: See only 1 organization (Elite Electrical)

### Test 4: Internal User Access
- Sets context to internal user
- Queries organizations and access grants
- **Expected**: See only 1 organization (ABC Construction)

### Test 5: Cross-Organization Access Prevention
- Customer user tries to access vendor organization
- **Expected**: BLOCKED (returns NULL)

### Test 6: Helper Functions
- Tests `get_user_orgs()` function
- Tests `is_external_user()` function
- **Expected**: Correct organization list and external flag

## Expected Output

```
NOTICE:  Sample users created:
NOTICE:    Internal: <uuid> (internal@abc.com)
NOTICE:    Customer: <uuid> (customer@acme.com)
NOTICE:    Vendor: <uuid> (vendor@steel.com)
NOTICE:    Contractor: <uuid> (contractor@elite.com)

NOTICE:  === TEST 1: Customer User ===
NOTICE:  User: customer@acme.com
NOTICE:  Organizations visible: 1
NOTICE:  Resource access grants visible: 0-2
NOTICE:  Expected: 1 organization (Acme Manufacturing Corp)

NOTICE:  === TEST 2: Vendor User ===
NOTICE:  User: vendor@steel.com
NOTICE:  Organizations visible: 1
NOTICE:  Resource access grants visible: 1
NOTICE:  Expected: 1 organization (Steel Supply Inc)

NOTICE:  === TEST 3: Contractor User ===
NOTICE:  User: contractor@elite.com
NOTICE:  Organizations visible: 1
NOTICE:  Resource access grants visible: 1
NOTICE:  Expected: 1 organization (Elite Electrical Services)

NOTICE:  === TEST 4: Internal User ===
NOTICE:  User: internal@abc.com
NOTICE:  Organizations visible: 1
NOTICE:  Resource access grants visible: 0
NOTICE:  Expected: 1 organization (ABC Construction Company)

NOTICE:  === TEST 5: Cross-Organization Access ===
NOTICE:  Customer trying to access vendor org: BLOCKED ✓
NOTICE:  Expected: BLOCKED (RLS working correctly)

NOTICE:  === TEST 6: Helper Functions ===
NOTICE:  User organizations: Acme Manufacturing Corp
NOTICE:  Is external user: true
NOTICE:  Expected: Acme Manufacturing Corp, true

NOTICE:  === ALL TESTS COMPLETE ===
```

## Success Criteria

✅ Each user sees only 1 organization (their own)  
✅ Cross-organization access is blocked  
✅ Helper functions return correct values  
✅ Resource access is filtered by organization  

## Troubleshooting

### Issue: Users see all organizations
**Cause**: RLS not enabled or policies not applied  
**Fix**: Run `database/apply_rls_policies.sql` and `database/secure_remaining_tables.sql`

### Issue: Users see 0 organizations
**Cause**: User not linked to organization  
**Fix**: Check `external_org_users` table has correct mappings

### Issue: Session variable error
**Cause**: `app.current_user_id` not set  
**Fix**: Script sets this automatically, but verify with `SHOW app.current_user_id;`

## Manual Testing

After running the script, you can manually test:

```sql
-- Test as customer user
SET app.current_user_id = (SELECT id FROM users WHERE email = 'customer@acme.com');
SELECT * FROM external_organizations;
-- Should return only Acme Manufacturing

-- Test as vendor user
SET app.current_user_id = (SELECT id FROM users WHERE email = 'vendor@steel.com');
SELECT * FROM external_organizations;
-- Should return only Steel Supply Inc

-- Test cross-org access
SET app.current_user_id = (SELECT id FROM users WHERE email = 'customer@acme.com');
SELECT * FROM resource_access WHERE external_org_id = (
  SELECT external_org_id FROM external_organizations WHERE org_code = 'VEND001'
);
-- Should return 0 rows (blocked)
```

## Cleanup

To remove test users:

```sql
DELETE FROM external_org_users WHERE user_id IN (
  SELECT id FROM users WHERE email IN (
    'internal@abc.com', 'customer@acme.com', 
    'vendor@steel.com', 'contractor@elite.com'
  )
);

DELETE FROM users WHERE email IN (
  'internal@abc.com', 'customer@acme.com', 
  'vendor@steel.com', 'contractor@elite.com'
);
```

## Summary

This test script verifies that RLS policies are working correctly by:
1. Creating sample users for each organization
2. Testing that users can only see their own organization's data
3. Verifying cross-organization access is blocked
4. Confirming helper functions work correctly

**Run the script to verify your RLS implementation is secure!**
