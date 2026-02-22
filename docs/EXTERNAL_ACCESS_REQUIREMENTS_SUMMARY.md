# EXTERNAL ACCESS MODULE - REQUIREMENTS SUMMARY

## **Objective**
Provide limited, secure access to external organizations (customers, vendors, contractors) for specific modules like:
- Drawing confirmation/approval
- Vendor progress updates
- Field service management
- Workflow participation

Similar to ADP's external portal model with multi-tenant isolation.

---

## **1. NEW TABLES TO CREATE**

### **1.1 organizations**
**Purpose:** Master table for all organizations (internal and external)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| organization_id | UUID | PK, DEFAULT gen_random_uuid() | Primary key |
| tenant_id | UUID | NOT NULL, FK → tenants(tenant_id) | Tenant isolation |
| org_code | VARCHAR(20) | NOT NULL | Short code (e.g., 'ACME') |
| org_name | VARCHAR(100) | NOT NULL | Full organization name |
| is_internal | BOOLEAN | DEFAULT true | Internal vs external org |
| is_active | BOOLEAN | DEFAULT true | Active status |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() | Last update timestamp |

**Unique Constraints:** (tenant_id, org_code)  
**Indexes:** tenant_id  
**RLS:** Enabled with tenant isolation  
**Triggers:** update_updated_at_column()

---

### **1.2 organization_relationships**
**Purpose:** Define customer/vendor relationships between organizations (supply chain graph)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| relationship_id | UUID | PK, DEFAULT gen_random_uuid() | Primary key |
| tenant_id | UUID | NOT NULL, FK → tenants(tenant_id) | Tenant isolation |
| source_org_id | UUID | NOT NULL, FK → organizations(organization_id) | Source organization |
| target_org_id | UUID | NOT NULL, FK → organizations(organization_id) | Target organization |
| relationship_type | VARCHAR(20) | NOT NULL, CHECK | CUSTOMER, VENDOR, PARTNER |
| is_active | BOOLEAN | DEFAULT true | Active status |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |

**Unique Constraints:** (tenant_id, source_org_id, target_org_id, relationship_type)  
**Check Constraints:** 
- source_org_id != target_org_id
- relationship_type IN ('CUSTOMER', 'VENDOR', 'PARTNER')

**Indexes:** source_org_id, target_org_id  
**RLS:** Enabled with tenant isolation

---

### **1.3 organization_metadata**
**Purpose:** Extended organization information (contact details, type)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| metadata_id | UUID | PK, DEFAULT gen_random_uuid() | Primary key |
| organization_id | UUID | NOT NULL, FK → organizations(organization_id), UNIQUE | Organization reference |
| tenant_id | UUID | NOT NULL, FK → tenants(tenant_id) | Tenant isolation |
| organization_type | VARCHAR(20) | CHECK | CUSTOMER, VENDOR, CONTRACTOR, CONSULTANT |
| primary_contact_name | VARCHAR(255) | NULL | Contact person name |
| primary_contact_email | VARCHAR(255) | NULL | Contact email |
| primary_contact_phone | VARCHAR(50) | NULL | Contact phone |
| address | TEXT | NULL | Organization address |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() | Last update timestamp |

**Check Constraints:** organization_type IN ('CUSTOMER', 'VENDOR', 'CONTRACTOR', 'CONSULTANT')  
**Indexes:** organization_id, tenant_id, organization_type  
**RLS:** Enabled with tenant isolation  
**Triggers:** update_updated_at_column()

---

### **1.4 organization_users**
**Purpose:** Link users to organizations (many-to-many relationship)

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| org_user_id | UUID | PK, DEFAULT gen_random_uuid() | Primary key |
| tenant_id | UUID | NOT NULL, FK → tenants(tenant_id) | Tenant isolation |
| organization_id | UUID | NOT NULL, FK → organizations(organization_id) | Organization reference |
| user_id | UUID | NOT NULL, FK → users(user_id) | User reference |
| position_title | VARCHAR(255) | NULL | User's position in org |
| is_primary_contact | BOOLEAN | DEFAULT false | Primary contact flag |
| is_active | BOOLEAN | DEFAULT true | Active status |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() | Last update timestamp |

**Unique Constraints:** (organization_id, user_id)  
**Indexes:** organization_id, user_id, tenant_id  
**RLS:** Enabled with tenant isolation  
**Triggers:** update_updated_at_column()

---

### **1.5 project_organization_access**
**Purpose:** Project-level access control with tiered permissions

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| access_id | UUID | PK, DEFAULT gen_random_uuid() | Primary key |
| tenant_id | UUID | NOT NULL, FK → tenants(tenant_id) | Tenant isolation |
| project_id | UUID | NOT NULL, FK → projects(project_id) | Project reference |
| organization_id | UUID | NOT NULL, FK → organizations(organization_id) | Organization reference |
| access_granted_by_org_id | UUID | NULL, FK → organizations(organization_id) | Who granted access (NULL = tenant) |
| role_in_project | VARCHAR(20) | NOT NULL, CHECK | CUSTOMER, VENDOR, CONTRACTOR, CONSULTANT |
| tier_level | INT | DEFAULT 1, CHECK | Access tier (1=direct, 2=sub, 3=sub-sub) |
| allowed_modules | TEXT[] | NULL | Array of allowed modules |
| access_level | VARCHAR(20) | DEFAULT 'READ', CHECK | READ, WRITE, COMMENT |
| can_invite_subcontractors | BOOLEAN | DEFAULT false | Can invite tier+1 orgs |
| access_start_date | DATE | NOT NULL | Access start date |
| access_end_date | DATE | NULL | Access end date (NULL = no expiry) |
| is_active | BOOLEAN | DEFAULT true | Active status |
| created_by | UUID | NULL, FK → users(user_id) | Creator user |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() | Last update timestamp |

**Unique Constraints:** (project_id, organization_id)  
**Check Constraints:**
- role_in_project IN ('CUSTOMER', 'VENDOR', 'CONTRACTOR', 'CONSULTANT')
- access_level IN ('READ', 'WRITE', 'COMMENT')
- tier_level >= 1 AND tier_level <= 5

**Indexes:** project_id, organization_id, access_granted_by_org_id, tenant_id, (is_active, access_end_date)  
**RLS:** Enabled with tenant isolation

---

### **1.6 drawing_customer_approvals**
**Purpose:** Track customer approvals/rejections of drawings

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| approval_id | UUID | PK, DEFAULT gen_random_uuid() | Primary key |
| tenant_id | UUID | NOT NULL, FK → tenants(tenant_id) | Tenant isolation |
| drawing_id | UUID | NOT NULL, FK → drawings(id) | Drawing reference |
| organization_id | UUID | NOT NULL, FK → organizations(organization_id) | Customer organization |
| customer_user_id | UUID | NOT NULL, FK → users(user_id) | User who approved/rejected |
| approval_status | VARCHAR(20) | DEFAULT 'PENDING', CHECK | Approval status |
| comments | TEXT | NULL | Approval comments |
| attachments | JSONB | NULL | File attachments metadata |
| approved_at | TIMESTAMPTZ | NULL | Approval timestamp |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() | Last update timestamp |

**Check Constraints:** approval_status IN ('PENDING', 'APPROVED', 'REJECTED', 'CLARIFICATION_NEEDED')  
**Indexes:** drawing_id, organization_id, approval_status, tenant_id  
**RLS:** Enabled with tenant isolation

---

### **1.7 vendor_progress_updates**
**Purpose:** Vendor progress tracking and reporting

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| update_id | UUID | PK, DEFAULT gen_random_uuid() | Primary key |
| tenant_id | UUID | NOT NULL, FK → tenants(tenant_id) | Tenant isolation |
| project_id | UUID | NOT NULL, FK → projects(project_id) | Project reference |
| organization_id | UUID | NOT NULL, FK → organizations(organization_id) | Vendor organization |
| vendor_user_id | UUID | NOT NULL, FK → users(user_id) | User who submitted update |
| work_package_id | UUID | NULL | Work package reference (future) |
| progress_percentage | DECIMAL(5,2) | CHECK | Progress % (0-100) |
| status | VARCHAR(50) | CHECK | ON_TRACK, DELAYED, AT_RISK, COMPLETED |
| update_description | TEXT | NOT NULL | Progress description |
| attachments | JSONB | NULL | File attachments metadata |
| reported_date | DATE | NOT NULL | Report date |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() | Last update timestamp |

**Check Constraints:**
- progress_percentage >= 0 AND progress_percentage <= 100
- status IN ('ON_TRACK', 'DELAYED', 'AT_RISK', 'COMPLETED')

**Indexes:** project_id, organization_id, reported_date DESC, tenant_id  
**RLS:** Enabled with tenant isolation

---

### **1.8 field_service_tickets**
**Purpose:** Contractor field service management

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ticket_id | UUID | PK, DEFAULT gen_random_uuid() | Primary key |
| tenant_id | UUID | NOT NULL, FK → tenants(tenant_id) | Tenant isolation |
| project_id | UUID | NOT NULL, FK → projects(project_id) | Project reference |
| ticket_number | VARCHAR(50) | NOT NULL | Unique ticket number |
| assigned_organization_id | UUID | NULL, FK → organizations(organization_id) | Assigned contractor org |
| assigned_contractor_id | UUID | NULL, FK → users(user_id) | Assigned contractor user |
| service_type | VARCHAR(50) | CHECK | Service type |
| priority | VARCHAR(20) | CHECK | LOW, MEDIUM, HIGH, CRITICAL |
| status | VARCHAR(20) | DEFAULT 'OPEN', CHECK | Ticket status |
| title | VARCHAR(255) | NOT NULL | Ticket title |
| description | TEXT | NOT NULL | Ticket description |
| location | VARCHAR(255) | NULL | Service location |
| scheduled_date | DATE | NULL | Scheduled date |
| completed_date | DATE | NULL | Completion date |
| created_by | UUID | NULL, FK → users(user_id) | Creator user |
| created_at | TIMESTAMPTZ | DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMPTZ | DEFAULT NOW() | Last update timestamp |

**Unique Constraints:** (tenant_id, ticket_number)  
**Check Constraints:**
- service_type IN ('INSPECTION', 'MAINTENANCE', 'INSTALLATION', 'REPAIR')
- priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')
- status IN ('OPEN', 'IN_PROGRESS', 'COMPLETED', 'CLOSED', 'CANCELLED')

**Indexes:** project_id, assigned_organization_id, status, priority, tenant_id  
**RLS:** Enabled with tenant isolation

---

### **1.9 external_workflow_notifications**
**Purpose:** Track workflow notifications sent to external users

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| notification_id | UUID | PK, DEFAULT gen_random_uuid() | Primary key |
| tenant_id | UUID | NOT NULL, FK → tenants(tenant_id) | Tenant isolation |
| step_instance_id | UUID | NOT NULL, FK → step_instances(id) | Workflow step reference |
| external_user_id | UUID | NOT NULL, FK → users(user_id) | External user |
| organization_id | UUID | NOT NULL, FK → organizations(organization_id) | User's organization |
| notification_type | VARCHAR(50) | CHECK | EMAIL, SMS, PORTAL |
| notification_subject | VARCHAR(255) | NULL | Notification subject |
| notification_body | TEXT | NULL | Notification body |
| sent_at | TIMESTAMPTZ | DEFAULT NOW() | Sent timestamp |
| opened_at | TIMESTAMPTZ | NULL | Opened timestamp |
| actioned_at | TIMESTAMPTZ | NULL | Action taken timestamp |

**Check Constraints:** notification_type IN ('EMAIL', 'SMS', 'PORTAL')  
**Indexes:** step_instance_id, external_user_id, organization_id, tenant_id  
**RLS:** Enabled with tenant isolation

---

### **1.10 external_access_audit_log**
**Purpose:** Comprehensive audit trail for all external user actions

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| log_id | UUID | PK, DEFAULT gen_random_uuid() | Primary key |
| tenant_id | UUID | NOT NULL, FK → tenants(tenant_id) | Tenant isolation |
| user_id | UUID | NOT NULL, FK → users(user_id) | User who performed action |
| organization_id | UUID | NULL, FK → organizations(organization_id) | User's organization |
| action_type | VARCHAR(50) | NOT NULL | Action type |
| resource_type | VARCHAR(50) | NOT NULL | Resource type |
| resource_id | UUID | NOT NULL | Resource ID |
| project_id | UUID | NULL, FK → projects(project_id) | Project context |
| ip_address | VARCHAR(45) | NULL | User IP address |
| user_agent | TEXT | NULL | User agent string |
| action_details | JSONB | NULL | Additional action details |
| accessed_at | TIMESTAMPTZ | DEFAULT NOW() | Action timestamp |

**Action Types:** VIEW, DOWNLOAD, UPLOAD, COMMENT, APPROVE, REJECT  
**Resource Types:** DRAWING, PROGRESS_UPDATE, TICKET, WORKFLOW  
**Indexes:** user_id, organization_id, (resource_type, resource_id), project_id, accessed_at DESC, tenant_id  
**RLS:** Enabled with tenant isolation

---

## **2. CHANGES TO EXISTING TABLES**

### **2.1 users table**
**Add new field:**

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| user_type | VARCHAR(20) | DEFAULT 'INTERNAL', CHECK | User classification |

**Check Constraint:** user_type IN ('INTERNAL', 'EXTERNAL')

**Purpose:** Distinguish internal employees from external users (customers/vendors)

---

### **2.2 step_instances table**
**Add new fields:**

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| is_external_participant | BOOLEAN | DEFAULT false | External user flag |
| notification_sent_at | TIMESTAMPTZ | NULL | Notification timestamp |

**Purpose:** Track external user participation in workflows

---

## **3. HELPER FUNCTIONS**

### **3.1 get_organization_tier_level()**
```sql
FUNCTION get_organization_tier_level(p_organization_id UUID, p_project_id UUID) 
RETURNS INT
```
**Purpose:** Get organization's tier level for a specific project

### **3.2 user_has_module_access()**
```sql
FUNCTION user_has_module_access(p_user_id UUID, p_project_id UUID, p_module_name TEXT) 
RETURNS BOOLEAN
```
**Purpose:** Check if user has access to a specific module on a project

---

## **4. ROW LEVEL SECURITY (RLS) POLICIES**

All tables have RLS enabled with tenant isolation policies:
```sql
CREATE POLICY {table}_tenant_isolation ON {table}
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
```

**Additional RLS for external users:**
- Drawings: External users see only drawings from projects they have access to
- Progress Updates: Vendors see only their own updates
- Tickets: Contractors see only assigned tickets
- Audit Log: Users see only their own actions

---

## **5. KEY FEATURES**

✅ **Multi-Role Organizations:** Same org can be customer on Project A, vendor on Project B  
✅ **Supply Chain Support:** Nested vendor relationships (vendor's vendor)  
✅ **Tiered Access Control:** Tier 1 (direct), Tier 2 (sub-vendor), Tier 3 (sub-sub-vendor)  
✅ **Module-Level Permissions:** Control access to DRAWINGS, VENDOR_PROGRESS, FIELD_SERVICE, WORKFLOW  
✅ **Time-Bound Access:** Automatic expiry via access_start_date/access_end_date  
✅ **Complete Audit Trail:** Track all external user actions  
✅ **Tenant Isolation:** All tables enforce tenant-level data separation  
✅ **ADP-Style Portal:** Similar to ADP's external access model  

---

## **6. IMPLEMENTATION PHASES**

### **Phase 1: Foundation (Immediate)**
- Create organizations table
- Create organization_relationships table
- Create organization_users table
- Create project_organization_access table
- Update users table with user_type field

### **Phase 2: Drawing Module (Short-term)**
- Create drawing_customer_approvals table
- Update RLS policies for drawings
- Implement drawing approval workflow

### **Phase 3: Vendor & Field Service (Medium-term)**
- Create vendor_progress_updates table
- Create field_service_tickets table
- Implement vendor portal features

### **Phase 4: Workflow & Audit (Long-term)**
- Create external_workflow_notifications table
- Create external_access_audit_log table
- Update step_instances table
- Implement comprehensive audit logging

---

## **7. SECURITY CONSIDERATIONS**

1. **Data Isolation:** External users NEVER see data from other organizations
2. **Time-Bound Access:** All access has expiry dates
3. **Audit Trail:** Every action is logged
4. **Module Restrictions:** Access limited to specific modules only
5. **Tier-Based Permissions:** Lower tiers have more restrictions
6. **RLS Enforcement:** Database-level security, not just application-level

---

## **8. TOTAL IMPACT**

**New Tables:** 10  
**Modified Tables:** 2 (users, step_instances)  
**New Functions:** 2  
**New RLS Policies:** 10+  
**New Indexes:** 40+  

**Estimated Development Time:** 4-6 weeks for full implementation
