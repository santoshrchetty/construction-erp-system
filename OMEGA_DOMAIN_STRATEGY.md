# Omega Data Labs - Domain Strategy
## Using omegadatalabs.com for Construction ERP SaaS

---

## Current Asset

**Registered Domain:** omegadatalabs.com  
**Registrar:** (To be confirmed)  
**Status:** Active  

---

## Recommended Domain Structure

### Option 1: Subdomain Approach (Recommended)

```
Main Company Site:
https://omegadatalabs.com
- Company information
- About us, careers, contact
- Product portfolio

ERP Product Site:
https://erp.omegadatalabs.com
- Product information
- Features, pricing, demos
- Documentation

Customer Instances (SaaS):
https://abc.erp.omegadatalabs.com (ABC Construction)
https://xyz.erp.omegadatalabs.com (XYZ Builders)
https://ntt.erp.omegadatalabs.com (NTT Projects)

Development:
https://dev.erp.omegadatalabs.com
https://abc-dev.erp.omegadatalabs.com

QA/Staging:
https://qa.erp.omegadatalabs.com
https://abc-qa.erp.omegadatalabs.com

Documentation:
https://docs.erp.omegadatalabs.com

API:
https://api.erp.omegadatalabs.com
```

**Pros:**
- ✅ Uses existing domain
- ✅ Clear hierarchy
- ✅ Professional structure
- ✅ No additional domain cost

**Cons:**
- ⚠️ Longer URLs
- ⚠️ Three-level subdomains (abc.erp.omegadatalabs.com)

---

### Option 2: Separate Product Domain (Alternative)

**Register:** omegaerp.com or omegabuild.com

```
Main Company Site:
https://omegadatalabs.com
- Company information

ERP Product Site:
https://omegaerp.com
- Product site

Customer Instances:
https://abc.omegaerp.com (ABC Construction)
https://xyz.omegaerp.com (XYZ Builders)
https://ntt.omegaerp.com (NTT Projects)
```

**Pros:**
- ✅ Shorter customer URLs
- ✅ Cleaner branding
- ✅ Two-level subdomains only
- ✅ Easier to remember

**Cons:**
- ❌ Additional domain cost ($12-15/year)
- ❌ Need to register and manage

---

### Option 3: Hybrid Approach (Best of Both)

```
Company:
https://omegadatalabs.com

Product Marketing:
https://omegadatalabs.com/erp
- Product pages under main site

Customer Instances:
https://abc.omegadatalabs.com (simplified)
https://xyz.omegadatalabs.com
https://ntt.omegadatalabs.com

Development:
https://abc-dev.omegadatalabs.com
https://xyz-dev.omegadatalabs.com
```

**Pros:**
- ✅ Uses existing domain
- ✅ Shorter customer URLs (two-level)
- ✅ No additional cost
- ✅ Clean and professional

**Cons:**
- ⚠️ Customer subdomains directly under main domain
- ⚠️ Need clear naming convention

---

## Recommended: Option 3 (Hybrid)

### URL Structure

```
┌─────────────────────────────────────────────────────────────┐
│                  omegadatalabs.com                          │
│              (Main Company Website)                         │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌──────▼───────┐  ┌───────▼────────┐
│   /products    │  │     /erp     │  │   /contact     │
│   /about       │  │   /pricing   │  │   /careers     │
│   /blog        │  │     /demo    │  │   /support     │
└────────────────┘  └──────────────┘  └────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              Customer Subdomains (SaaS)                     │
└─────────────────────────────────────────────────────────────┘

abc.omegadatalabs.com → ABC Construction ERP
xyz.omegadatalabs.com → XYZ Builders ERP
ntt.omegadatalabs.com → NTT Projects ERP

┌─────────────────────────────────────────────────────────────┐
│              Development/QA Subdomains                      │
└─────────────────────────────────────────────────────────────┘

dev.omegadatalabs.com → Development environment
abc-dev.omegadatalabs.com → ABC Development
xyz-dev.omegadatalabs.com → XYZ Development

qa.omegadatalabs.com → QA environment
abc-qa.omegadatalabs.com → ABC QA
xyz-qa.omegadatalabs.com → XYZ QA

┌─────────────────────────────────────────────────────────────┐
│              Utility Subdomains                             │
└─────────────────────────────────────────────────────────────┘

docs.omegadatalabs.com → Documentation
api.omegadatalabs.com → API Documentation
status.omegadatalabs.com → System Status
support.omegadatalabs.com → Support Portal
```

---

## DNS Configuration

### Cloudflare DNS Setup (Recommended)

```
# Main website
omegadatalabs.com           A       Vercel IP
www.omegadatalabs.com       CNAME   omegadatalabs.com

# Wildcard for customer instances
*.omegadatalabs.com         CNAME   your-app.vercel.app

# Specific subdomains (optional, wildcard covers these)
abc.omegadatalabs.com       CNAME   your-app.vercel.app
xyz.omegadatalabs.com       CNAME   your-app.vercel.app
ntt.omegadatalabs.com       CNAME   your-app.vercel.app

# Development
dev.omegadatalabs.com       CNAME   dev-app.vercel.app
*.dev.omegadatalabs.com     CNAME   dev-app.vercel.app

# QA
qa.omegadatalabs.com        CNAME   qa-app.vercel.app
*.qa.omegadatalabs.com      CNAME   qa-app.vercel.app

# Utilities
docs.omegadatalabs.com      CNAME   docs-site.vercel.app
api.omegadatalabs.com       CNAME   api-docs.vercel.app
status.omegadatalabs.com    CNAME   status-page.vercel.app
```

---

## SSL Certificate

### Wildcard SSL (Required)

```
Certificate for: *.omegadatalabs.com
Covers:
- abc.omegadatalabs.com
- xyz.omegadatalabs.com
- any-customer.omegadatalabs.com

Provider Options:
1. Let's Encrypt (Free) - via Vercel
2. Cloudflare (Free) - if using Cloudflare
3. Commercial SSL ($50-200/year)

Recommendation: Use Vercel's automatic SSL
```

---

## Branding Examples

### Customer Login Pages

**ABC Construction:**
```
URL: https://abc.omegadatalabs.com/login

Page Title: ABC Construction - Omega ERP
Browser Tab: ABC Construction | Omega Data Labs

Login Page:
┌─────────────────────────────┐
│ [ABC Logo]                  │
│ ABC Construction            │
│                             │
│ Email: [____________]       │
│ Password: [____________]    │
│ [Sign In]                   │
│                             │
│ Powered by Omega Data Labs  │
└─────────────────────────────┘
```

**XYZ Builders:**
```
URL: https://xyz.omegadatalabs.com/login

Page Title: XYZ Builders - Omega ERP
Browser Tab: XYZ Builders | Omega Data Labs

Login Page:
┌─────────────────────────────┐
│ [XYZ Logo]                  │
│ XYZ Builders                │
│                             │
│ Email: [____________]       │
│ Password: [____________]    │
│ [Sign In]                   │
│                             │
│ Powered by Omega Data Labs  │
└─────────────────────────────┘
```

---

## Email Configuration

### Email Addresses

```
Company:
info@omegadatalabs.com
contact@omegadatalabs.com
careers@omegadatalabs.com

Sales & Support:
sales@omegadatalabs.com
support@omegadatalabs.com
help@omegadatalabs.com

Technical:
dev@omegadatalabs.com
api@omegadatalabs.com
security@omegadatalabs.com

No-Reply:
noreply@omegadatalabs.com
notifications@omegadatalabs.com
```

### Email Sending Domains

```
Transactional Emails (SendGrid/Mailgun):
mail.omegadatalabs.com

Marketing Emails:
marketing.omegadatalabs.com

SPF Record:
v=spf1 include:_spf.google.com include:sendgrid.net ~all

DKIM:
Setup via email provider

DMARC:
v=DMARC1; p=quarantine; rua=mailto:dmarc@omegadatalabs.com
```

---

## Marketing URLs

### Landing Pages

```
Main Product:
https://omegadatalabs.com/erp
https://omegadatalabs.com/construction-erp

Features:
https://omegadatalabs.com/erp/features
https://omegadatalabs.com/erp/modules

Pricing:
https://omegadatalabs.com/erp/pricing

Demo:
https://omegadatalabs.com/erp/demo
https://omegadatalabs.com/erp/trial

Resources:
https://omegadatalabs.com/erp/resources
https://omegadatalabs.com/erp/case-studies
https://omegadatalabs.com/erp/blog
```

---

## Custom Domain Support (Enterprise)

### For Enterprise Customers

```
Customer wants: https://erp.abc-construction.com

Setup:
1. Customer creates CNAME:
   erp.abc-construction.com → abc.omegadatalabs.com

2. We add to tenant_domains table:
   domain: erp.abc-construction.com
   tenant_id: abc-tenant-id
   domain_type: custom_domain

3. SSL certificate auto-provisioned by Vercel

4. Customer accesses their custom domain
   https://erp.abc-construction.com
   → Routes to ABC tenant
   → Shows ABC branding
```

---

## Implementation Checklist

### Phase 1: DNS Setup (1 hour)

- [ ] Login to domain registrar
- [ ] Point nameservers to Cloudflare (recommended)
- [ ] Add A record for main domain
- [ ] Add wildcard CNAME for subdomains
- [ ] Verify DNS propagation

### Phase 2: SSL Setup (30 minutes)

- [ ] Enable Cloudflare SSL (if using)
- [ ] Configure Vercel SSL
- [ ] Test wildcard certificate
- [ ] Verify HTTPS works

### Phase 3: Email Setup (1 hour)

- [ ] Setup Google Workspace or similar
- [ ] Configure MX records
- [ ] Setup SPF, DKIM, DMARC
- [ ] Test email sending/receiving

### Phase 4: Application Configuration (30 minutes)

- [ ] Update environment variables
- [ ] Configure NEXT_PUBLIC_APP_URL
- [ ] Update middleware for domain detection
- [ ] Test subdomain routing

### Phase 5: Testing (1 hour)

- [ ] Test main site: omegadatalabs.com
- [ ] Test customer subdomain: abc.omegadatalabs.com
- [ ] Test dev environment: dev.omegadatalabs.com
- [ ] Test custom domain (if applicable)
- [ ] Verify SSL on all subdomains

---

## Cost Breakdown

```
Domain Registration:
omegadatalabs.com: Already owned ✅

DNS Hosting:
Cloudflare: Free ✅

SSL Certificates:
Wildcard SSL via Vercel: Free ✅

Email:
Google Workspace: $6/user/month
(5 users = $30/month)

Total Monthly Cost: $30
Total Annual Cost: $360

Additional Domains (Optional):
omegaerp.com: $12/year
omegabuild.com: $12/year
```

---

## Comparison with Competitors

### Your Setup:
```
Company: omegadatalabs.com
Customers: abc.omegadatalabs.com
Cost: $30/month
```

### Competitors:
```
Salesforce:
Company: salesforce.com
Customers: abc.my.salesforce.com
Cost: $$$

SAP:
Company: sap.com
Customers: abc.s4hana.cloud.sap
Cost: $$$$

Procore:
Company: procore.com
Customers: app.procore.com (no subdomain)
Cost: $$$
```

**Your advantage:** Professional subdomain structure at minimal cost!

---

## Next Steps

1. **Verify DNS Access**
   - Login to domain registrar
   - Confirm you can modify DNS records

2. **Choose DNS Provider**
   - Cloudflare (Recommended - Free, Fast, Secure)
   - Current registrar DNS
   - AWS Route 53

3. **Plan Migration**
   - Current site on omegadatalabs.com?
   - Need to preserve existing content?
   - Downtime acceptable?

4. **Implement Subdomain Detection**
   - Update middleware
   - Update login page
   - Test locally first

**Timeline: 1 day for complete setup**

Ready to proceed with implementation? 🚀
