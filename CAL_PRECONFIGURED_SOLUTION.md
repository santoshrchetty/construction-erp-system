# Nexus ERP Cloud Appliance Library (CAL)
## Pre-Configured Construction ERP Solutions

Inspired by SAP CAL - Automated deployment of pre-configured ERP instances with sample data.

---

## What is SAP CAL?

**SAP Cloud Appliance Library** provides:
- ✅ Pre-configured SAP systems
- ✅ Sample data included
- ✅ Ready-to-use in minutes
- ✅ Trial/demo/training environments
- ✅ One-click deployment

**Our Version: Nexus ERP CAL**

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    NEXUS ERP CAL                            │
│                  (Cloud Appliance Library)                  │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌──────▼───────┐  ┌───────▼────────┐
│   Template 1   │  │  Template 2  │  │  Template 3    │
│   Basic ERP    │  │  Construction│  │  Enterprise    │
│   (Starter)    │  │  (Standard)  │  │  (Full Suite)  │
└────────────────┘  └──────────────┘  └────────────────┘
        │                   │                   │
        └───────────────────┼───────────────────┘
                            │
                    ┌───────▼────────┐
                    │  Provisioning  │
                    │     Engine     │
                    └───────┬────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
┌───────▼────────┐  ┌──────▼───────┐  ┌───────▼────────┐
│   Customer A   │  │  Customer B  │  │  Customer C    │
│ abc.nexuserp   │  │ xyz.nexuserp │  │ pqr.nexuserp   │
└────────────────┘  └──────────────┘  └────────────────┘
```

---

## Pre-Configured Templates

### Template 1: Basic Construction ERP (Starter)

**Use Case:** Small contractors, 5-10 users, basic features

**Includes:**
```
✅ Master Data:
   - 50 materials (cement, steel, aggregates)
   - 5 suppliers
   - 3 company codes
   - 2 plants
   - 5 storage locations

✅ Sample Projects:
   - 2 residential projects
   - 1 commercial project
   - Sample BOQ data
   - Sample cost estimates

✅ Users:
   - 1 Admin
   - 2 Project Managers
   - 2 Engineers

✅ Transactions:
   - 10 material requests
   - 5 purchase orders
   - 3 goods receipts
   - Sample GL postings

✅ Configuration:
   - Basic approval workflows
   - Standard number ranges
   - GST configuration (India)
   - Basic reports
```

**Deployment Time:** 2 minutes
**Price:** $99/month

---

### Template 2: Standard Construction ERP (Professional)

**Use Case:** Medium contractors, 25-50 users, full features

**Includes:**
```
✅ Master Data:
   - 500 materials (complete catalog)
   - 50 suppliers
   - 5 company codes
   - 10 plants
   - 25 storage locations
   - 100 equipment items

✅ Sample Projects:
   - 5 residential projects
   - 3 commercial projects
   - 2 infrastructure projects
   - Complete BOQ data
   - WBS structures
   - Resource planning

✅ Users:
   - 1 Admin
   - 5 Project Managers
   - 10 Engineers
   - 5 Procurement staff
   - 4 Finance users

✅ Transactions:
   - 100 material requests
   - 50 purchase orders
   - 30 goods receipts
   - Complete GL postings
   - Sample invoices
   - Payment documents

✅ Configuration:
   - Multi-level approval workflows
   - Custom number ranges
   - GST + TDS configuration
   - Advanced reports
   - Dashboard templates
   - Integration APIs enabled
```

**Deployment Time:** 5 minutes
**Price:** $299/month

---

### Template 3: Enterprise Construction ERP (Full Suite)

**Use Case:** Large contractors, 100+ users, all modules

**Includes:**
```
✅ Master Data:
   - 2,000+ materials
   - 200 suppliers
   - 10 company codes
   - 25 plants
   - 100 storage locations
   - 500 equipment items
   - 1,000 employees

✅ Sample Projects:
   - 20 projects across all types
   - Complete project lifecycle data
   - Multi-year projects
   - Complex WBS structures
   - Resource allocation
   - Subcontractor management

✅ Users:
   - Complete org hierarchy
   - 50+ users with roles
   - Department-wise access
   - Regional offices

✅ Transactions:
   - 1,000+ transactions
   - Complete audit trail
   - Multi-currency
   - Inter-company transactions

✅ Configuration:
   - Enterprise workflows
   - Custom fields
   - Advanced GST scenarios
   - Custom reports
   - BI dashboards
   - API integrations
   - Mobile app access
```

**Deployment Time:** 10 minutes
**Price:** $499/month

---

## Implementation: Provisioning Engine

### Database Structure

```sql
-- Template definitions
CREATE TABLE erp_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_code VARCHAR(50) UNIQUE NOT NULL,
  template_name VARCHAR(200) NOT NULL,
  description TEXT,
  tier VARCHAR(20) NOT NULL, -- 'starter', 'professional', 'enterprise'
  monthly_price DECIMAL(10,2),
  max_users INTEGER,
  max_projects INTEGER,
  max_storage_gb INTEGER,
  features JSONB,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Template data snapshots
CREATE TABLE template_snapshots (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id UUID REFERENCES erp_templates(id),
  snapshot_type VARCHAR(50) NOT NULL, -- 'master_data', 'transactions', 'users', 'config'
  data_sql TEXT NOT NULL, -- SQL to insert data
  execution_order INTEGER,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Provisioning jobs
CREATE TABLE provisioning_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES tenants(id),
  template_id UUID REFERENCES erp_templates(id),
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'running', 'completed', 'failed'
  progress_percentage INTEGER DEFAULT 0,
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  error_message TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Sample Template Data

```sql
-- Insert templates
INSERT INTO erp_templates (template_code, template_name, tier, monthly_price, max_users, max_projects) VALUES
('BASIC_CONST', 'Basic Construction ERP', 'starter', 99.00, 10, 10),
('STD_CONST', 'Standard Construction ERP', 'professional', 299.00, 50, 50),
('ENT_CONST', 'Enterprise Construction ERP', 'enterprise', 499.00, 200, 999);

-- Insert template snapshots (master data)
INSERT INTO template_snapshots (template_id, snapshot_type, data_sql, execution_order) VALUES
(
  (SELECT id FROM erp_templates WHERE template_code = 'BASIC_CONST'),
  'master_data',
  $$
    -- Materials
    INSERT INTO materials (tenant_id, material_code, material_name, base_uom, material_group) VALUES
    ('{TENANT_ID}', 'MAT-001', 'Cement OPC 53 Grade', 'BAG', 'CEMENT'),
    ('{TENANT_ID}', 'MAT-002', 'TMT Steel 8mm', 'TON', 'STEEL'),
    ('{TENANT_ID}', 'MAT-003', 'River Sand', 'CUM', 'AGGREGATE');
    
    -- Suppliers
    INSERT INTO suppliers (tenant_id, supplier_code, supplier_name) VALUES
    ('{TENANT_ID}', 'SUP-001', 'ABC Cement Ltd'),
    ('{TENANT_ID}', 'SUP-002', 'XYZ Steel Corp');
  $$,
  1
);
```

---

## Provisioning API

### Endpoint: Create New Instance

```typescript
// app/api/cal/provision/route.ts

import { NextRequest, NextResponse } from 'next/server'
import { createServiceClient } from '@/lib/supabase/server'

export async function POST(request: NextRequest) {
  try {
    const { 
      companyName, 
      subdomain, 
      templateCode, 
      adminEmail, 
      adminName 
    } = await request.json()
    
    // Validate subdomain availability
    const supabase = await createServiceClient()
    const { data: existing } = await supabase
      .from('tenants')
      .select('id')
      .eq('subdomain', subdomain)
      .single()
    
    if (existing) {
      return NextResponse.json(
        { error: 'Subdomain already taken' },
        { status: 400 }
      )
    }
    
    // Get template
    const { data: template } = await supabase
      .from('erp_templates')
      .select('*')
      .eq('template_code', templateCode)
      .single()
    
    if (!template) {
      return NextResponse.json(
        { error: 'Template not found' },
        { status: 404 }
      )
    }
    
    // Create tenant
    const { data: tenant, error: tenantError } = await supabase
      .from('tenants')
      .insert({
        tenant_code: subdomain.toUpperCase(),
        tenant_name: companyName,
        subdomain: subdomain,
        deployment_type: 'public_saas',
        subscription_status: 'trial',
        subscription_plan: template.tier
      })
      .select()
      .single()
    
    if (tenantError) throw tenantError
    
    // Create provisioning job
    const { data: job } = await supabase
      .from('provisioning_jobs')
      .insert({
        tenant_id: tenant.id,
        template_id: template.id,
        status: 'pending'
      })
      .select()
      .single()
    
    // Trigger async provisioning
    await triggerProvisioning(job.id)
    
    return NextResponse.json({
      success: true,
      tenant_id: tenant.id,
      subdomain: subdomain,
      job_id: job.id,
      url: `https://${subdomain}.nexuserp.com`,
      estimated_time: '2-5 minutes'
    })
    
  } catch (error) {
    console.error('Provisioning error:', error)
    return NextResponse.json(
      { error: 'Provisioning failed' },
      { status: 500 }
    )
  }
}

async function triggerProvisioning(jobId: string) {
  // Queue background job
  await fetch('/api/cal/provision/execute', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ jobId })
  })
}
```

### Endpoint: Execute Provisioning

```typescript
// app/api/cal/provision/execute/route.ts

export async function POST(request: NextRequest) {
  const { jobId } = await request.json()
  const supabase = await createServiceClient()
  
  try {
    // Update job status
    await supabase
      .from('provisioning_jobs')
      .update({ status: 'running', started_at: new Date().toISOString() })
      .eq('id', jobId)
    
    // Get job details
    const { data: job } = await supabase
      .from('provisioning_jobs')
      .select('*, tenants(*), erp_templates(*)')
      .eq('id', jobId)
      .single()
    
    // Get template snapshots
    const { data: snapshots } = await supabase
      .from('template_snapshots')
      .select('*')
      .eq('template_id', job.template_id)
      .order('execution_order')
    
    // Execute each snapshot
    for (const snapshot of snapshots) {
      const sql = snapshot.data_sql.replace(/{TENANT_ID}/g, job.tenant_id)
      
      // Execute SQL
      await supabase.rpc('execute_sql', { sql_query: sql })
      
      // Update progress
      const progress = Math.round((snapshots.indexOf(snapshot) + 1) / snapshots.length * 100)
      await supabase
        .from('provisioning_jobs')
        .update({ progress_percentage: progress })
        .eq('id', jobId)
    }
    
    // Create admin user in Supabase Auth
    // ... (create user logic)
    
    // Mark as completed
    await supabase
      .from('provisioning_jobs')
      .update({ 
        status: 'completed', 
        completed_at: new Date().toISOString(),
        progress_percentage: 100
      })
      .eq('id', jobId)
    
    // Send welcome email
    await sendWelcomeEmail(job)
    
    return NextResponse.json({ success: true })
    
  } catch (error) {
    // Mark as failed
    await supabase
      .from('provisioning_jobs')
      .update({ 
        status: 'failed', 
        error_message: error.message 
      })
      .eq('id', jobId)
    
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
}
```

---

## Self-Service Portal

### Landing Page: nexuserp.com/cal

```tsx
// app/cal/page.tsx

export default function CALPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4">
          <h1 className="text-3xl font-bold">Nexus ERP Cloud Appliance Library</h1>
          <p className="text-gray-600">Pre-configured Construction ERP - Ready in minutes</p>
        </div>
      </header>
      
      <main className="max-w-7xl mx-auto py-12 px-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          
          {/* Template 1 */}
          <TemplateCard
            name="Basic Construction ERP"
            price="$99/month"
            features={[
              '10 users',
              '10 projects',
              '50 materials',
              'Basic workflows',
              '5 GB storage'
            ]}
            templateCode="BASIC_CONST"
          />
          
          {/* Template 2 */}
          <TemplateCard
            name="Standard Construction ERP"
            price="$299/month"
            features={[
              '50 users',
              '50 projects',
              '500 materials',
              'Advanced workflows',
              '25 GB storage',
              'API access'
            ]}
            templateCode="STD_CONST"
            popular={true}
          />
          
          {/* Template 3 */}
          <TemplateCard
            name="Enterprise Construction ERP"
            price="$499/month"
            features={[
              '200 users',
              'Unlimited projects',
              '2000+ materials',
              'Custom workflows',
              '100 GB storage',
              'Full API access',
              'Priority support'
            ]}
            templateCode="ENT_CONST"
          />
          
        </div>
      </main>
    </div>
  )
}
```

### Provisioning Form

```tsx
// components/ProvisioningForm.tsx

export function ProvisioningForm({ templateCode }: { templateCode: string }) {
  const [loading, setLoading] = useState(false)
  const [result, setResult] = useState(null)
  
  const handleSubmit = async (e) => {
    e.preventDefault()
    setLoading(true)
    
    const response = await fetch('/api/cal/provision', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        companyName: e.target.companyName.value,
        subdomain: e.target.subdomain.value,
        templateCode: templateCode,
        adminEmail: e.target.adminEmail.value,
        adminName: e.target.adminName.value
      })
    })
    
    const data = await response.json()
    setResult(data)
    setLoading(false)
  }
  
  if (result?.success) {
    return (
      <div className="text-center">
        <h2 className="text-2xl font-bold text-green-600 mb-4">
          🎉 Your ERP is being provisioned!
        </h2>
        <p className="mb-4">Estimated time: {result.estimated_time}</p>
        <p className="mb-4">Your URL: <a href={result.url} className="text-blue-600">{result.url}</a></p>
        <ProvisioningProgress jobId={result.job_id} />
      </div>
    )
  }
  
  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <input name="companyName" placeholder="Company Name" required />
      <input name="subdomain" placeholder="Subdomain (e.g., abc)" required />
      <input name="adminEmail" type="email" placeholder="Admin Email" required />
      <input name="adminName" placeholder="Admin Name" required />
      <button type="submit" disabled={loading}>
        {loading ? 'Provisioning...' : 'Deploy Now'}
      </button>
    </form>
  )
}
```

---

## Comparison: SAP CAL vs Nexus ERP CAL

| Feature | SAP CAL | Nexus ERP CAL |
|---------|---------|---------------|
| **Deployment Time** | 30-60 minutes | 2-5 minutes |
| **Cost** | $500-$2,000/month | $99-$499/month |
| **Pre-configured Data** | Yes | Yes |
| **Sample Transactions** | Yes | Yes |
| **One-Click Deploy** | Yes | Yes |
| **Trial Period** | 30 days | 14 days |
| **Customization** | Limited | Full access |
| **Source Code** | No | Yes (Enterprise) |

---

## Benefits

### For Customers
✅ **Instant Access:** ERP ready in 2-5 minutes
✅ **Pre-loaded Data:** Start working immediately
✅ **No Setup:** Everything configured
✅ **Try Before Buy:** 14-day trial
✅ **Learn Fast:** Sample data to explore

### For You (Platform Owner)
✅ **Automated Onboarding:** No manual setup
✅ **Scalable:** Handle 100+ signups/day
✅ **Consistent:** Same quality every time
✅ **Upsell Ready:** Easy to upgrade tiers
✅ **Demo Ready:** Perfect for sales demos

---

## Implementation Timeline

**Week 1:** Database schema + templates
**Week 2:** Provisioning engine
**Week 3:** Self-service portal
**Week 4:** Testing + launch

**Total: 1 month to CAL-like solution!**

This gives you SAP CAL-like capabilities at a fraction of the cost and complexity! 🚀
