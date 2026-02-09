# Material Request (MR) - Requestors & Workflow

## Who Raises Material Requests?

### **Primary Requestors**

#### 1. **Site Engineers / Site Supervisors**
- **Most Common Requestor** (60-70% of MRs)
- Raise MRs for materials needed at construction sites
- Examples:
  - Cement, steel, aggregates for ongoing work
  - Consumables (nails, bolts, paint)
  - Equipment rentals

#### 2. **Project Managers**
- Raise MRs for project-level requirements
- Examples:
  - Bulk material orders for project phases
  - Specialized equipment
  - Subcontractor materials

#### 3. **Store Keepers / Warehouse Managers**
- Raise MRs to replenish stock
- Examples:
  - Reorder when stock reaches minimum level
  - Seasonal stock buildup
  - Fast-moving items

#### 4. **Foremen / Gang Leaders**
- Raise MRs for their work crews
- Examples:
  - Daily/weekly material needs
  - Tools and equipment
  - Safety gear

#### 5. **Planning Engineers**
- Raise MRs based on project schedules
- Examples:
  - Materials for upcoming activities
  - Long-lead items
  - Imported materials

#### 6. **Maintenance Team**
- Raise MRs for maintenance activities
- Examples:
  - Spare parts
  - Maintenance consumables
  - Equipment repairs

#### 7. **QA/QC Engineers**
- Raise MRs for quality testing
- Examples:
  - Testing materials
  - Lab equipment
  - Calibration tools

---

## MR Types by Requestor

| Requestor | MR Type | Frequency | Approval Level |
|-----------|---------|-----------|----------------|
| Site Engineer | Standard | Daily/Weekly | Project Manager |
| Project Manager | Project | Weekly/Monthly | Construction Manager |
| Store Keeper | Stock Replenishment | Weekly | Warehouse Manager |
| Foreman | Urgent/Emergency | As needed | Site Engineer |
| Planning Engineer | Planned | Monthly | Project Manager |
| Maintenance | Maintenance | As needed | Maintenance Manager |
| QA/QC | Testing | As needed | QA Manager |

---

## Approval Workflow

### **Level 1: Site Level (< $5,000)**
```
Site Engineer → Project Manager → Procurement
```

### **Level 2: Project Level ($5,000 - $50,000)**
```
Project Manager → Construction Manager → Procurement Manager → Vendor
```

### **Level 3: High Value (> $50,000)**
```
Project Manager → Construction Manager → Finance Manager → CEO/Director → Procurement
```

### **Emergency Requests**
```
Any Requestor → Site Manager → Immediate Procurement (Post-approval within 24 hours)
```

---

## User Roles & Permissions

### **MR Creation Permissions**

```typescript
// Role-based MR creation
const MR_CREATOR_ROLES = [
  'SITE_ENGINEER',
  'PROJECT_MANAGER',
  'STORE_KEEPER',
  'FOREMAN',
  'PLANNING_ENGINEER',
  'MAINTENANCE_ENGINEER',
  'QA_ENGINEER',
  'WAREHOUSE_MANAGER'
];

// Approval permissions
const MR_APPROVER_ROLES = [
  'PROJECT_MANAGER',
  'CONSTRUCTION_MANAGER',
  'PROCUREMENT_MANAGER',
  'FINANCE_MANAGER',
  'CEO'
];
```

---

## Database Schema for Requestors

### **Current Schema**
```sql
-- material_requests table
requested_by UUID NOT NULL,  -- User ID who raised the MR
created_by UUID NOT NULL,    -- Same as requested_by
```

### **Enhanced Schema (Recommended)**
```sql
ALTER TABLE material_requests
ADD COLUMN requested_by_role VARCHAR(50),      -- Role of requestor
ADD COLUMN requested_for_department VARCHAR(50), -- Department
ADD COLUMN requested_for_location VARCHAR(100),  -- Site/Office location
ADD COLUMN approver_level_1 UUID,              -- First approver
ADD COLUMN approver_level_2 UUID,              -- Second approver
ADD COLUMN approver_level_3 UUID,              -- Third approver (if needed)
ADD COLUMN approval_level_1_date TIMESTAMP,
ADD COLUMN approval_level_2_date TIMESTAMP,
ADD COLUMN approval_level_3_date TIMESTAMP;
```

---

## Real-World Scenarios

### **Scenario 1: Site Engineer Needs Cement**
```
1. Site Engineer (John) logs into mobile app at site
2. Creates MR for 100 bags of cement
3. Assigns to Project: Highway-001, WBS: Civil Works
4. Sets priority: HIGH, Required date: Tomorrow
5. Submits MR
6. Project Manager (Sarah) receives notification
7. Sarah approves MR
8. Procurement team receives approved MR
9. Procurement converts MR → PR → PO
```

### **Scenario 2: Store Keeper Replenishment**
```
1. Store Keeper (Mike) checks stock levels
2. Sees cement stock below reorder point (50 bags)
3. Creates MR for 500 bags (reorder quantity)
4. Assigns to Cost Center: Warehouse
5. Warehouse Manager (Lisa) approves
6. Procurement processes order
```

### **Scenario 3: Emergency Request**
```
1. Foreman (David) needs urgent steel bars (equipment breakdown)
2. Creates URGENT MR via mobile app
3. Site Manager (Tom) gets instant notification
4. Tom approves immediately
5. Procurement expedites order
6. Post-approval by Project Manager within 24 hours
```

---

## MR Request Types

### **1. Standard Request**
- Normal materials for ongoing work
- Lead time: 3-7 days
- Approval: 1 level

### **2. Urgent Request**
- Critical materials needed quickly
- Lead time: 1-2 days
- Approval: Fast-track (same day)

### **3. Emergency Request**
- Immediate need (safety, breakdown)
- Lead time: Same day
- Approval: Post-approval allowed

### **4. Planned Request**
- Materials for future activities
- Lead time: 2-4 weeks
- Approval: Standard process

### **5. Stock Replenishment**
- Warehouse stock reorder
- Lead time: 1-2 weeks
- Approval: Automated (if below reorder point)

---

## Validation Rules

### **Requestor Validation**
```sql
-- Check if user has permission to create MR
CREATE OR REPLACE FUNCTION can_create_mr(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles ur
    JOIN roles r ON ur.role_id = r.id
    WHERE ur.user_id = user_id
    AND r.role_code IN (
      'SITE_ENGINEER',
      'PROJECT_MANAGER',
      'STORE_KEEPER',
      'FOREMAN',
      'PLANNING_ENGINEER',
      'MAINTENANCE_ENGINEER',
      'QA_ENGINEER'
    )
  );
END;
$$ LANGUAGE plpgsql;
```

### **Approval Authority Validation**
```sql
-- Check if user can approve based on MR value
CREATE OR REPLACE FUNCTION can_approve_mr(
  user_id UUID,
  mr_total_amount DECIMAL
)
RETURNS BOOLEAN AS $$
DECLARE
  user_approval_limit DECIMAL;
BEGIN
  SELECT approval_limit INTO user_approval_limit
  FROM user_approval_limits
  WHERE user_id = user_id
  AND document_type = 'MR'
  AND is_active = true;
  
  RETURN user_approval_limit >= mr_total_amount;
END;
$$ LANGUAGE plpgsql;
```

---

## UI/UX Considerations

### **Mobile App (Primary for Site Users)**
- Quick MR creation (< 2 minutes)
- Voice-to-text for descriptions
- Photo attachment for material reference
- Offline mode (sync when online)
- Push notifications for approvals

### **Web App (Office Users)**
- Bulk MR creation
- Copy from previous MRs
- Template-based creation
- Advanced search and filters
- Dashboard for pending approvals

---

## Reporting & Analytics

### **By Requestor**
- Top requestors by volume
- Average MR value by requestor
- Approval time by requestor
- Rejection rate by requestor

### **By Department**
- MR volume by department
- Material consumption by department
- Budget utilization by department

### **By Project**
- MR volume by project
- Material cost by project
- Variance analysis (planned vs actual)

---

## Best Practices

1. **Empower Site Teams**: Give site engineers direct MR creation access
2. **Set Approval Limits**: Define clear approval authority by value
3. **Enable Mobile**: 80% of MRs should be creatable via mobile
4. **Auto-routing**: System should route to correct approver based on rules
5. **Notifications**: Real-time alerts for requestors and approvers
6. **Audit Trail**: Track all changes and approvals
7. **Training**: Train all potential requestors on MR process

---

## Status: ✅ DOCUMENTED

**Next Steps**:
1. Implement role-based MR creation
2. Add approval workflow engine
3. Create mobile-first MR form
4. Set up notification system
