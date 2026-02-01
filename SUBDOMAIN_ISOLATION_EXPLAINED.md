# Subdomain-Based Tenant Isolation - Deep Dive

## Concept Overview

**Subdomain-based tenant isolation** means each tenant gets their own unique URL (subdomain) that automatically identifies them, eliminating the need for manual tenant selection.

---

## Visual Comparison

### Current Implementation (Tenant Selection)

```
User Experience:
┌─────────────────────────────────────────┐
│ User visits: https://nexuserp.com      │
│                                         │
│ Login Page:                             │
│ ┌─────────────────────────────────┐    │
│ │ Select Organization: [▼ Dropdown]│    │ ← User must choose
│ │   - ABC Construction            │    │
│ │   - XYZ Builders                │    │
│ │   - NTT Projects                │    │
│ │                                 │    │
│ │ Email: [____________]           │    │
│ │ Password: [____________]        │    │
│ │ [Sign In]                       │    │
│ └─────────────────────────────────┘    │
└─────────────────────────────────────────┘

Problems:
❌ User sees all tenants (security concern)
❌ Extra step (poor UX)
❌ Not professional for SaaS
❌ Tenant enumeration possible
```

### Subdomain-Based Isolation (SaaS)

```
User Experience:
┌─────────────────────────────────────────┐
│ ABC User visits: https://abc.nexuserp.com
│                                         │
│ Login Page:                             │
│ ┌─────────────────────────────────┐    │
│ │ ABC Construction                │    │ ← Auto-detected!
│ │                                 │    │
│ │ Email: [____________]           │    │
│ │ Password: [____________]        │    │
│ │ [Sign In]                       │    │
│ └─────────────────────────────────┘    │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ XYZ User visits: https://xyz.nexuserp.com
│                                         │
│ Login Page:                             │
│ ┌─────────────────────────────────┐    │
│ │ XYZ Builders                    │    │ ← Different tenant!
│ │                                 │    │
│ │ Email: [____________]           │    │
│ │ Password: [____________]        │    │
│ │ [Sign In]                       │    │
│ └─────────────────────────────────┘    │
└─────────────────────────────────────────┘

Benefits:
✅ Tenant auto-detected from URL
✅ No dropdown needed
✅ Professional SaaS experience
✅ Each tenant isolated by URL
✅ No tenant enumeration
```

---

## How It Works Technically

### Step 1: URL Structure

```
Standard URL Format:
https://subdomain.domain.com/path

Example:
https://abc.nexuserp.com/login
         ↑
    Subdomain = "abc"
```

### Step 2: Subdomain Extraction

```typescript
// Extract subdomain from URL
function extractSubdomain(host: string): string | null {
  // host = "abc.nexuserp.com"
  
  const parts = host.split('.')
  // parts = ["abc", "nexuserp", "com"]
  
  if (parts.length >= 3) {
    const subdomain = parts[0]
    // subdomain = "abc"
    
    // Ignore common subdomains
    if (subdomain !== 'www' && subdomain !== 'app') {
      return subdomain  // Returns "abc"
    }
  }
  
  return null
}
```

### Step 3: Tenant Lookup

```typescript
// Database lookup
const { data: tenant } = await supabase
  .from('tenants')
  .select('id, tenant_code, tenant_name')
  .eq('subdomain', 'abc')  // Match subdomain
  .eq('is_active', true)
  .single()

// Result:
// {
//   id: "9bd339ec-9877-4d9f-b3dc-3e60048c1b15",
//   tenant_code: "ABC",
//   tenant_name: "ABC Construction"
// }
```

### Step 4: Automatic Tenant Context

```typescript
// Middleware sets tenant context automatically
response.headers.set('x-tenant-id', tenant.id)
response.headers.set('x-tenant-code', tenant.tenant_code)

// All downstream requests know the tenant!
```

---

## Complete Request Flow

### Scenario: User Accesses abc.nexuserp.com

```
1. Browser Request
   ↓
   GET https://abc.nexuserp.com/login
   Host: abc.nexuserp.com

2. Next.js Middleware (FIRST TO RUN)
   ↓
   Extract subdomain: "abc"
   ↓
   Query database: SELECT * FROM tenants WHERE subdomain = 'abc'
   ↓
   Found: tenant_id = "9bd339ec..."
   ↓
   Set headers: x-tenant-id = "9bd339ec..."
   ↓
   Continue to page

3. Login Page Component
   ↓
   Detect subdomain from window.location.hostname
   ↓
   Auto-select tenant (hide dropdown)
   ↓
   Show branded login: "ABC Construction"

4. User Enters Credentials
   ↓
   Submit: email + password + tenant_id (auto-filled)

5. Authentication
   ↓
   Validate credentials
   ↓
   Validate user belongs to tenant "9bd339ec..."
   ↓
   Set tenant cookie: tenant-id = "9bd339ec..."
   ↓
   Redirect to /erp-modules

6. All Subsequent Requests
   ↓
   Middleware checks:
   - Subdomain = "abc" → tenant_id = "9bd339ec..."
   - Cookie = "9bd339ec..."
   - Match? ✅ Allow
   - Mismatch? ❌ Redirect to login
```

---

## Isolation Mechanisms

### 1. URL-Level Isolation

```
Tenant A: https://abc.nexuserp.com
Tenant B: https://xyz.nexuserp.com
Tenant C: https://ntt.nexuserp.com

Each URL is completely separate:
- Different subdomain
- Different tenant context
- Different data access
- Different branding
```

### 2. Middleware-Level Isolation

```typescript
// Every request goes through middleware
export async function middleware(req: NextRequest) {
  // Extract tenant from subdomain
  const subdomain = extractSubdomain(req.headers.get('host'))
  
  // Lookup tenant
  const tenant = await getTenantBySubdomain(subdomain)
  
  if (!tenant) {
    // Invalid subdomain → redirect to main site
    return NextResponse.redirect('https://nexuserp.com')
  }
  
  // Set tenant context for this request
  response.headers.set('x-tenant-id', tenant.id)
  
  // All API routes will use this tenant_id
}
```

### 3. Database-Level Isolation

```sql
-- Every query automatically filtered by tenant
SELECT * FROM projects 
WHERE tenant_id = '9bd339ec...'  -- From middleware header

SELECT * FROM materials 
WHERE tenant_id = '9bd339ec...'  -- Same tenant

-- Tenant B cannot see Tenant A's data
-- Even if they try to manipulate the request
```

### 4. Cookie-Level Isolation

```
Cookies are domain-specific:

abc.nexuserp.com cookies:
- tenant-id = "9bd339ec..." (ABC tenant)
- session-token = "xyz..."

xyz.nexuserp.com cookies:
- tenant-id = "xxxxxxxx..." (XYZ tenant)
- session-token = "abc..."

Browser keeps them separate automatically!
```

---

## Security Benefits

### 1. No Tenant Enumeration

**Current (Dropdown):**
```
User visits login page
→ Sees dropdown with ALL tenants
→ Can enumerate: "ABC", "XYZ", "NTT", etc.
→ Security risk: attacker knows all tenants
```

**Subdomain-Based:**
```
User visits abc.nexuserp.com
→ Only sees "ABC Construction"
→ No knowledge of other tenants
→ Cannot enumerate tenants
```

### 2. Automatic Validation

```typescript
// Middleware validates on EVERY request
if (subdomain === 'abc' && userTenantId !== 'abc-tenant-id') {
  // User from XYZ trying to access ABC subdomain
  return redirect('/login')  // Blocked!
}
```

### 3. Browser-Level Isolation

```
Different subdomains = Different origins (CORS)

abc.nexuserp.com cannot access:
- xyz.nexuserp.com cookies
- xyz.nexuserp.com localStorage
- xyz.nexuserp.com sessionStorage

Complete browser-level isolation!
```

### 4. DNS-Level Isolation

```
Each subdomain can have:
- Different IP address (if needed)
- Different SSL certificate
- Different CDN configuration
- Different rate limiting
```

---

## Real-World Examples

### Example 1: Slack

```
Your workspace: acme.slack.com
Other workspace: xyz.slack.com

You cannot access xyz.slack.com even if you know the URL
Each workspace is completely isolated
```

### Example 2: Shopify

```
Your store: mystore.myshopify.com
Other store: otherstore.myshopify.com

Each store has its own subdomain
Complete data isolation
```

### Example 3: Zendesk

```
Your support: acme.zendesk.com
Other support: xyz.zendesk.com

Subdomain-based multi-tenancy
Industry standard for SaaS
```

---

## Implementation in Your App

### Database Schema

```sql
-- Add subdomain column to tenants table
ALTER TABLE tenants ADD COLUMN subdomain VARCHAR(50) UNIQUE;

-- Update existing tenants
UPDATE tenants SET subdomain = 'ntt' WHERE tenant_code = 'NTT';
UPDATE tenants SET subdomain = 'abc' WHERE tenant_code = 'ABC';

-- Create index for fast lookup
CREATE INDEX idx_tenants_subdomain ON tenants(subdomain);
```

### Middleware Enhancement

```typescript
// middleware.ts
async function detectTenant(req: NextRequest) {
  const host = req.headers.get('host') || ''
  const subdomain = extractSubdomain(host)
  
  if (subdomain) {
    // Lookup tenant by subdomain
    const { data: tenant } = await supabase
      .from('tenants')
      .select('id, tenant_code, tenant_name')
      .eq('subdomain', subdomain)
      .eq('is_active', true)
      .single()
    
    if (tenant) {
      return {
        tenantId: tenant.id,
        tenantCode: tenant.tenant_code,
        tenantName: tenant.tenant_name,
        method: 'subdomain'
      }
    }
  }
  
  // Fallback to cookie or manual selection
  return { tenantId: null, method: 'none' }
}
```

### Login Page Enhancement

```typescript
// app/login/page.tsx
useEffect(() => {
  const hostname = window.location.hostname
  const subdomain = extractSubdomain(hostname)
  
  if (subdomain) {
    // Find tenant by subdomain
    const tenant = tenants.find(t => 
      t.tenant_code.toLowerCase() === subdomain.toLowerCase()
    )
    
    if (tenant) {
      setTenantId(tenant.id)
      setShowTenantDropdown(false)  // Hide dropdown
      setDetectedTenant(tenant)      // Show branded header
    }
  }
}, [tenants])

// Render
{detectedTenant ? (
  <div className="text-center mb-4">
    <h2 className="text-2xl font-semibold">{detectedTenant.tenant_name}</h2>
  </div>
) : (
  <select>...</select>  // Show dropdown only if no subdomain
)}
```

---

## Testing Locally

### Setup Local Subdomains

**Option 1: Edit hosts file (Windows)**
```
# C:\Windows\System32\drivers\etc\hosts
127.0.0.1 ntt.localhost
127.0.0.1 abc.localhost
```

**Option 2: Use .localhost (Chrome/Firefox)**
```
# No configuration needed!
http://ntt.localhost:3000  ← Works automatically
http://abc.localhost:3000  ← Works automatically
```

### Test Scenarios

```
1. Access http://ntt.localhost:3000/login
   → Should show "NTT Projects"
   → No tenant dropdown
   → Auto-selects NTT tenant

2. Access http://abc.localhost:3000/login
   → Should show "ABC Construction"
   → No tenant dropdown
   → Auto-selects ABC tenant

3. Access http://localhost:3000/login
   → No subdomain detected
   → Shows tenant dropdown
   → User must select manually

4. Login as NTT user on abc.localhost:3000
   → Should fail: "You do not have access to this organization"
   → Tenant mismatch detected
```

---

## Production Deployment

### DNS Configuration

```
# Add CNAME records for each tenant

ntt.nexuserp.com    CNAME    your-app.vercel.app
abc.nexuserp.com    CNAME    your-app.vercel.app
xyz.nexuserp.com    CNAME    your-app.vercel.app

# Or use wildcard (recommended)
*.nexuserp.com      CNAME    your-app.vercel.app
```

### SSL Certificates

```
Wildcard SSL certificate covers all subdomains:
*.nexuserp.com

Automatically includes:
- abc.nexuserp.com
- xyz.nexuserp.com
- ntt.nexuserp.com
- any-new-tenant.nexuserp.com
```

### Vercel Configuration

```json
// vercel.json
{
  "domains": [
    "nexuserp.com",
    "*.nexuserp.com"
  ]
}
```

---

## Advantages Over Current Implementation

| Aspect | Current (Dropdown) | Subdomain-Based |
|--------|-------------------|-----------------|
| **UX** | Extra step (select tenant) | Automatic (no selection) |
| **Security** | All tenants visible | Only own tenant visible |
| **Branding** | Generic login page | Branded per tenant |
| **Professional** | Looks internal | Looks like SaaS |
| **Isolation** | Application-level | URL + Application-level |
| **Enumeration** | Possible (see all tenants) | Impossible (isolated URLs) |
| **Custom Domain** | Not supported | Easy to add |
| **White-Label** | Difficult | Easy (per subdomain) |

---

## Summary

**Subdomain-based tenant isolation** means:

1. **Each tenant gets unique URL**: abc.nexuserp.com, xyz.nexuserp.com
2. **Automatic tenant detection**: No dropdown needed
3. **Complete isolation**: URL, cookies, data, branding
4. **Professional SaaS experience**: Like Slack, Shopify, Zendesk
5. **Better security**: No tenant enumeration, automatic validation
6. **Scalable**: Add new tenants instantly (just DNS + database)

**Implementation time: 2-3 hours**
**Result: Professional SaaS platform ready for customers!** 🚀
