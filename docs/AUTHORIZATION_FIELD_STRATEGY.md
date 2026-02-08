# Authorization Field Assignment Strategy

## Core Principle: Full Access by Default

### Default Behavior
When an authorization object is assigned to a role, **all fields default to full access (`*`)**.

```json
{
  "COMP_CODE": ["*"],
  "PLANT": ["*"],
  "DEPT": ["*"],
  "ACTVT": ["*"]
}
```

This means:
- ✅ User can access **all** company codes
- ✅ User can access **all** plants
- ✅ User can access **all** departments
- ✅ User can perform **all** activities

---

## When to Create Restricted Roles

### Scenario 1: Geographic Restrictions
**Use Case**: Regional managers should only access their region's plants

**Solution**: Create role-specific field restrictions

```
Role: Regional_Manager_North
Authorization Object: MATERIAL_MASTER_READ
Field Values:
  COMP_CODE: ["*"]           ← All companies
  PLANT: ["P001", "P002"]    ← Only North region plants
  DEPT: ["*"]                ← All departments
  ACTVT: ["03"]              ← Display only
```

```
Role: Regional_Manager_South
Authorization Object: MATERIAL_MASTER_READ
Field Values:
  COMP_CODE: ["*"]
  PLANT: ["P003", "P004"]    ← Only South region plants
  DEPT: ["*"]
  ACTVT: ["03"]
```

### Scenario 2: Department-Specific Access
**Use Case**: Department heads should only manage their department

```
Role: HR_Manager
Authorization Object: EMPLOYEE_MASTER_CHANGE
Field Values:
  COMP_CODE: ["*"]
  PLANT: ["*"]
  DEPT: ["HR"]               ← Only HR department
  ACTVT: ["01", "02", "03"]  ← Create, Change, Display
```

```
Role: Finance_Manager
Authorization Object: EMPLOYEE_MASTER_CHANGE
Field Values:
  COMP_CODE: ["*"]
  PLANT: ["*"]
  DEPT: ["FINANCE"]          ← Only Finance department
  ACTVT: ["01", "02", "03"]
```

### Scenario 3: Activity Restrictions
**Use Case**: Junior staff can only view, not modify

```
Role: Junior_Analyst
Authorization Object: MATERIAL_MASTER_READ
Field Values:
  COMP_CODE: ["*"]
  PLANT: ["*"]
  DEPT: ["*"]
  ACTVT: ["03"]              ← Display only (no create/change)
```

```
Role: Senior_Analyst
Authorization Object: MATERIAL_MASTER_READ
Field Values:
  COMP_CODE: ["*"]
  PLANT: ["*"]
  DEPT: ["*"]
  ACTVT: ["01", "02", "03"]  ← Create, Change, Display
```

### Scenario 4: Value Limits
**Use Case**: Purchase approval limits based on amount

```
Role: Purchase_Officer
Authorization Object: PO_APPROVAL
Field Values:
  COMP_CODE: ["*"]
  PLANT: ["*"]
  PO_VALUE: ["0-50000"]      ← Up to 50K only
  ACTVT: ["01", "02", "03"]
```

```
Role: Purchase_Manager
Authorization Object: PO_APPROVAL
Field Values:
  COMP_CODE: ["*"]
  PLANT: ["*"]
  PO_VALUE: ["*"]            ← No limit
  ACTVT: ["01", "02", "03"]
```

---

## Implementation Strategy

### Step 1: Assign Object with Full Access (Default)
```sql
INSERT INTO role_authorization_objects (
  role_id,
  auth_object_id,
  field_values,
  tenant_id
) VALUES (
  'role-uuid',
  'object-uuid',
  '{"COMP_CODE": ["*"], "PLANT": ["*"], "DEPT": ["*"], "ACTVT": ["*"]}'::jsonb,
  'tenant-uuid'
);
```

### Step 2: Create Restricted Role (If Needed)
```sql
-- Create new role for restricted access
INSERT INTO roles (name, description, tenant_id)
VALUES ('Regional_Manager_North', 'North Region Manager', 'tenant-uuid');

-- Assign same object with field restrictions
INSERT INTO role_authorization_objects (
  role_id,
  auth_object_id,
  field_values,
  tenant_id
) VALUES (
  'regional-manager-north-uuid',
  'object-uuid',
  '{"COMP_CODE": ["*"], "PLANT": ["P001", "P002"], "DEPT": ["*"], "ACTVT": ["03"]}'::jsonb,
  'tenant-uuid'
);
```

---

## Authorization Check Logic

### Runtime Check Process
```typescript
function checkAuthorization(
  user: User,
  authObject: string,
  fieldValues: Record<string, string>
): boolean {
  // Get user's role assignments for this object
  const assignments = getUserRoleAssignments(user, authObject)
  
  // Check if any assignment grants access
  for (const assignment of assignments) {
    let hasAccess = true
    
    // Check each field
    for (const [field, requiredValue] of Object.entries(fieldValues)) {
      const allowedValues = assignment.field_values[field] || []
      
      // If field has wildcard, allow all
      if (allowedValues.includes('*')) {
        continue
      }
      
      // Check if required value is in allowed values
      if (!allowedValues.includes(requiredValue)) {
        hasAccess = false
        break
      }
    }
    
    // If this assignment grants access, return true
    if (hasAccess) {
      return true
    }
  }
  
  return false
}
```

### Example Check
```typescript
// User tries to view material in Plant P001
checkAuthorization(
  user,
  'MATERIAL_MASTER_READ',
  {
    COMP_CODE: '1000',
    PLANT: 'P001',
    DEPT: 'WAREHOUSE',
    ACTVT: '03'
  }
)

// If user has Regional_Manager_North role:
// - COMP_CODE: '1000' ✅ (allowed: ['*'])
// - PLANT: 'P001' ✅ (allowed: ['P001', 'P002'])
// - DEPT: 'WAREHOUSE' ✅ (allowed: ['*'])
// - ACTVT: '03' ✅ (allowed: ['03'])
// Result: GRANTED

// If user tries to access Plant P003:
// - PLANT: 'P003' ❌ (allowed: ['P001', 'P002'])
// Result: DENIED
```

---

## Best Practices

### 1. Start Broad, Restrict as Needed
- ✅ Assign objects with full access (`*`) initially
- ✅ Create restricted roles only when business requires it
- ❌ Don't create unnecessary restrictions upfront

### 2. Role Naming Convention
```
[Function]_[Level]_[Restriction]

Examples:
- Purchase_Manager_Full          (full access)
- Purchase_Officer_50K           (value limit)
- Regional_Manager_North         (geographic)
- Department_Head_HR             (department)
- Analyst_ReadOnly               (activity)
```

### 3. Field Value Inheritance
```
Priority Order:
1. Specific values: ["P001", "P002"]
2. Wildcard: ["*"]
3. Empty/NULL: Deny access

If user has multiple roles:
- Take UNION of all allowed values
- If any role has "*", grant full access
```

### 4. Audit Trail
```sql
-- Track who has access to what
SELECT 
  u.email,
  r.name as role,
  ao.object_name,
  rao.field_values
FROM users u
JOIN user_roles ur ON u.id = ur.user_id
JOIN roles r ON ur.role_id = r.id
JOIN role_authorization_objects rao ON r.id = rao.role_id
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE ao.object_name = 'MATERIAL_MASTER_READ'
ORDER BY u.email, r.name;
```

---

## UI Workflow

### For Administrators

**Step 1: Assign Module to Role (Full Access)**
```
1. Go to Authorization Objects → Role Assignments
2. Select role (e.g., "Engineer")
3. Click "Assign Modules"
4. Select modules (e.g., "materials", "projects")
5. System creates assignments with field_values = {"*": ["*"]}
```

**Step 2: Create Restricted Role (If Needed)**
```
1. Go to User Management → Roles
2. Create new role (e.g., "Engineer_Plant_P001")
3. Go to Authorization Objects → Role Assignments
4. Expand role → Expand module → Expand object
5. Click "Customize" to edit field values
6. Uncheck "*" and select specific values
7. Save custom template
```

**Step 3: Assign Users**
```
1. Go to User Management → User Role Assignment
2. Assign user to appropriate role:
   - Full access → "Engineer"
   - Restricted → "Engineer_Plant_P001"
```

---

## Summary

| Aspect | Approach |
|--------|----------|
| **Default** | Full access (`*`) for all fields |
| **Restriction** | Create new role with specific field values |
| **Flexibility** | Same object, different field values per role |
| **Maintenance** | Minimal - only create restrictions when needed |
| **Scalability** | Unlimited role variations possible |
| **Audit** | Track exact field values per role |

This approach provides maximum flexibility while keeping the system simple for common use cases.
