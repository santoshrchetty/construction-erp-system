# Quick Start: Enable SaaS Multi-Tenant Features

## Goal
Transform current implementation to support:
1. ✅ Subdomain-based tenant detection (abc.nexuserp.com)
2. ✅ Custom domain support (erp.abc-construction.com)
3. ✅ Fallback to tenant selection (on-premise mode)

**Time Required:** 2-3 hours

---

## Step 1: Database Schema Updates (5 minutes)

### Add SaaS Fields to Tenants Table

```sql
-- Run in Supabase SQL Editor

-- Add deployment and subscription fields
ALTER TABLE tenants 
ADD COLUMN IF NOT EXISTS deployment_type VARCHAR(20) DEFAULT 'public_saas',
ADD COLUMN IF NOT EXISTS subdomain VARCHAR(50) UNIQUE,
ADD COLUMN IF NOT EXISTS custom_domain VARCHAR(255),
ADD COLUMN IF NOT EXISTS subscription_status VARCHAR(20) DEFAULT 'active',
ADD COLUMN IF NOT EXISTS subscription_plan VARCHAR(50) DEFAULT 'professional',
ADD COLUMN IF NOT EXISTS features JSONB DEFAULT '{}';

-- Update existing tenant with subdomain
UPDATE tenants 
SET subdomain = 'ntt', 
    deployment_type = 'public_saas',
    subscription_status = 'active'
WHERE tenant_code = 'NTT';

-- Verify
SELECT id, tenant_code, tenant_name, subdomain, deployment_type, subscription_status
FROM tenants;
```

### Create Domain Mapping Table (Optional - for custom domains)

```sql
CREATE TABLE IF NOT EXISTS tenant_domains (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  domain VARCHAR(255) UNIQUE NOT NULL,
  domain_type VARCHAR(20) NOT NULL, -- 'subdomain', 'custom_domain'
  is_primary BOOLEAN DEFAULT false,
  ssl_status VARCHAR(20) DEFAULT 'active',
  verified_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Example: Add subdomain mapping
INSERT INTO tenant_domains (tenant_id, domain, domain_type, is_primary)
SELECT id, subdomain || '.nexuserp.com', 'subdomain', true
FROM tenants 
WHERE subdomain IS NOT NULL;
```

---

## Step 2: Update Middleware (30 minutes)

### Enhanced Tenant Detection

```typescript
// middleware.ts - Add this function before middleware()

interface TenantContext {
  tenantId: string | null
  tenantCode: string | null
  detectionMethod: 'subdomain' | 'custom_domain' | 'cookie' | 'none'
}

async function detectTenant(req: NextRequest): Promise<TenantContext> {
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return req.cookies.getAll() },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => {
            req.cookies.set(name, value)
          })
        },
      },
    }
  )
  
  const host = req.headers.get('host') || ''
  
  // 1. Try subdomain detection (abc.nexuserp.com or abc.localhost:3000)
  const subdomain = extractSubdomain(host)
  if (subdomain) {
    const { data: tenant } = await supabase
      .from('tenants')
      .select('id, tenant_code')
      .eq('subdomain', subdomain)
      .eq('is_active', true)
      .single()
    
    if (tenant) {
      return {
        tenantId: tenant.id,
        tenantCode: tenant.tenant_code,
        detectionMethod: 'subdomain'
      }
    }
  }
  
  // 2. Try custom domain mapping
  const { data: domainMapping } = await supabase
    .from('tenant_domains')
    .select('tenant_id, tenants(id, tenant_code)')
    .eq('domain', host)
    .eq('ssl_status', 'active')
    .single()
  
  if (domainMapping?.tenants) {
    return {
      tenantId: domainMapping.tenants.id,
      tenantCode: domainMapping.tenants.tenant_code,
      detectionMethod: 'custom_domain'
    }
  }
  
  // 3. Try cookie (after login)
  const tenantCookie = req.cookies.get('tenant-id')?.value
  if (tenantCookie) {
    const { data: tenant } = await supabase
      .from('tenants')
      .select('id, tenant_code')
      .eq('id', tenantCookie)
      .single()
    
    if (tenant) {
      return {
        tenantId: tenant.id,
        tenantCode: tenant.tenant_code,
        detectionMethod: 'cookie'
      }
    }
  }
  
  return { tenantId: null, tenantCode: null, detectionMethod: 'none' }
}

function extractSubdomain(host: string): string | null {
  // Remove port if present
  const hostname = host.split(':')[0]
  
  // Split by dots
  const parts = hostname.split('.')
  
  // For localhost: abc.localhost → 'abc'
  if (parts.length === 2 && parts[1] === 'localhost') {
    return parts[0] !== 'localhost' ? parts[0] : null
  }
  
  // For production: abc.nexuserp.com → 'abc'
  if (parts.length >= 3) {
    const subdomain = parts[0]
    // Ignore www and app
    if (subdomain !== 'www' && subdomain !== 'app') {
      return subdomain
    }
  }
  
  return null
}
```

### Update Middleware Function

```typescript
// Replace existing middleware function with this enhanced version

export async function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl
  
  // Skip middleware for static files, API routes, and public routes
  if (
    pathname.startsWith('/_next') ||
    pathname.startsWith('/api') ||
    pathname.includes('.') ||
    publicRoutes.includes(pathname)
  ) {
    if (pathname.startsWith('/api')) {
      const tenantContext = await detectTenant(req)
      const response = NextResponse.next()
      if (tenantContext.tenantId) {
        response.headers.set('x-tenant-id', tenantContext.tenantId)
        response.headers.set('x-tenant-code', tenantContext.tenantCode || '')
        response.headers.set('x-detection-method', tenantContext.detectionMethod)
      }
      return response
    }
    return NextResponse.next()
  }
  
  const res = NextResponse.next()
  
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return req.cookies.getAll() },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => {
            req.cookies.set(name, value)
            res.cookies.set(name, value)
          })
        },
      },
    }
  )
  
  const { data: { session } } = await supabase.auth.getSession()
  
  // Detect tenant from URL/cookie
  const tenantContext = await detectTenant(req)
  
  // Protect routes that require authentication
  if (!session && protectedRoutes.some(route => pathname.startsWith(route))) {
    const redirectUrl = new URL('/login', req.url)
    redirectUrl.searchParams.set('redirectTo', pathname)
    return NextResponse.redirect(redirectUrl)
  }
  
  // If authenticated, validate tenant access
  if (session) {
    // If no tenant detected and accessing protected route, redirect to login
    if (!tenantContext.tenantId && protectedRoutes.some(route => pathname.startsWith(route))) {
      const redirectUrl = new URL('/login', req.url)
      redirectUrl.searchParams.set('redirectTo', pathname)
      return NextResponse.redirect(redirectUrl)
    }
    
    // Validate user belongs to detected tenant
    if (tenantContext.tenantId) {
      const { data: profile } = await supabase
        .from('users')
        .select('tenant_id')
        .eq('id', session.user.id)
        .single()
      
      if (profile && profile.tenant_id !== tenantContext.tenantId) {
        // Tenant mismatch, clear session and redirect
        const response = NextResponse.redirect(new URL('/login', req.url))
        response.cookies.delete('tenant-id')
        return response
      }
    }
  }
  
  // Add tenant context to response headers
  const response = NextResponse.next()
  if (tenantContext.tenantId) {
    response.headers.set('x-tenant-id', tenantContext.tenantId)
    response.headers.set('x-tenant-code', tenantContext.tenantCode || '')
    response.headers.set('x-detection-method', tenantContext.detectionMethod)
  }
  
  // Add security headers
  response.headers.set('X-Frame-Options', 'DENY')
  response.headers.set('X-Content-Type-Options', 'nosniff')
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin')
  response.headers.set('X-XSS-Protection', '1; mode=block')
  
  return response
}
```

---

## Step 3: Update Login Page (30 minutes)

### Auto-Detect Tenant from URL

```typescript
// app/login/page.tsx - Add this useEffect after existing ones

useEffect(() => {
  detectTenantFromURL()
}, [])

const detectTenantFromURL = async () => {
  // Get hostname
  const hostname = window.location.hostname
  
  // Extract subdomain
  const parts = hostname.split('.')
  let subdomain = null
  
  // For localhost: abc.localhost
  if (parts.length === 2 && parts[1] === 'localhost') {
    subdomain = parts[0] !== 'localhost' ? parts[0] : null
  }
  // For production: abc.nexuserp.com
  else if (parts.length >= 3) {
    const sub = parts[0]
    if (sub !== 'www' && sub !== 'app') {
      subdomain = sub
    }
  }
  
  // If subdomain detected, find and auto-select tenant
  if (subdomain) {
    const tenant = tenants.find(t => 
      t.tenant_code.toLowerCase() === subdomain.toLowerCase()
    )
    if (tenant) {
      setTenantId(tenant.id)
      // Hide tenant dropdown (optional)
      setShowTenantDropdown(false)
    }
  }
}

// Add state for dropdown visibility
const [showTenantDropdown, setShowTenantDropdown] = useState(true)

// Update form to conditionally show dropdown
{showTenantDropdown && (
  <div>
    <select id="tenant" ...>
      ...
    </select>
  </div>
)}

{!showTenantDropdown && tenantId && (
  <div className="text-center text-sm text-gray-600 mb-4">
    Signing in to: {tenants.find(t => t.id === tenantId)?.tenant_name}
  </div>
)}
```

---

## Step 4: Test Locally (15 minutes)

### Setup Local Subdomain Testing

**Option 1: Edit hosts file (Windows)**
```
# C:\Windows\System32\drivers\etc\hosts

127.0.0.1 ntt.localhost
127.0.0.1 abc.localhost
```

**Option 2: Use .localhost (Chrome/Firefox support)**
```
# No configuration needed!
# Just access: http://ntt.localhost:3000
```

### Test Scenarios

1. **Subdomain Access:**
   ```
   http://ntt.localhost:3000/login
   → Should auto-detect NTT tenant
   → Tenant dropdown hidden
   → Shows "Signing in to: NTT Demo"
   ```

2. **Main Domain Access:**
   ```
   http://localhost:3000/login
   → No tenant detected
   → Shows tenant dropdown
   → User must select tenant
   ```

3. **Wrong Subdomain:**
   ```
   http://invalid.localhost:3000/login
   → No tenant found
   → Shows tenant dropdown
   → User can select correct tenant
   ```

---

## Step 5: Production Deployment

### DNS Configuration

```
# Add CNAME records for each tenant subdomain

ntt.nexuserp.com    CNAME    your-app.vercel.app
abc.nexuserp.com    CNAME    your-app.vercel.app
*.nexuserp.com      CNAME    your-app.vercel.app  (wildcard)
```

### Vercel Configuration

```json
// vercel.json
{
  "domains": [
    "nexuserp.com",
    "*.nexuserp.com"
  ],
  "wildcard": [
    {
      "domain": "*.nexuserp.com",
      "value": "nexuserp.com"
    }
  ]
}
```

### Environment Variables

```env
# .env.production
NEXT_PUBLIC_APP_URL=https://nexuserp.com
NEXT_PUBLIC_ENABLE_SUBDOMAIN=true
NEXT_PUBLIC_ENABLE_CUSTOM_DOMAIN=true
```

---

## Benefits After Implementation

### For Public SaaS Customers
✅ **Branded Experience:** abc.nexuserp.com shows ABC branding
✅ **No Tenant Selection:** Auto-detected from URL
✅ **Professional:** Custom domain support ready
✅ **Secure:** Tenant isolation enforced

### For Private/On-Premise Customers
✅ **Flexible:** Can still use tenant selection
✅ **Multi-Tenant:** Support multiple tenants on one domain
✅ **Compatible:** Works with existing setup

### For You (Platform Owner)
✅ **Scalable:** Add new tenants instantly
✅ **Marketable:** Professional SaaS offering
✅ **Flexible:** Support all deployment models
✅ **Secure:** Proper tenant isolation

---

## Rollout Strategy

### Week 1: Internal Testing
- ✅ Implement changes
- ✅ Test with localhost subdomains
- ✅ Verify tenant isolation

### Week 2: Staging Deployment
- ✅ Deploy to staging with real subdomains
- ✅ Test with 2-3 test tenants
- ✅ Verify DNS and SSL

### Week 3: Beta Launch
- ✅ Onboard 3-5 beta customers
- ✅ Gather feedback
- ✅ Fix issues

### Week 4: Production Launch
- ✅ Public announcement
- ✅ Marketing campaign
- ✅ Customer onboarding automation

---

## Monitoring & Alerts

### Key Metrics to Track
- Tenant detection success rate
- Login success rate per tenant
- API response time per tenant
- Subdomain resolution time
- SSL certificate status

### Alerts to Setup
- ⚠️ Tenant detection failure
- ⚠️ High login failure rate
- ⚠️ SSL certificate expiry
- ⚠️ Subdomain DNS issues

---

## Next Steps

1. **Run database migration** (Step 1)
2. **Update middleware** (Step 2)
3. **Update login page** (Step 3)
4. **Test locally** (Step 4)
5. **Deploy to staging** (Step 5)

**Total Time: 2-3 hours for basic SaaS functionality!**

Your construction ERP will be SaaS-ready! 🚀
