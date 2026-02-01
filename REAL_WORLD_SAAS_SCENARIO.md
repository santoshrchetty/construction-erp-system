# Real-World SaaS Scenario: 2 Customers Across Dev/QA/Prod

## Customer Profiles

### Customer 1: ABC Construction Ltd
- **Industry:** Commercial Construction
- **Size:** 50 employees
- **Projects:** 10 active projects
- **Plan:** Professional ($299/month)
- **Location:** Mumbai, India

### Customer 2: XYZ Builders Pvt Ltd
- **Industry:** Residential Construction
- **Size:** 25 employees
- **Projects:** 5 active projects
- **Plan:** Starter ($99/month)
- **Location:** Bangalore, India

---

## Environment Architecture

### Overview
```
┌─────────────────────────────────────────────────────────────┐
│                    DEVELOPMENT                              │
│  Supabase: dev-nexuserp.supabase.co                       │
│  App: dev.nexuserp.com                                     │
│                                                             │
│  ├── abc-dev.nexuserp.com → ABC Construction (Dev)        │
│  └── xyz-dev.nexuserp.com → XYZ Builders (Dev)            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       QA/STAGING                            │
│  Supabase: qa-nexuserp.supabase.co                        │
│  App: qa.nexuserp.com                                      │
│                                                             │
│  ├── abc-qa.nexuserp.com → ABC Construction (QA)          │
│  └── xyz-qa.nexuserp.com → XYZ Builders (QA)              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      PRODUCTION                             │
│  Supabase: prod-nexuserp.supabase.co                      │
│  App: nexuserp.com                                         │
│                                                             │
│  ├── abc.nexuserp.com → ABC Construction (Prod)           │
│  └── xyz.nexuserp.com → XYZ Builders (Prod)               │
└─────────────────────────────────────────────────────────────┘
```

---

## Database Setup Per Environment

### Development Database

```sql
-- DEV: Supabase Project ID: dev-nexuserp

-- Tenants Table
INSERT INTO tenants (id, tenant_code, tenant_name, subdomain, deployment_type, subscription_status) VALUES
('abc-dev-id-001', 'ABC', 'ABC Construction Ltd', 'abc-dev', 'public_saas', 'active'),
('xyz-dev-id-001', 'XYZ', 'XYZ Builders Pvt Ltd', 'xyz-dev', 'public_saas', 'active');

-- ABC Construction - Dev Users
INSERT INTO users (id, email, first_name, last_name, tenant_id, role_id, employee_code) VALUES
('abc-dev-user-001', 'admin@abc-dev.com', 'Rajesh', 'Kumar', 'abc-dev-id-001', 'abc-admin-role', 'ABC001'),
('abc-dev-user-002', 'pm@abc-dev.com', 'Priya', 'Sharma', 'abc-dev-id-001', 'abc-pm-role', 'ABC002');

-- XYZ Builders - Dev Users
INSERT INTO users (id, email, first_name, last_name, tenant_id, role_id, employee_code) VALUES
('xyz-dev-user-001', 'admin@xyz-dev.com', 'Amit', 'Patel', 'xyz-dev-id-001', 'xyz-admin-role', 'XYZ001'),
('xyz-dev-user-002', 'engineer@xyz-dev.com', 'Sneha', 'Reddy', 'xyz-dev-id-001', 'xyz-eng-role', 'XYZ002');

-- ABC Construction - Dev Projects
INSERT INTO projects (id, project_code, project_name, tenant_id, company_code, status) VALUES
('abc-dev-proj-001', 'ABC-DEV-001', 'Mumbai Office Tower (Dev)', 'abc-dev-id-001', 'ABC001', 'active'),
('abc-dev-proj-002', 'ABC-DEV-002', 'Pune Residential Complex (Dev)', 'abc-dev-id-001', 'ABC001', 'active');

-- XYZ Builders - Dev Projects
INSERT INTO projects (id, project_code, project_name, tenant_id, company_code, status) VALUES
('xyz-dev-proj-001', 'XYZ-DEV-001', 'Bangalore Villa Project (Dev)', 'xyz-dev-id-001', 'XYZ001', 'active'),
('xyz-dev-proj-002', 'XYZ-DEV-002', 'Mysore Apartments (Dev)', 'xyz-dev-id-001', 'XYZ001', 'active');
```

### QA Database

```sql
-- QA: Supabase Project ID: qa-nexuserp

-- Tenants Table (Same structure, different IDs)
INSERT INTO tenants (id, tenant_code, tenant_name, subdomain, deployment_type, subscription_status) VALUES
('abc-qa-id-001', 'ABC', 'ABC Construction Ltd', 'abc-qa', 'public_saas', 'active'),
('xyz-qa-id-001', 'XYZ', 'XYZ Builders Pvt Ltd', 'xyz-qa', 'public_saas', 'active');

-- ABC Construction - QA Users
INSERT INTO users (id, email, first_name, last_name, tenant_id, role_id, employee_code) VALUES
('abc-qa-user-001', 'admin@abc-qa.com', 'Rajesh', 'Kumar', 'abc-qa-id-001', 'abc-admin-role', 'ABC001'),
('abc-qa-user-002', 'pm@abc-qa.com', 'Priya', 'Sharma', 'abc-qa-id-001', 'abc-pm-role', 'ABC002');

-- XYZ Builders - QA Users
INSERT INTO users (id, email, first_name, last_name, tenant_id, role_id, employee_code) VALUES
('xyz-qa-user-001', 'admin@xyz-qa.com', 'Amit', 'Patel', 'xyz-qa-id-001', 'xyz-admin-role', 'XYZ001'),
('xyz-qa-user-002', 'engineer@xyz-qa.com', 'Sneha', 'Reddy', 'xyz-qa-id-001', 'xyz-eng-role', 'XYZ002');

-- Projects (Copy of production data for testing)
-- ... similar structure
```

### Production Database

```sql
-- PROD: Supabase Project ID: prod-nexuserp

-- Tenants Table (Production IDs)
INSERT INTO tenants (id, tenant_code, tenant_name, subdomain, deployment_type, subscription_status, subscription_plan) VALUES
('9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'ABC', 'ABC Construction Ltd', 'abc', 'public_saas', 'active', 'professional'),
('f8e7d6c5-b4a3-9281-7069-5e4d3c2b1a09', 'XYZ', 'XYZ Builders Pvt Ltd', 'xyz', 'public_saas', 'active', 'starter');

-- ABC Construction - Production Users
INSERT INTO users (id, email, first_name, last_name, tenant_id, role_id, employee_code) VALUES
('abc-prod-user-001', 'admin@abcconstruction.com', 'Rajesh', 'Kumar', '9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'abc-admin-role', 'ABC001'),
('abc-prod-user-002', 'pm@abcconstruction.com', 'Priya', 'Sharma', '9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'abc-pm-role', 'ABC002');

-- XYZ Builders - Production Users
INSERT INTO users (id, email, first_name, last_name, tenant_id, role_id, employee_code) VALUES
('xyz-prod-user-001', 'admin@xyzbuilders.com', 'Amit', 'Patel', 'f8e7d6c5-b4a3-9281-7069-5e4d3c2b1a09', 'xyz-admin-role', 'XYZ001'),
('xyz-prod-user-002', 'engineer@xyzbuilders.com', 'Sneha', 'Reddy', 'f8e7d6c5-b4a3-9281-7069-5e4d3c2b1a09', 'xyz-eng-role', 'XYZ002');

-- Real production projects
INSERT INTO projects (id, project_code, project_name, tenant_id, company_code, status, budget) VALUES
('abc-prod-proj-001', 'ABC-2025-001', 'Mumbai Office Tower', '9bd339ec-9877-4d9f-b3dc-3e60048c1b15', 'ABC001', 'active', 50000000),
('xyz-prod-proj-001', 'XYZ-2025-001', 'Bangalore Villa Project', 'f8e7d6c5-b4a3-9281-7069-5e4d3c2b1a09', 'XYZ001', 'active', 25000000);
```

---

## URL Structure Per Environment

### Development URLs

```
Main App: https://dev.nexuserp.com

ABC Construction:
- Login: https://abc-dev.nexuserp.com/login
- Dashboard: https://abc-dev.nexuserp.com/erp-modules
- Projects: https://abc-dev.nexuserp.com/projects

XYZ Builders:
- Login: https://xyz-dev.nexuserp.com/login
- Dashboard: https://xyz-dev.nexuserp.com/erp-modules
- Projects: https://xyz-dev.nexuserp.com/projects
```

### QA URLs

```
Main App: https://qa.nexuserp.com

ABC Construction:
- Login: https://abc-qa.nexuserp.com/login
- Dashboard: https://abc-qa.nexuserp.com/erp-modules
- Projects: https://abc-qa.nexuserp.com/projects

XYZ Builders:
- Login: https://xyz-qa.nexuserp.com/login
- Dashboard: https://xyz-qa.nexuserp.com/erp-modules
- Projects: https://xyz-qa.nexuserp.com/projects
```

### Production URLs

```
Main App: https://nexuserp.com

ABC Construction:
- Login: https://abc.nexuserp.com/login
- Dashboard: https://abc.nexuserp.com/erp-modules
- Projects: https://abc.nexuserp.com/projects

XYZ Builders:
- Login: https://xyz.nexuserp.com/login
- Dashboard: https://xyz.nexuserp.com/erp-modules
- Projects: https://xyz.nexuserp.com/projects
```

---

## User Journey: ABC Construction

### Development Environment

**Day 1: Developer Testing**
```
1. Developer visits: https://abc-dev.nexuserp.com/login

2. Login Page Shows:
   ┌─────────────────────────────────┐
   │ ABC Construction Ltd            │ ← Auto-detected from subdomain
   │ [Development Environment]       │ ← Environment badge
   │                                 │
   │ Email: admin@abc-dev.com        │
   │ Password: ********              │
   │ [Sign In]                       │
   └─────────────────────────────────┘

3. After Login:
   - Middleware detects: subdomain = "abc-dev"
   - Looks up: tenant_id = "abc-dev-id-001"
   - Sets cookie: tenant-id = "abc-dev-id-001"
   - Redirects to: /erp-modules

4. Dashboard Shows:
   - Projects: ABC-DEV-001, ABC-DEV-002
   - Users: 2 dev users
   - Materials: Dev test data
   - Environment: DEV (red badge)

5. Developer Creates Test Project:
   - Project Code: ABC-DEV-003
   - Project Name: "Test Project for Feature X"
   - Budget: ₹1,000,000 (test data)
   - Status: Active

6. All Data Isolated:
   - tenant_id = "abc-dev-id-001" on all records
   - XYZ Builders cannot see this data
   - QA/Prod cannot see this data
```

### QA Environment

**Day 5: QA Testing**
```
1. QA Tester visits: https://abc-qa.nexuserp.com/login

2. Login Page Shows:
   ┌─────────────────────────────────┐
   │ ABC Construction Ltd            │
   │ [QA Environment]                │ ← QA badge
   │                                 │
   │ Email: admin@abc-qa.com         │
   │ Password: ********              │
   │ [Sign In]                       │
   └─────────────────────────────────┘

3. After Login:
   - Middleware detects: subdomain = "abc-qa"
   - Looks up: tenant_id = "abc-qa-id-001"
   - Sets cookie: tenant-id = "abc-qa-id-001"
   - Redirects to: /erp-modules

4. Dashboard Shows:
   - Projects: Copy of production data
   - Users: QA test users
   - Materials: Production-like data
   - Environment: QA (yellow badge)

5. QA Tests New Feature:
   - Create material request
   - Approve workflow
   - Generate GRN
   - Verify GL posting
   - All isolated to QA tenant

6. QA Validates:
   ✅ Feature works correctly
   ✅ No data leakage to XYZ
   ✅ Performance acceptable
   ✅ Ready for production
```

### Production Environment

**Day 10: Production Deployment**
```
1. ABC User visits: https://abc.nexuserp.com/login

2. Login Page Shows:
   ┌─────────────────────────────────┐
   │ ABC Construction Ltd            │
   │ [ABC Logo]                      │ ← Branded
   │                                 │
   │ Email: admin@abcconstruction.com│
   │ Password: ********              │
   │ [Sign In]                       │
   └─────────────────────────────────┘

3. After Login:
   - Middleware detects: subdomain = "abc"
   - Looks up: tenant_id = "9bd339ec..."
   - Sets cookie: tenant-id = "9bd339ec..."
   - Redirects to: /erp-modules

4. Dashboard Shows:
   - Projects: 10 real projects
   - Budget: ₹500 Crores total
   - Users: 50 employees
   - Materials: 5,000+ items
   - Environment: PRODUCTION (green badge)

5. Daily Operations:
   - Create material requests
   - Approve purchase orders
   - Track project costs
   - Generate reports
   - All data isolated to ABC tenant

6. Data Isolation Verified:
   - tenant_id = "9bd339ec..." on all records
   - XYZ Builders cannot access
   - Dev/QA data separate
   - Complete isolation ✅
```

---

## User Journey: XYZ Builders

### Development Environment

```
1. Developer visits: https://xyz-dev.nexuserp.com/login

2. Login Page Shows:
   ┌─────────────────────────────────┐
   │ XYZ Builders Pvt Ltd            │
   │ [Development Environment]       │
   │                                 │
   │ Email: admin@xyz-dev.com        │
   │ Password: ********              │
   │ [Sign In]                       │
   └─────────────────────────────────┘

3. After Login:
   - Middleware detects: subdomain = "xyz-dev"
   - Looks up: tenant_id = "xyz-dev-id-001"
   - Dashboard shows XYZ projects only
   - Cannot see ABC data ✅
```

### Production Environment

```
1. XYZ User visits: https://xyz.nexuserp.com/login

2. Login Page Shows:
   ┌─────────────────────────────────┐
   │ XYZ Builders Pvt Ltd            │
   │ [XYZ Logo]                      │
   │                                 │
   │ Email: admin@xyzbuilders.com    │
   │ Password: ********              │
   │ [Sign In]                       │
   └─────────────────────────────────┘

3. After Login:
   - Middleware detects: subdomain = "xyz"
   - Looks up: tenant_id = "f8e7d6c5..."
   - Dashboard shows XYZ projects only
   - Cannot see ABC data ✅
```

---

## Data Isolation Verification

### Test Scenario 1: Cross-Tenant Access Attempt

```
ABC User tries to access XYZ subdomain:

1. ABC User logged in at: abc.nexuserp.com
   - Cookie: tenant-id = "9bd339ec..." (ABC)

2. User manually types: xyz.nexuserp.com

3. Middleware Checks:
   - Subdomain: "xyz" → tenant_id = "f8e7d6c5..." (XYZ)
   - Cookie: tenant-id = "9bd339ec..." (ABC)
   - Mismatch detected! ❌

4. Middleware Action:
   - Clear tenant cookie
   - Redirect to: xyz.nexuserp.com/login
   - Show error: "Session expired. Please login again."

5. Result:
   ✅ Cross-tenant access blocked
   ✅ User must login with XYZ credentials
   ✅ Data isolation maintained
```

### Test Scenario 2: API Request Validation

```
ABC User makes API request:

Request:
GET https://abc.nexuserp.com/api/projects
Cookie: tenant-id=9bd339ec...
Headers: x-tenant-id=9bd339ec...

Middleware:
1. Extract subdomain: "abc"
2. Lookup tenant: "9bd339ec..."
3. Validate cookie matches: ✅
4. Set header: x-tenant-id=9bd339ec...

API Route:
1. Read header: x-tenant-id=9bd339ec...
2. Query: SELECT * FROM projects WHERE tenant_id = '9bd339ec...'
3. Return: Only ABC projects

Result:
✅ Only ABC data returned
✅ XYZ data not accessible
✅ Complete isolation
```

---

## Environment Configuration

### .env.development

```env
# Development Environment
NEXT_PUBLIC_APP_URL=https://dev.nexuserp.com
NEXT_PUBLIC_SUPABASE_URL=https://dev-nexuserp.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...dev
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...dev-service

NEXT_PUBLIC_ENVIRONMENT=development
NEXT_PUBLIC_ENABLE_SUBDOMAIN=true
NEXT_PUBLIC_SUBDOMAIN_SUFFIX=-dev
```

### .env.qa

```env
# QA Environment
NEXT_PUBLIC_APP_URL=https://qa.nexuserp.com
NEXT_PUBLIC_SUPABASE_URL=https://qa-nexuserp.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...qa
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...qa-service

NEXT_PUBLIC_ENVIRONMENT=qa
NEXT_PUBLIC_ENABLE_SUBDOMAIN=true
NEXT_PUBLIC_SUBDOMAIN_SUFFIX=-qa
```

### .env.production

```env
# Production Environment
NEXT_PUBLIC_APP_URL=https://nexuserp.com
NEXT_PUBLIC_SUPABASE_URL=https://prod-nexuserp.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...prod
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...prod-service

NEXT_PUBLIC_ENVIRONMENT=production
NEXT_PUBLIC_ENABLE_SUBDOMAIN=true
NEXT_PUBLIC_SUBDOMAIN_SUFFIX=
```

---

## DNS Configuration

### Development

```
# Cloudflare DNS for dev.nexuserp.com

*.dev.nexuserp.com    CNAME    dev-nexuserp.vercel.app
abc-dev.nexuserp.com  CNAME    dev-nexuserp.vercel.app
xyz-dev.nexuserp.com  CNAME    dev-nexuserp.vercel.app
```

### QA

```
# Cloudflare DNS for qa.nexuserp.com

*.qa.nexuserp.com     CNAME    qa-nexuserp.vercel.app
abc-qa.nexuserp.com   CNAME    qa-nexuserp.vercel.app
xyz-qa.nexuserp.com   CNAME    qa-nexuserp.vercel.app
```

### Production

```
# Cloudflare DNS for nexuserp.com

*.nexuserp.com        CNAME    nexuserp.vercel.app
abc.nexuserp.com      CNAME    nexuserp.vercel.app
xyz.nexuserp.com      CNAME    nexuserp.vercel.app
```

---

## Deployment Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Developer commits code to GitHub                         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. GitHub Actions runs tests                                │
│    - Unit tests                                             │
│    - Integration tests                                      │
│    - Tenant isolation tests                                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Auto-deploy to DEV                                       │
│    - Vercel deploys to dev-nexuserp.vercel.app            │
│    - Available at: abc-dev.nexuserp.com                    │
│    - Available at: xyz-dev.nexuserp.com                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Manual promotion to QA                                   │
│    - QA team approves                                       │
│    - Vercel deploys to qa-nexuserp.vercel.app             │
│    - Available at: abc-qa.nexuserp.com                     │
│    - Available at: xyz-qa.nexuserp.com                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 5. QA Testing (2-3 days)                                    │
│    - Functional testing                                     │
│    - Performance testing                                    │
│    - Security testing                                       │
│    - Tenant isolation testing                               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 6. Manual promotion to PRODUCTION                           │
│    - Product owner approves                                 │
│    - Vercel deploys to nexuserp.vercel.app                │
│    - Available at: abc.nexuserp.com                        │
│    - Available at: xyz.nexuserp.com                        │
│    - Zero downtime deployment                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Monitoring & Alerts

### Per-Tenant Metrics

```
ABC Construction (Production):
- Active Users: 50
- API Requests/day: 10,000
- Storage Used: 5 GB / 25 GB
- Projects: 10 active
- Response Time: 150ms (p95)
- Uptime: 99.95%

XYZ Builders (Production):
- Active Users: 25
- API Requests/day: 5,000
- Storage Used: 2 GB / 10 GB
- Projects: 5 active
- Response Time: 120ms (p95)
- Uptime: 99.98%
```

### Alerts

```
⚠️ ABC Construction:
- Storage usage > 80% → Upgrade prompt
- API rate limit approaching → Throttle warning
- Response time > 500ms → Performance alert

⚠️ XYZ Builders:
- User limit reached (25/25) → Upgrade prompt
- Project limit reached (5/5) → Upgrade prompt
```

---

## Summary

### What We Achieved

✅ **Complete Isolation:**
- ABC and XYZ data completely separate
- Different tenant_ids in all tables
- Subdomain-based access control
- Cookie-based session isolation

✅ **Environment Separation:**
- Dev, QA, Prod completely isolated
- Different Supabase instances
- Different subdomains
- Different data sets

✅ **Professional SaaS:**
- Branded login per tenant
- Auto-tenant detection
- No manual tenant selection
- Industry-standard architecture

✅ **Security:**
- No cross-tenant access possible
- Middleware validates every request
- Cookie tampering detected
- Tenant enumeration prevented

### Next Steps

1. **Implement subdomain detection** (2-3 hours)
2. **Setup DNS for dev/qa/prod** (1 hour)
3. **Test with 2 tenants** (2 hours)
4. **Deploy to production** (1 hour)

**Total: 1 day to production-ready SaaS!** 🚀
