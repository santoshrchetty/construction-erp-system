# Subdomain-Based Multi-Tenancy Implementation Guide

## What Was Implemented

### 1. Database Changes
- Added `subdomain` column to `tenants` table
- Created unique index for fast subdomain lookups
- Migration script: `migrations/add_subdomain_to_tenants.sql`

### 2. Subdomain Utility
- Created `lib/utils/subdomain.ts`
- Functions:
  - `extractSubdomain(hostname)` - Extracts subdomain from URL
  - `isLocalDevelopment(hostname)` - Detects localhost

### 3. Middleware Updates
- Extracts subdomain from request hostname
- Validates subdomain matches user's tenant (production only)
- Adds `x-subdomain` header to requests
- Skips subdomain validation in development

### 4. API Routes
- `GET /api/tenant/subdomain` - Fetch tenant by subdomain
- Uses service role key for public access

### 5. Authentication Updates
- AuthContext now supports optional tenant selection
- Validates subdomain matches user's tenant
- Falls back to tenant dropdown in development

### 6. Login Page Updates
- **Subdomain Mode** (Production): Shows tenant name, no dropdown
- **Dropdown Mode** (Development): Shows tenant selection dropdown
- Auto-detects mode based on hostname

---

## How It Works

### Production (Subdomain Mode)
```
URL: https://abc.omegadatalabs.com/login

1. User visits abc.omegadatalabs.com
2. Middleware extracts subdomain: "abc"
3. Login page fetches tenant by subdomain
4. Shows: "ABC Construction Ltd" (no dropdown)
5. User enters email + password
6. System validates user belongs to ABC tenant
7. Login successful
```

### Development (Dropdown Mode)
```
URL: http://localhost:3000/login

1. User visits localhost:3000
2. No subdomain detected
3. Login page shows tenant dropdown
4. User selects organization
5. User enters email + password
6. Login successful
```

---

## Database Migration

### Run Migration
```sql
-- Execute in Supabase SQL Editor
-- File: migrations/add_subdomain_to_tenants.sql

ALTER TABLE tenants 
ADD COLUMN IF NOT EXISTS subdomain VARCHAR(50) UNIQUE;

CREATE INDEX IF NOT EXISTS idx_tenants_subdomain ON tenants(subdomain);

UPDATE tenants 
SET subdomain = LOWER(REGEXP_REPLACE(tenant_code, '[^a-zA-Z]', '', 'g'))
WHERE subdomain IS NULL;
```

### Verify Migration
```sql
SELECT id, tenant_code, tenant_name, subdomain FROM tenants;
```

Expected output:
```
tenant_code | tenant_name           | subdomain
------------|----------------------|----------
ABC001      | ABC Construction Ltd | abc
XYZ001      | XYZ Builders         | xyz
NTT001      | NTT Infrastructure   | ntt
```

---

## DNS Configuration

### Wildcard DNS Setup
```
Type: CNAME
Name: *.omegadatalabs.com
Value: cname.vercel-dns.com
TTL: 3600
```

### Vercel Configuration
1. Go to Vercel Dashboard → Project Settings → Domains
2. Add domain: `*.omegadatalabs.com`
3. Vercel auto-provisions wildcard SSL
4. All subdomains now work: abc.omegadatalabs.com, xyz.omegadatalabs.com

---

## Testing

### Test Subdomain Detection
```typescript
// In browser console
import { extractSubdomain } from '@/lib/utils/subdomain'

extractSubdomain('abc.omegadatalabs.com')  // Returns: 'abc'
extractSubdomain('xyz.omegadatalabs.com')  // Returns: 'xyz'
extractSubdomain('localhost:3000')         // Returns: null
extractSubdomain('www.omegadatalabs.com')  // Returns: null
```

### Test Login Flow

**Development:**
1. Visit `http://localhost:3000/login`
2. Should see tenant dropdown
3. Select tenant → Enter credentials → Login

**Production:**
1. Visit `https://abc.omegadatalabs.com/login`
2. Should see "ABC Construction Ltd" (no dropdown)
3. Enter credentials → Login
4. If user doesn't belong to ABC tenant → Error

---

## Environment Variables

No new environment variables needed. Uses existing:
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

---

## Security Features

### 1. Subdomain Validation
- Middleware validates subdomain matches user's tenant
- Prevents cross-tenant access
- Only enforced in production

### 2. Tenant Cookie
- HttpOnly cookie stores tenant ID
- Validated on every request
- Cleared on logout

### 3. User-Tenant Validation
- User's tenant_id must match selected/detected tenant
- Enforced in AuthContext
- Session terminated on mismatch

---

## Backward Compatibility

### Development Mode
- Still shows tenant dropdown
- No breaking changes for local development
- Works exactly as before

### Production Mode
- Requires subdomain in URL
- Falls back to dropdown if no subdomain
- Graceful degradation

---

## Next Steps

### 1. Run Database Migration
```bash
# Copy SQL from migrations/add_subdomain_to_tenants.sql
# Paste in Supabase SQL Editor
# Execute
```

### 2. Update Existing Tenants
```sql
-- Set subdomains for existing tenants
UPDATE tenants SET subdomain = 'abc' WHERE tenant_code = 'ABC001';
UPDATE tenants SET subdomain = 'xyz' WHERE tenant_code = 'XYZ001';
UPDATE tenants SET subdomain = 'ntt' WHERE tenant_code = 'NTT001';
```

### 3. Configure DNS
- Add wildcard CNAME: `*.omegadatalabs.com`
- Point to Vercel

### 4. Add Domain in Vercel
- Add `*.omegadatalabs.com` in Vercel dashboard
- Wait for SSL provisioning (5-10 minutes)

### 5. Test
- Visit `https://abc.omegadatalabs.com/login`
- Should see tenant name without dropdown
- Login with user belonging to ABC tenant

---

## Troubleshooting

### Issue: Subdomain not detected
**Solution:** Check DNS propagation
```bash
nslookup abc.omegadatalabs.com
```

### Issue: SSL certificate error
**Solution:** Wait for Vercel SSL provisioning (5-10 minutes)

### Issue: Tenant not found
**Solution:** Verify subdomain exists in database
```sql
SELECT * FROM tenants WHERE subdomain = 'abc';
```

### Issue: User can't login
**Solution:** Verify user's tenant_id matches tenant
```sql
SELECT u.email, u.tenant_id, t.subdomain 
FROM users u 
JOIN tenants t ON u.tenant_id = t.id 
WHERE u.email = 'user@example.com';
```

---

## Files Modified

1. `types/schemas/tenants.schema.ts` - Added subdomain field
2. `lib/utils/subdomain.ts` - New utility file
3. `middleware.ts` - Subdomain extraction and validation
4. `lib/contexts/AuthContext.tsx` - Optional tenant selection
5. `app/login/page.tsx` - Dual mode (subdomain/dropdown)
6. `app/api/tenant/subdomain/route.ts` - New API endpoint
7. `migrations/add_subdomain_to_tenants.sql` - Database migration

---

## Architecture Diagram

```
User visits abc.omegadatalabs.com
         ↓
    DNS Resolution
         ↓
    Vercel Edge Network
         ↓
    Next.js Middleware
         ↓
  Extract subdomain: "abc"
         ↓
    Login Page
         ↓
  Fetch tenant by subdomain
         ↓
  Show: "ABC Construction Ltd"
         ↓
    User enters credentials
         ↓
    AuthContext.signIn()
         ↓
  Validate user.tenant_id == abc.tenant_id
         ↓
    Set tenant cookie
         ↓
    Redirect to /erp-modules
```

---

**Status:** ✅ Implementation Complete  
**Next:** Run database migration and configure DNS
