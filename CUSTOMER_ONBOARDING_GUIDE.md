# Customer Onboarding Guide - Omega Data Labs Construction ERP

## Overview
This document explains how new customers are set up in the Omega Data Labs Construction ERP system, from initial signup to production access.

---

## 🎯 Customer Setup Process

### **Phase 1: Sales & Provisioning (Day 1)**

#### Step 1: Customer Signs Up
- Customer visits **omegadatalabs.com**
- Fills signup form:
  - Company Name: "ABC Construction Ltd"
  - Contact Person: "Rajesh Kumar"
  - Email: rajesh@abcconstruction.com
  - Phone: +91-9876543210
  - Plan: Professional (₹24K/month)

#### Step 2: Automated Provisioning (2-5 minutes)
System automatically:

1. **Creates Tenant Record**
   ```sql
   INSERT INTO tenants (
     tenant_code,
     tenant_name,
     subdomain,
     plan_type,
     is_active
   ) VALUES (
     'ABC001',
     'ABC Construction Ltd',
     'abc',
     'professional',
     true
   );
   ```

2. **Generates Subdomain**
   - Subdomain: `abc.omegadatalabs.com`
   - DNS: Automatically configured via wildcard (*.omegadatalabs.com)
   - SSL: Auto-provisioned by Vercel

3. **Creates Admin User**
   ```sql
   INSERT INTO users (
     email,
     tenant_id,
     role,
     is_active
   ) VALUES (
     'rajesh@abcconstruction.com',
     '<tenant_id>',
     'admin',
     true
   );
   ```

4. **Sends Welcome Email**
   - Subject: "Welcome to Omega Data Labs Construction ERP"
   - Contains:
     - Login URL: https://abc.omegadatalabs.com
     - Temporary password
     - Setup instructions
     - Support contact

---

### **Phase 2: Initial Configuration (Day 1-2)**

#### Step 3: Admin First Login
Customer admin logs in at `abc.omegadatalabs.com`:

1. **Auto-detected Tenant**
   - Middleware extracts subdomain: "abc"
   - Looks up tenant in database
   - No dropdown needed (unlike current login page)

2. **Forced Password Change**
   - Must change temporary password
   - Set up 2FA (optional)

3. **Company Profile Setup**
   ```sql
   INSERT INTO companies (
     tenant_id,
     company_code,
     company_name,
     gstin,
     pan,
     address
   ) VALUES (
     '<tenant_id>',
     'ABC',
     'ABC Construction Ltd',
     '29ABCDE1234F1Z5',
     'ABCDE1234F',
     'Mumbai, Maharashtra'
   );
   ```

#### Step 4: Template-Based Setup (CAL)
Admin selects preconfigured template:

**Professional Template Includes:**
- ✅ 50 user licenses
- ✅ 500 material master records
- ✅ 20 equipment types
- ✅ 10 vendor records
- ✅ 5 project templates
- ✅ Standard workflows
- ✅ GST/TDS configurations
- ✅ Report templates

System automatically creates:
```sql
-- Materials
INSERT INTO materials (tenant_id, company_code, material_code, ...)
SELECT '<tenant_id>', 'ABC', material_code, ...
FROM template_materials
WHERE template_id = 'professional';

-- Equipment
INSERT INTO equipment_types (tenant_id, company_code, ...)
SELECT '<tenant_id>', 'ABC', ...
FROM template_equipment
WHERE template_id = 'professional';

-- Workflows
INSERT INTO workflows (tenant_id, ...)
SELECT '<tenant_id>', ...
FROM template_workflows
WHERE template_id = 'professional';
```

---

### **Phase 3: User & Data Setup (Day 2-7)**

#### Step 5: Add Users
Admin invites team members:

1. **Bulk User Import**
   - Upload CSV with user details
   - System sends invitation emails
   - Each user gets role assignment

2. **User Creation**
   ```sql
   INSERT INTO users (
     email,
     tenant_id,
     role,
     department,
     is_active
   ) VALUES
     ('pm1@abcconstruction.com', '<tenant_id>', 'project_manager', 'Projects', true),
     ('acc1@abcconstruction.com', '<tenant_id>', 'accountant', 'Finance', true),
     ('eng1@abcconstruction.com', '<tenant_id>', 'engineer', 'Engineering', true);
   ```

3. **Role-Based Access**
   - Project Manager: Full project access
   - Accountant: Finance module only
   - Engineer: Technical modules

#### Step 6: Master Data Import
Customer imports existing data:

1. **Materials**
   - Upload Excel: 500 materials
   - System validates & imports
   - Auto-assigns material codes

2. **Vendors**
   - Import vendor list
   - GST validation
   - Bank details

3. **Equipment**
   - Equipment inventory
   - Maintenance schedules
   - Depreciation setup

4. **Projects**
   - Ongoing projects
   - Budget allocations
   - Timeline setup

---

### **Phase 4: Training & Go-Live (Week 2)**

#### Step 7: Training Sessions
Omega Data Labs provides:

- **Admin Training** (2 hours)
  - System configuration
  - User management
  - Report generation

- **User Training** (4 hours)
  - Module-specific training
  - Daily operations
  - Best practices

- **Support Setup**
  - Dedicated support channel
  - Documentation access
  - Video tutorials

#### Step 8: Go-Live
- Parallel run with old system (1 week)
- Data validation
- Issue resolution
- Full cutover

---

## 🔧 Technical Implementation

### Current Setup (Manual - Needs Automation)

**Database Operations:**
```sql
-- 1. Create Tenant
INSERT INTO tenants (tenant_code, tenant_name, subdomain, plan_type, is_active)
VALUES ('ABC001', 'ABC Construction Ltd', 'abc', 'professional', true)
RETURNING id;

-- 2. Create Admin User (via Supabase Auth)
-- Done through Supabase Admin API

-- 3. Link User to Tenant
INSERT INTO users (id, email, tenant_id, role, is_active)
VALUES ('<auth_user_id>', 'rajesh@abcconstruction.com', '<tenant_id>', 'admin', true);

-- 4. Create Default Company
INSERT INTO companies (tenant_id, company_code, company_name, is_active)
VALUES ('<tenant_id>', 'ABC', 'ABC Construction Ltd', true);

-- 5. Apply Template Data
-- Copy from template tables to tenant-specific records
```

### Future Setup (Automated - To Be Built)

**API Endpoint: `/api/admin/provision-customer`**

```typescript
// POST /api/admin/provision-customer
{
  "companyName": "ABC Construction Ltd",
  "contactEmail": "rajesh@abcconstruction.com",
  "contactName": "Rajesh Kumar",
  "phone": "+91-9876543210",
  "plan": "professional",
  "subdomain": "abc"  // Optional, auto-generated if not provided
}

// Response (2-5 minutes later)
{
  "success": true,
  "tenantId": "uuid",
  "tenantCode": "ABC001",
  "subdomain": "abc",
  "loginUrl": "https://abc.omegadatalabs.com",
  "adminEmail": "rajesh@abcconstruction.com",
  "temporaryPassword": "TempPass123!",
  "status": "provisioned"
}
```

---

## 📊 Customer Lifecycle

### 1. **Trial Customer** (14 days free)
- Limited to 5 users
- 1 project
- Basic features only
- No credit card required

### 2. **Paid Customer** (Active subscription)
- Full feature access
- Based on plan limits
- Monthly/Annual billing
- Priority support

### 3. **Suspended Customer** (Payment failed)
- Read-only access
- 7-day grace period
- Data retained for 30 days
- Reactivation available

### 4. **Churned Customer** (Cancelled)
- Data export provided
- 90-day data retention
- Exit survey
- Win-back campaigns

---

## 🎨 Multi-Customer Scenarios

### Scenario 1: Three Customers on SaaS

| Customer | Subdomain | Tenant Code | Users | Plan |
|----------|-----------|-------------|-------|------|
| ABC Construction | abc.omegadatalabs.com | ABC001 | 50 | Professional |
| XYZ Builders | xyz.omegadatalabs.com | XYZ001 | 200 | Enterprise |
| NTT Infrastructure | ntt.omegadatalabs.com | NTT001 | 25 | Basic |

**Data Isolation:**
```sql
-- ABC Construction can only see their data
SELECT * FROM projects WHERE tenant_id = 'abc-tenant-uuid';

-- XYZ Builders can only see their data
SELECT * FROM projects WHERE tenant_id = 'xyz-tenant-uuid';

-- Complete isolation at database level
```

### Scenario 2: Enterprise Customer (Private Cloud)

**Customer:** Larsen & Toubro (L&T)
**Deployment:** Dedicated infrastructure
**URL:** erp.lnt.com (custom domain)
**Setup:**
- Dedicated Vercel project
- Dedicated Supabase instance
- Custom branding
- SSO integration (Azure AD)
- 1000+ users
- Multiple companies (L&T Construction, L&T Infra, L&T Power)

---

## 🚀 Automation Roadmap

### Phase 1: Manual Setup (Current - 1-2 days)
- ❌ Admin manually creates tenant in database
- ❌ Admin manually creates user in Supabase
- ❌ Admin manually sends credentials
- ❌ Customer manually configures everything

### Phase 2: Semi-Automated (Next 2 months)
- ✅ Admin portal to create tenants
- ✅ Automated user creation
- ✅ Automated welcome emails
- ✅ Template-based setup
- ⏱️ Setup time: 30 minutes

### Phase 3: Fully Automated (6 months)
- ✅ Self-service signup
- ✅ Instant provisioning (2-5 minutes)
- ✅ Automated subdomain creation
- ✅ Automated billing integration
- ✅ Automated onboarding emails
- ⏱️ Setup time: 2-5 minutes

---

## 📋 Checklist: Setting Up New Customer

### Pre-Sales
- [ ] Customer fills signup form
- [ ] Sales team reviews & approves
- [ ] Payment/PO received
- [ ] Plan & pricing confirmed

### Provisioning
- [ ] Create tenant record
- [ ] Generate tenant code (ABC001)
- [ ] Assign subdomain (abc)
- [ ] Create admin user
- [ ] Send welcome email with credentials

### Configuration
- [ ] Customer logs in & changes password
- [ ] Company profile completed
- [ ] Template applied (Basic/Professional/Enterprise)
- [ ] Master data imported
- [ ] Users added & invited

### Training & Go-Live
- [ ] Admin training completed
- [ ] User training completed
- [ ] Parallel run completed
- [ ] Data validated
- [ ] Go-live approved
- [ ] Support handoff completed

### Post Go-Live
- [ ] 1-week check-in
- [ ] 1-month review
- [ ] Feedback collected
- [ ] Success metrics tracked

---

## 🔐 Security & Compliance

### Data Isolation
- Each tenant has unique UUID
- All queries filtered by tenant_id
- Row-level security (RLS) in Supabase
- No cross-tenant data access

### Access Control
- Role-based access control (RBAC)
- Tenant-level permissions
- Company-level permissions
- Module-level permissions

### Audit Trail
- All customer setup activities logged
- User creation tracked
- Configuration changes recorded
- Compliance reports available

---

## 💰 Pricing & Plans

| Plan | Price | Users | Projects | Storage | Support |
|------|-------|-------|----------|---------|---------|
| **Basic** | ₹8,000/mo | 10 | 5 | 10 GB | Email |
| **Professional** | ₹24,000/mo | 50 | 20 | 50 GB | Email + Chat |
| **Enterprise** | ₹40,000/mo | 200 | Unlimited | 200 GB | 24/7 Phone |
| **Private Cloud** | ₹80,000/mo | Unlimited | Unlimited | Custom | Dedicated |
| **On-Premise** | ₹8,00,000 | Unlimited | Unlimited | Unlimited | Premium |

---

## 📞 Support During Setup

### Omega Data Labs Support
- **Email:** support@omegadatalabs.com
- **Phone:** +91-80-1234-5678
- **Chat:** Available on omegadatalabs.com
- **Hours:** Mon-Fri 9 AM - 6 PM IST

### Onboarding Team
- Dedicated onboarding specialist
- Weekly check-in calls
- Custom training sessions
- Data migration assistance

---

## 🎯 Success Metrics

### Customer Onboarding KPIs
- **Time to First Login:** < 5 minutes
- **Time to Go-Live:** < 14 days
- **User Adoption Rate:** > 80% in 30 days
- **Customer Satisfaction:** > 4.5/5
- **Support Tickets:** < 5 per customer in first month

---

## Next Steps

1. **Build Admin Portal** - For manual customer provisioning
2. **Create Templates** - Basic, Professional, Enterprise
3. **Automate Provisioning** - Self-service signup
4. **Integrate Billing** - Razorpay/Stripe
5. **Build Onboarding Flow** - Guided setup wizard

---

**Document Version:** 1.0  
**Last Updated:** January 2025  
**Owner:** Omega Data Labs Product Team
