## FIX REQUIRED: AuthContext.tsx

The issue is on lines 87-90 and 104-107 where it fetches user profile:

### Current Code (WRONG):
```typescript
const { data: userProfile } = await supabase
  .from('users')
  .select('*, roles(*), tenants(*)')
  .eq('id', userId)  // ❌ This returns first match (OMEGA-TEST)
  .single()
```

### Fixed Code (CORRECT):
```typescript
// Get user email first
const { data: authUser } = await supabase.auth.getUser()
const userEmail = authUser?.user?.email

// Fetch user record for the selected tenant
const { data: userProfile } = await supabase
  .from('users')
  .select('*, roles(*), tenants(*)')
  .eq('email', userEmail)  // ✅ Match by email
  .eq('tenant_id', selectedTenantId || localStorage.getItem('selectedTenant'))  // ✅ Match by tenant
  .single()
```

### Changes needed in 2 places:
1. Line 87-90 (signIn function)
2. Line 104-107 (useEffect initialization)

This ensures the correct user record is fetched based on the selected tenant.
