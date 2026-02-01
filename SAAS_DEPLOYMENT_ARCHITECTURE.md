# SaaS Deployment Architecture: Public & Private

## Vision Statement

**Nexus Construction ERP** - A flexible SaaS platform deployable as:
1. **Public Cloud SaaS** - Multi-tenant shared infrastructure
2. **Private Cloud** - Dedicated tenant infrastructure
3. **On-Premise** - Customer-hosted deployment

---

## Deployment Models

### Model 1: Public Cloud SaaS (Multi-Tenant)

**Architecture:**
```
Single Supabase Instance
├── Shared Database
│   ├── Tenant: ABC Construction (tenant_id: xxx)
│   ├── Tenant: XYZ Builders (tenant_id: yyy)
│   └── Tenant: NTT Projects (tenant_id: zzz)
│
└── Shared Application Server
    ├── https://abc.nexuserp.com
    ├── https://xyz.nexuserp.com
    └── https://ntt.nexuserp.com
```

**Characteristics:**
- ✅ Shared infrastructure (cost-effective)
- ✅ Subdomain per tenant (white-labeling)
- ✅ Row-Level Security (RLS) for data isolation
- ✅ Rapid deployment (minutes)
- ✅ Automatic updates
- ⚠️ Shared resources (noisy neighbor risk)
- ⚠️ Data residency concerns

**Pricing:** $99-$499/month per tenant

---

### Model 2: Private Cloud (Dedicated Tenant)

**Architecture:**
```
Dedicated Supabase Instance per Tenant
├── ABC Construction
│   ├── Dedicated Database
│   ├── Dedicated Auth
│   └── https://erp.abc-construction.com
│
└── XYZ Builders
    ├── Dedicated Database
    ├── Dedicated Auth
    └── https://erp.xyz-builders.com
```

**Characteristics:**
- ✅ Complete isolation (dedicated infrastructure)
- ✅ Custom domain support
- ✅ Data residency compliance
- ✅ Performance guarantees
- ✅ Custom configurations
- ❌ Higher cost
- ❌ Longer deployment time

**Pricing:** $999-$2,999/month per tenant

---

### Model 3: On-Premise (Self-Hosted)

**Architecture:**
```
Customer Infrastructure
├── Customer's Supabase (or PostgreSQL)
├── Customer's Application Server
├── Customer's Domain
└── Customer manages everything
```

**Characteristics:**
- ✅ Complete control
- ✅ Data stays on-premise
- ✅ Compliance (banking, defense, government)
- ✅ Customization freedom
- ❌ Customer manages updates
- ❌ Customer manages infrastructure
- ❌ Higher TCO

**Pricing:** $10,000-$50,000 perpetual license + support

---

## Technical Architecture for SaaS

### Hybrid Tenant Identification Strategy

**Support ALL access patterns:**

```typescript
// Pattern 1: Subdomain-based (Public SaaS)
https://abc.nexuserp.com → Auto-detect tenant: ABC

// Pattern 2: Custom domain (Private Cloud)
https://erp.abc-construction.com → Tenant from domain mapping

// Pattern 3: Tenant selection (On-Premise)
https://erp.company.com → User selects tenant at login

// Pattern 4: Path-based (Alternative)
https://nexuserp.com/abc → Tenant from URL path
```

### Enhanced Middleware for SaaS

```typescript
// middleware.ts
export async function middleware(req: NextRequest) {
  const { pathname } = req.nextUrl
  
  // 1. Extract tenant from multiple sources
  const tenantContext = await extractTenantContext(req)
  
  // 2. Validate tenant exists and is active
  const tenant = await validateTenant(tenantContext)
  
  // 3. Check subscription status (SaaS-specific)
  if (tenant.subscription_status !== 'active') {
    return NextResponse.redirect(new URL('/subscription-expired', req.url))
  }
  
  // 4. Apply tenant-specific configuration
  const config = await getTenantConfig(tenant.id)
  
  // 5. Set tenant context for downstream
  const response = NextResponse.next()
  response.headers.set('x-tenant-id', tenant.id)
  response.headers.set('x-tenant-code', tenant.tenant_code)
  response.headers.set('x-deployment-type', tenant.deployment_type)
  
  return response
}

async function extractTenantContext(req: NextRequest) {
  // Priority 1: Subdomain
  const host = req.headers.get('host')
  const subdomain = extractSubdomain(host)
  if (subdomain) return { type: 'subdomain', value: subdomain }
  
  // Priority 2: Custom domain mapping
  const customDomain = await getCustomDomainMapping(host)
  if (customDomain) return { type: 'custom_domain', value: customDomain.tenant_code }
  
  // Priority 3: Cookie (after login)
  const tenantCookie = req.cookies.get('tenant-id')?.value
  if (tenantCookie) return { type: 'cookie', value: tenantCookie }
  
  // Priority 4: Path-based
  const pathTenant = extractTenantFromPath(req.nextUrl.pathname)
  if (pathTenant) return { type: 'path', value: pathTenant }
  
  return null
}
```

---

## Database Schema Enhancements for SaaS

### Add SaaS-Specific Fields to Tenants Table

```sql
ALTER TABLE tenants ADD COLUMN IF NOT EXISTS deployment_type VARCHAR(20) DEFAULT 'public_saas';
-- Values: 'public_saas', 'private_cloud', 'on_premise'

ALTER TABLE tenants ADD COLUMN IF NOT EXISTS subscription_status VARCHAR(20) DEFAULT 'trial';
-- Values: 'trial', 'active', 'suspended', 'cancelled'

ALTER TABLE tenants ADD COLUMN IF NOT EXISTS subscription_plan VARCHAR(50);
-- Values: 'starter', 'professional', 'enterprise', 'custom'

ALTER TABLE tenants ADD COLUMN IF NOT EXISTS subscription_start_date TIMESTAMP;
ALTER TABLE tenants ADD COLUMN IF NOT EXISTS subscription_end_date TIMESTAMP;

ALTER TABLE tenants ADD COLUMN IF NOT EXISTS custom_domain VARCHAR(255);
-- Example: 'erp.abc-construction.com'

ALTER TABLE tenants ADD COLUMN IF NOT EXISTS subdomain VARCHAR(50) UNIQUE;
-- Example: 'abc' for abc.nexuserp.com

ALTER TABLE tenants ADD COLUMN IF NOT EXISTS max_users INTEGER DEFAULT 10;
ALTER TABLE tenants ADD COLUMN IF NOT EXISTS max_projects INTEGER DEFAULT 50;
ALTER TABLE tenants ADD COLUMN IF NOT EXISTS max_storage_gb INTEGER DEFAULT 10;

ALTER TABLE tenants ADD COLUMN IF NOT EXISTS features JSONB DEFAULT '{}';
-- Example: {"advanced_reporting": true, "api_access": true, "white_label": false}

ALTER TABLE tenants ADD COLUMN IF NOT EXISTS billing_email VARCHAR(255);
ALTER TABLE tenants ADD COLUMN IF NOT EXISTS billing_contact VARCHAR(255);
```

### Create Domain Mapping Table

```sql
CREATE TABLE tenant_domains (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  domain VARCHAR(255) UNIQUE NOT NULL,
  domain_type VARCHAR(20) NOT NULL, -- 'subdomain', 'custom_domain'
  is_primary BOOLEAN DEFAULT false,
  ssl_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'active', 'failed'
  verified_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(tenant_id, is_primary) WHERE is_primary = true
);

-- Examples:
-- ('tenant-abc-id', 'abc.nexuserp.com', 'subdomain', true, 'active')
-- ('tenant-abc-id', 'erp.abc-construction.com', 'custom_domain', false, 'active')
```

### Create Subscription Tracking Table

```sql
CREATE TABLE tenant_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE,
  plan_name VARCHAR(50) NOT NULL,
  status VARCHAR(20) NOT NULL,
  start_date TIMESTAMP NOT NULL,
  end_date TIMESTAMP,
  auto_renew BOOLEAN DEFAULT true,
  monthly_price DECIMAL(10,2),
  currency VARCHAR(3) DEFAULT 'USD',
  payment_method VARCHAR(50),
  last_payment_date TIMESTAMP,
  next_payment_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

## Login Flow for SaaS

### Scenario 1: Public SaaS with Subdomain

```
User visits: https://abc.nexuserp.com/login

1. Middleware detects subdomain: "abc"
2. Lookup tenant by subdomain → tenant_id
3. Login page shows:
   ┌─────────────────────────────┐
   │ ABC Construction            │ ← Branded
   │                             │
   │ Email: [____________]       │
   │ Password: [____________]    │
   │                             │
   │ [Sign In]                   │
   └─────────────────────────────┘
   
4. No tenant selection needed (auto-detected)
5. Validate user belongs to ABC tenant
6. Set tenant cookie and redirect
```

### Scenario 2: Private Cloud with Custom Domain

```
User visits: https://erp.abc-construction.com/login

1. Middleware looks up custom domain mapping
2. Find tenant_id for "erp.abc-construction.com"
3. Same flow as Scenario 1 (auto-detected)
```

### Scenario 3: On-Premise Multi-Tenant

```
User visits: https://erp.company.com/login

1. No subdomain/custom domain detected
2. Login page shows tenant selection:
   ┌─────────────────────────────┐
   │ Company ERP                 │
   │                             │
   │ Organization: [▼ Select]    │ ← Dropdown
   │ Email: [____________]       │
   │ Password: [____________]    │
   │                             │
   │ [Sign In]                   │
   └─────────────────────────────┘
   
3. User selects tenant from dropdown
4. Validate and proceed
```

---

## Implementation Roadmap

### Phase 1: Current State Enhancement (Week 1-2)
- ✅ Tenant validation at login (DONE)
- ✅ Server-side tenant cookies (DONE)
- ✅ Middleware enforcement (DONE)
- ⏳ Add deployment_type to tenants table
- ⏳ Add subdomain column to tenants table
- ⏳ Update middleware to detect subdomain

### Phase 2: Subdomain Support (Week 3-4)
- ⏳ Implement subdomain extraction in middleware
- ⏳ Auto-detect tenant from subdomain
- ⏳ Hide tenant dropdown if subdomain detected
- ⏳ Update login page for branded experience
- ⏳ Test with local subdomain (abc.localhost:3000)

### Phase 3: Custom Domain Support (Week 5-6)
- ⏳ Create tenant_domains table
- ⏳ Implement domain mapping lookup
- ⏳ Add SSL certificate management
- ⏳ Domain verification workflow
- ⏳ DNS configuration guide

### Phase 4: Subscription Management (Week 7-8)
- ⏳ Create subscription tables
- ⏳ Implement subscription checks in middleware
- ⏳ Add usage tracking (users, projects, storage)
- ⏳ Subscription expiry handling
- ⏳ Payment integration (Stripe/Razorpay)

### Phase 5: Multi-Deployment Support (Week 9-10)
- ⏳ Support all three deployment models
- ⏳ Deployment-specific configuration
- ⏳ Feature flags per deployment type
- ⏳ White-labeling support
- ⏳ Tenant onboarding automation

---

## Pricing Strategy

### Public SaaS Plans

| Plan | Price/Month | Users | Projects | Storage | Features |
|------|-------------|-------|----------|---------|----------|
| **Starter** | $99 | 5 | 10 | 5 GB | Basic modules |
| **Professional** | $299 | 25 | 50 | 25 GB | All modules + API |
| **Enterprise** | $499 | 100 | Unlimited | 100 GB | Everything + Support |

### Private Cloud

| Plan | Price/Month | Description |
|------|-------------|-------------|
| **Dedicated** | $999 | Dedicated Supabase instance |
| **Premium** | $1,999 | + Custom domain + SLA |
| **Enterprise** | Custom | + On-call support + Custom features |

### On-Premise

| License | Price | Description |
|---------|-------|-------------|
| **Perpetual** | $10,000 | One-time + 20% annual support |
| **Enterprise** | $25,000 | + Source code + Customization |
| **Government** | Custom | Compliance + Air-gapped deployment |

---

## Competitive Positioning

### vs Procore
- ✅ Lower cost (Procore: $500-$1,000/month)
- ✅ On-premise option (Procore: Cloud only)
- ✅ Indian market focus (GST, local compliance)

### vs Buildertrend
- ✅ Enterprise features (Buildertrend: SMB focus)
- ✅ Multi-company support
- ✅ SAP integration ready

### vs Custom Development
- ✅ Faster deployment (weeks vs months)
- ✅ Lower TCO (SaaS vs custom)
- ✅ Continuous updates

---

## Next Immediate Steps

1. **Add SaaS fields to tenants table** (5 min)
2. **Update middleware for subdomain detection** (30 min)
3. **Modify login page for auto-tenant detection** (30 min)
4. **Test with subdomain locally** (15 min)
5. **Document deployment guide** (1 hour)

**Total Time: ~2.5 hours to enable basic SaaS functionality**

---

## Success Metrics

### Technical
- ✅ Tenant isolation: 100% (no data leakage)
- ✅ Uptime: 99.9% SLA
- ✅ Response time: <200ms (p95)
- ✅ Deployment time: <5 minutes (new tenant)

### Business
- 🎯 10 paying customers in 3 months
- 🎯 $10,000 MRR in 6 months
- 🎯 50 tenants in 12 months
- 🎯 Break-even in 18 months

---

## Conclusion

Your architecture is **perfectly positioned** for SaaS deployment:
- ✅ Multi-tenant database ready
- ✅ Tenant isolation implemented
- ✅ Authentication working
- ⏳ Need subdomain support (2-3 hours)
- ⏳ Need subscription management (1-2 weeks)

**You're 80% there!** Just need to add the SaaS-specific features.
