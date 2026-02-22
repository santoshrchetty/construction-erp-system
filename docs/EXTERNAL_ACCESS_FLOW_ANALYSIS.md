# EXTERNAL ACCESS - FLOW ANALYSIS & MISSING DETAILS

## **1. CRITICAL MISSING DETAILS**

### **1.1 User Onboarding Flow**
**MISSING:** How external users are created and invited

**Required:**
```sql
-- Add invitation tracking table
CREATE TABLE organization_user_invitations (
  invitation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  invited_email VARCHAR(255) NOT NULL,
  invited_by UUID NOT NULL REFERENCES users(user_id),
  invitation_token VARCHAR(255) UNIQUE NOT NULL,
  invitation_status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, ACCEPTED, EXPIRED, REVOKED
  expires_at TIMESTAMPTZ NOT NULL,
  accepted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (invitation_status IN ('PENDING', 'ACCEPTED', 'EXPIRED', 'REVOKED'))
);
```

**Flow:**
1. Internal user invites external user via email
2. System creates invitation record with token
3. External user clicks link, creates account
4. System creates user + organization_users link
5. System grants project access based on invitation

---

### **1.2 Drawing Sharing/Assignment Flow**
**MISSING:** How drawings are assigned to customers for approval

**Required:**
```sql
-- Add drawing assignments table
CREATE TABLE drawing_assignments (
  assignment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  drawing_id UUID NOT NULL REFERENCES drawings(id),
  organization_id UUID NOT NULL REFERENCES organizations(organization_id),
  assigned_by UUID NOT NULL REFERENCES users(user_id),
  due_date DATE,
  is_mandatory BOOLEAN DEFAULT true,
  assignment_status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, IN_REVIEW, COMPLETED
  assigned_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  UNIQUE(drawing_id, organization_id),
  CHECK (assignment_status IN ('PENDING', 'IN_REVIEW', 'COMPLETED'))
);
```

**Flow:**
1. Internal user uploads drawing
2. Internal user assigns drawing to customer org for approval
3. System creates drawing_assignment record
4. System sends notification to customer users
5. Customer reviews and creates drawing_customer_approval
6. System updates assignment_status to COMPLETED

---

### **1.3 Access Revocation Flow**
**MISSING:** How to revoke access when project ends or relationship terminates

**Required:**
```sql
-- Add access revocation tracking
CREATE TABLE access_revocations (
  revocation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  access_id UUID NOT NULL REFERENCES project_organization_access(access_id),
  revoked_by UUID NOT NULL REFERENCES users(user_id),
  revocation_reason TEXT,
  revoked_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add trigger to auto-revoke on end date
CREATE OR REPLACE FUNCTION auto_revoke_expired_access()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.access_end_date IS NOT NULL AND NEW.access_end_date < CURRENT_DATE THEN
    NEW.is_active = false;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_access_expiry
  BEFORE UPDATE ON project_organization_access
  FOR EACH ROW
  EXECUTE FUNCTION auto_revoke_expired_access();
```

---

### **1.4 Notification Preferences**
**MISSING:** User notification settings

**Required:**
```sql
CREATE TABLE user_notification_preferences (
  preference_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(user_id) UNIQUE,
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  
  -- Email notifications
  email_enabled BOOLEAN DEFAULT true,
  email_frequency VARCHAR(20) DEFAULT 'IMMEDIATE', -- IMMEDIATE, DAILY, WEEKLY
  
  -- Notification types
  notify_drawing_assignment BOOLEAN DEFAULT true,
  notify_drawing_update BOOLEAN DEFAULT true,
  notify_workflow_action BOOLEAN DEFAULT true,
  notify_ticket_assignment BOOLEAN DEFAULT true,
  notify_progress_due BOOLEAN DEFAULT true,
  
  -- SMS notifications (future)
  sms_enabled BOOLEAN DEFAULT false,
  sms_phone VARCHAR(20),
  
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

### **1.5 Document Versioning for External Users**
**MISSING:** How external users see drawing revisions

**Required:**
- Add `visible_to_external` flag to drawing_revisions
- External users should only see APPROVED revisions by default
- Add RLS policy for drawing_revisions

```sql
-- Add to drawing_revisions
ALTER TABLE drawing_revisions ADD COLUMN visible_to_external BOOLEAN DEFAULT false;

-- RLS for external users
CREATE POLICY drawing_revisions_external_access ON drawing_revisions
  FOR SELECT
  USING (
    visible_to_external = true
    AND EXISTS (
      SELECT 1 FROM organization_users ou
      JOIN project_organization_access poa ON ou.organization_id = poa.organization_id
      JOIN drawings d ON drawing_revisions.drawing_id = d.id
      WHERE ou.user_id = auth.uid()
      AND poa.project_id = d.project_id
      AND 'DRAWINGS' = ANY(poa.allowed_modules)
    )
  );
```

---

## **2. MISSING RLS POLICIES FOR EXTERNAL USERS**

### **2.1 Drawings RLS - External User Access**
```sql
CREATE POLICY drawings_external_user_access ON drawings
  FOR SELECT
  USING (
    -- Internal users see all
    EXISTS (
      SELECT 1 FROM users u
      LEFT JOIN organization_users ou ON u.user_id = ou.user_id
      WHERE u.user_id = auth.uid()
      AND ou.organization_id IS NULL -- No org = internal user
    )
    OR
    -- External users see only assigned project drawings
    EXISTS (
      SELECT 1 FROM organization_users ou
      JOIN project_organization_access poa ON ou.organization_id = poa.organization_id
      WHERE ou.user_id = auth.uid()
      AND poa.project_id = drawings.project_id
      AND poa.is_active = true
      AND 'DRAWINGS' = ANY(poa.allowed_modules)
      AND CURRENT_DATE BETWEEN poa.access_start_date 
          AND COALESCE(poa.access_end_date, '2099-12-31')
      -- Tier 3+ can only see APPROVED drawings
      AND (poa.tier_level <= 2 OR drawings.status = 'APPROVED')
    )
  );
```

### **2.2 Drawing Comments RLS**
```sql
CREATE POLICY drawing_comments_external_access ON drawing_comments
  FOR ALL
  USING (
    -- Can see comments on drawings they have access to
    EXISTS (
      SELECT 1 FROM drawings d
      JOIN organization_users ou ON true
      JOIN project_organization_access poa ON ou.organization_id = poa.organization_id
      WHERE d.id = drawing_comments.drawing_id
      AND ou.user_id = auth.uid()
      AND poa.project_id = d.project_id
      AND 'DRAWINGS' = ANY(poa.allowed_modules)
    )
  )
  WITH CHECK (
    -- Can only create comments if they have COMMENT or WRITE access
    EXISTS (
      SELECT 1 FROM drawings d
      JOIN organization_users ou ON true
      JOIN project_organization_access poa ON ou.organization_id = poa.organization_id
      WHERE d.id = drawing_comments.drawing_id
      AND ou.user_id = auth.uid()
      AND poa.project_id = d.project_id
      AND poa.access_level IN ('COMMENT', 'WRITE')
    )
  );
```

### **2.3 Vendor Progress Updates RLS**
```sql
CREATE POLICY vendor_progress_own_org_only ON vendor_progress_updates
  FOR ALL
  USING (
    -- Internal users see all
    NOT EXISTS (
      SELECT 1 FROM organization_users ou
      WHERE ou.user_id = auth.uid()
    )
    OR
    -- External users see only their org's updates
    EXISTS (
      SELECT 1 FROM organization_users ou
      WHERE ou.user_id = auth.uid()
      AND ou.organization_id = vendor_progress_updates.organization_id
    )
  )
  WITH CHECK (
    -- Can only create for their own org
    EXISTS (
      SELECT 1 FROM organization_users ou
      JOIN project_organization_access poa ON ou.organization_id = poa.organization_id
      WHERE ou.user_id = auth.uid()
      AND ou.organization_id = vendor_progress_updates.organization_id
      AND poa.project_id = vendor_progress_updates.project_id
      AND 'VENDOR_PROGRESS' = ANY(poa.allowed_modules)
      AND poa.access_level IN ('WRITE')
    )
  );
```

### **2.4 Field Service Tickets RLS**
```sql
CREATE POLICY field_service_tickets_external_access ON field_service_tickets
  FOR ALL
  USING (
    -- Internal users see all
    NOT EXISTS (
      SELECT 1 FROM organization_users ou
      WHERE ou.user_id = auth.uid()
    )
    OR
    -- External users see only tickets assigned to their org
    EXISTS (
      SELECT 1 FROM organization_users ou
      WHERE ou.user_id = auth.uid()
      AND ou.organization_id = field_service_tickets.assigned_organization_id
    )
  );
```

---

## **3. MISSING BUSINESS LOGIC**

### **3.1 Automatic Tier Calculation**
**MISSING:** Function to calculate tier level based on relationship chain

```sql
CREATE OR REPLACE FUNCTION calculate_tier_level(
  p_source_org_id UUID,
  p_target_org_id UUID,
  p_tenant_id UUID
) RETURNS INT AS $$
DECLARE
  v_tier INT := 1;
  v_current_org UUID := p_target_org_id;
  v_parent_org UUID;
BEGIN
  -- Traverse relationship chain up to 5 levels
  WHILE v_tier <= 5 LOOP
    SELECT source_org_id INTO v_parent_org
    FROM organization_relationships
    WHERE target_org_id = v_current_org
    AND tenant_id = p_tenant_id
    AND relationship_type = 'VENDOR'
    AND is_active = true
    LIMIT 1;
    
    IF v_parent_org IS NULL THEN
      RETURN NULL; -- No relationship found
    END IF;
    
    IF v_parent_org = p_source_org_id THEN
      RETURN v_tier;
    END IF;
    
    v_current_org := v_parent_org;
    v_tier := v_tier + 1;
  END LOOP;
  
  RETURN NULL; -- Max depth exceeded
END;
$$ LANGUAGE plpgsql;
```

### **3.2 Access Inheritance**
**MISSING:** When Tier 1 vendor invites Tier 2, automatically grant limited access

```sql
CREATE OR REPLACE FUNCTION grant_subcontractor_access(
  p_parent_access_id UUID,
  p_subcontractor_org_id UUID,
  p_invited_by_user_id UUID
) RETURNS UUID AS $$
DECLARE
  v_parent_access project_organization_access%ROWTYPE;
  v_new_access_id UUID;
BEGIN
  -- Get parent access details
  SELECT * INTO v_parent_access
  FROM project_organization_access
  WHERE access_id = p_parent_access_id;
  
  -- Check if parent can invite
  IF NOT v_parent_access.can_invite_subcontractors THEN
    RAISE EXCEPTION 'Organization cannot invite subcontractors';
  END IF;
  
  -- Create subcontractor access with reduced permissions
  INSERT INTO project_organization_access (
    tenant_id,
    project_id,
    organization_id,
    access_granted_by_org_id,
    role_in_project,
    tier_level,
    allowed_modules,
    access_level,
    can_invite_subcontractors,
    access_start_date,
    access_end_date,
    created_by
  ) VALUES (
    v_parent_access.tenant_id,
    v_parent_access.project_id,
    p_subcontractor_org_id,
    v_parent_access.organization_id, -- Parent org granted access
    'CONTRACTOR',
    v_parent_access.tier_level + 1, -- Increment tier
    ARRAY['DRAWINGS'], -- Limited to drawings only
    'READ', -- Read-only
    false, -- Cannot invite further
    CURRENT_DATE,
    v_parent_access.access_end_date, -- Same end date as parent
    p_invited_by_user_id
  ) RETURNING access_id INTO v_new_access_id;
  
  RETURN v_new_access_id;
END;
$$ LANGUAGE plpgsql;
```

### **3.3 Drawing Approval Workflow Integration**
**MISSING:** Link drawing_customer_approvals to workflow system

```sql
-- Add workflow integration
ALTER TABLE drawing_customer_approvals 
  ADD COLUMN workflow_step_instance_id UUID REFERENCES step_instances(id);

-- Trigger to update workflow when approval is given
CREATE OR REPLACE FUNCTION handle_drawing_approval()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.approval_status = 'APPROVED' AND OLD.approval_status = 'PENDING' THEN
    -- Update workflow step instance
    UPDATE step_instances
    SET status = 'APPROVED',
        actioned_at = NEW.approved_at
    WHERE id = NEW.workflow_step_instance_id;
    
    -- Update drawing status
    UPDATE drawings
    SET status = 'APPROVED',
        approved_by = NEW.customer_user_id,
        approved_at = NEW.approved_at
    WHERE id = NEW.drawing_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_drawing_approval
  AFTER UPDATE ON drawing_customer_approvals
  FOR EACH ROW
  WHEN (NEW.approval_status != OLD.approval_status)
  EXECUTE FUNCTION handle_drawing_approval();
```

---

## **4. MISSING API/APPLICATION LAYER LOGIC**

### **4.1 Authentication & Session Management**
**Required:**
- Separate login endpoints for external users
- JWT tokens with organization_id claim
- Session timeout for external users (shorter than internal)
- IP whitelisting for sensitive customers

### **4.2 File Access Control**
**Required:**
- Presigned URLs for drawing downloads (time-limited)
- Watermarking for external user downloads
- Download limits per user/org
- File access logging

```sql
-- Add download tracking
CREATE TABLE file_download_log (
  download_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(tenant_id),
  user_id UUID NOT NULL REFERENCES users(user_id),
  organization_id UUID REFERENCES organizations(organization_id),
  file_type VARCHAR(50), -- DRAWING, ATTACHMENT, REPORT
  file_id UUID NOT NULL,
  file_path VARCHAR(500),
  download_url TEXT, -- Presigned URL
  ip_address VARCHAR(45),
  downloaded_at TIMESTAMPTZ DEFAULT NOW()
);
```

### **4.3 Rate Limiting**
**Required:**
- API rate limits per organization
- Stricter limits for external users
- Throttling for bulk downloads

---

## **5. MISSING VALIDATION & CONSTRAINTS**

### **5.1 Business Rule Validations**
```sql
-- Prevent circular relationships
CREATE OR REPLACE FUNCTION prevent_circular_org_relationships()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM organization_relationships
    WHERE source_org_id = NEW.target_org_id
    AND target_org_id = NEW.source_org_id
    AND tenant_id = NEW.tenant_id
  ) THEN
    RAISE EXCEPTION 'Circular relationship not allowed';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_circular_relationships
  BEFORE INSERT OR UPDATE ON organization_relationships
  FOR EACH ROW
  EXECUTE FUNCTION prevent_circular_org_relationships();
```

### **5.2 Access Date Validation**
```sql
-- Ensure access_start_date < access_end_date
ALTER TABLE project_organization_access
  ADD CONSTRAINT check_access_dates
  CHECK (access_end_date IS NULL OR access_end_date >= access_start_date);
```

### **5.3 Tier Level Validation**
```sql
-- Ensure tier level matches relationship chain
CREATE OR REPLACE FUNCTION validate_tier_level()
RETURNS TRIGGER AS $$
DECLARE
  v_calculated_tier INT;
BEGIN
  IF NEW.access_granted_by_org_id IS NOT NULL THEN
    -- Get parent org's tier level
    SELECT tier_level + 1 INTO v_calculated_tier
    FROM project_organization_access
    WHERE organization_id = NEW.access_granted_by_org_id
    AND project_id = NEW.project_id;
    
    IF NEW.tier_level != v_calculated_tier THEN
      RAISE EXCEPTION 'Tier level must be parent tier + 1';
    END IF;
  ELSE
    -- Direct access must be tier 1
    IF NEW.tier_level != 1 THEN
      RAISE EXCEPTION 'Direct access must be tier level 1';
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_access_tier
  BEFORE INSERT OR UPDATE ON project_organization_access
  FOR EACH ROW
  EXECUTE FUNCTION validate_tier_level();
```

---

## **6. MISSING REPORTING & ANALYTICS**

### **6.1 External User Activity Dashboard**
```sql
CREATE VIEW external_user_activity_summary AS
SELECT
  ou.organization_id,
  o.org_name,
  COUNT(DISTINCT ou.user_id) as total_users,
  COUNT(DISTINCT CASE WHEN u.last_login > NOW() - INTERVAL '30 days' THEN ou.user_id END) as active_users,
  COUNT(DISTINCT poa.project_id) as projects_count,
  COUNT(DISTINCT eal.log_id) as total_actions,
  MAX(eal.accessed_at) as last_activity
FROM organization_users ou
JOIN organizations o ON ou.organization_id = o.organization_id
JOIN users u ON ou.user_id = u.user_id
LEFT JOIN project_organization_access poa ON ou.organization_id = poa.organization_id
LEFT JOIN external_access_audit_log eal ON ou.user_id = eal.user_id
WHERE o.is_internal = false
GROUP BY ou.organization_id, o.org_name;
```

### **6.2 Drawing Approval Metrics**
```sql
CREATE VIEW drawing_approval_metrics AS
SELECT
  d.project_id,
  dca.organization_id,
  o.org_name,
  COUNT(*) as total_drawings,
  COUNT(CASE WHEN dca.approval_status = 'APPROVED' THEN 1 END) as approved_count,
  COUNT(CASE WHEN dca.approval_status = 'REJECTED' THEN 1 END) as rejected_count,
  COUNT(CASE WHEN dca.approval_status = 'PENDING' THEN 1 END) as pending_count,
  AVG(EXTRACT(EPOCH FROM (dca.approved_at - dca.created_at))/86400) as avg_approval_days
FROM drawing_customer_approvals dca
JOIN drawings d ON dca.drawing_id = d.id
JOIN organizations o ON dca.organization_id = o.organization_id
GROUP BY d.project_id, dca.organization_id, o.org_name;
```

---

## **7. MISSING DOCUMENTATION**

### **7.1 User Guides**
- External user onboarding guide
- Drawing approval process
- Vendor progress submission guide
- Field service ticket management

### **7.2 API Documentation**
- External API endpoints
- Authentication flow
- Rate limits
- Error codes

### **7.3 Admin Guides**
- How to onboard external organizations
- How to grant/revoke access
- How to monitor external user activity
- Security best practices

---

## **8. IMPLEMENTATION CHECKLIST**

### **Phase 1: Critical Missing Items**
- [ ] organization_user_invitations table
- [ ] drawing_assignments table
- [ ] User notification preferences
- [ ] All RLS policies for external users
- [ ] Access revocation logic
- [ ] Tier level calculation function

### **Phase 2: Business Logic**
- [ ] Subcontractor access inheritance
- [ ] Drawing approval workflow integration
- [ ] Circular relationship prevention
- [ ] Date validation constraints
- [ ] Tier level validation

### **Phase 3: Security & Monitoring**
- [ ] File download tracking
- [ ] Presigned URL generation
- [ ] Rate limiting
- [ ] IP whitelisting
- [ ] Audit log queries

### **Phase 4: Reporting & UX**
- [ ] Activity dashboards
- [ ] Approval metrics
- [ ] User guides
- [ ] API documentation
- [ ] Admin tools

---

## **9. SECURITY GAPS TO ADDRESS**

1. **Password Policy:** External users should have stricter password requirements
2. **MFA:** Consider mandatory MFA for external users
3. **Session Management:** Shorter session timeouts for external users
4. **IP Restrictions:** Allow IP whitelisting per organization
5. **Data Retention:** Policy for external user data after access revocation
6. **GDPR Compliance:** Right to be forgotten for external users
7. **Encryption:** Ensure all external user data is encrypted at rest

---

## **10. PERFORMANCE CONSIDERATIONS**

1. **Indexes:** Add composite indexes for common query patterns
2. **Partitioning:** Consider partitioning audit logs by month
3. **Caching:** Cache organization access checks
4. **Query Optimization:** RLS policies can be expensive - monitor performance
5. **Connection Pooling:** Separate pool for external user connections

---

## **SUMMARY OF CRITICAL GAPS**

**Must Have Before Launch:**
1. ✅ User invitation system
2. ✅ Drawing assignment workflow
3. ✅ All RLS policies
4. ✅ Access revocation logic
5. ✅ File access control
6. ✅ Audit logging

**Should Have:**
1. Notification preferences
2. Tier level auto-calculation
3. Approval workflow integration
4. Activity dashboards
5. Rate limiting

**Nice to Have:**
1. IP whitelisting
2. Download watermarking
3. Advanced analytics
4. Self-service portal
5. Mobile app support
