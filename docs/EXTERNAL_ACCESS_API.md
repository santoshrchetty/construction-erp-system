# External Access API Documentation

## Base URL
```
/api/external-access
```

## Authentication
All endpoints require authentication. Set user context via `app.current_user_id` session variable.

---

## Organizations

### List Organizations
```typescript
GET /api/external-access?action=list-organizations&tenant_id={id}&is_internal={bool}&org_type={type}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "external_org_id": "uuid",
      "name": "ABC Construction",
      "org_type": "CONTRACTOR",
      "is_internal": false,
      "is_active": true
    }
  ]
}
```

### Get Organization
```typescript
GET /api/external-access?action=get-organization&external_org_id={id}
```

### Create Organization
```typescript
POST /api/external-access?action=create-organization
Body: {
  "tenant_id": "uuid",
  "name": "ABC Construction",
  "org_type": "CONTRACTOR",
  "is_internal": false,
  "contact_email": "contact@abc.com",
  "contact_phone": "+1234567890"
}
```

### Update Organization
```typescript
PUT /api/external-access?action=update-organization
Body: {
  "external_org_id": "uuid",
  "name": "ABC Construction Ltd",
  "contact_email": "new@abc.com"
}
```

### Deactivate Organization
```typescript
DELETE /api/external-access?action=deactivate-organization&external_org_id={id}
```

---

## Organization Users

### List Organization Users
```typescript
GET /api/external-access?action=list-org-users&external_org_id={id}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "org_user_id": "uuid",
      "external_org_id": "uuid",
      "user_id": "uuid",
      "role": "PROJECT_MANAGER",
      "is_active": true,
      "user": {
        "email": "john@abc.com",
        "full_name": "John Doe"
      }
    }
  ]
}
```

### Invite User
```typescript
POST /api/external-access?action=invite-user
Body: {
  "email": "john@abc.com",
  "external_org_id": "uuid",
  "role": "PROJECT_MANAGER",
  "invited_by": "uuid"
}
```

### Activate User
```typescript
PUT /api/external-access?action=activate-user
Body: {
  "org_user_id": "uuid"
}
```

### Deactivate User
```typescript
PUT /api/external-access?action=deactivate-user
Body: {
  "org_user_id": "uuid"
}
```

---

## Resource Access

### List Resource Access
```typescript
GET /api/external-access?action=list-resource-access&external_org_id={id}&resource_type={type}&resource_id={id}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "access_id": "uuid",
      "external_org_id": "uuid",
      "resource_type": "DRAWING",
      "resource_id": "uuid",
      "access_level": "VIEW",
      "is_active": true,
      "organization": {
        "name": "ABC Construction"
      }
    }
  ]
}
```

### Grant Access
```typescript
POST /api/external-access?action=grant-access
Body: {
  "tenant_id": "uuid",
  "external_org_id": "uuid",
  "resource_type": "DRAWING",
  "resource_id": "uuid",
  "access_level": "VIEW",
  "access_start_date": "2024-01-01",
  "access_end_date": "2024-12-31",
  "granted_by": "uuid",
  "notes": "Access for review"
}
```

**Resource Types:** `PROJECT`, `DRAWING`, `DOCUMENT`, `FACILITY`, `EQUIPMENT`, `FOLDER`  
**Access Levels:** `VIEW`, `COMMENT`, `EDIT`, `ADMIN`

### Revoke Access
```typescript
DELETE /api/external-access?action=revoke-access&access_id={id}
```

### Update Access
```typescript
PUT /api/external-access?action=update-access
Body: {
  "access_id": "uuid",
  "access_level": "COMMENT",
  "access_end_date": "2025-12-31"
}
```

---

## Drawings

### List Drawings
```typescript
GET /api/external-access?action=list-drawings&project_id={id}&drawing_category={category}
```

**Drawing Categories:** `CONSTRUCTION`, `MAINTENANCE`, `AS_BUILT`, `SHOP_DRAWING`, `SUBMITTAL`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "drawing_number": "A-101",
      "title": "Floor Plan",
      "status": "RELEASED",
      "is_released": true,
      "drawing_category": "CONSTRUCTION"
    }
  ]
}
```

### Get Drawing
```typescript
GET /api/external-access?action=get-drawing&id={id}
```

### Release Drawing
```typescript
PUT /api/external-access?action=release-drawing
Body: {
  "id": "uuid",
  "released_by": "uuid"
}
```

---

## Facilities

### List Facilities
```typescript
GET /api/external-access?action=list-facilities&project_id={id}
```

### Get Facility
```typescript
GET /api/external-access?action=get-facility&facility_id={id}
```

---

## Equipment

### List Equipment
```typescript
GET /api/external-access?action=list-equipment&facility_id={id}&project_id={id}
```

### Get Equipment
```typescript
GET /api/external-access?action=get-equipment&equipment_id={id}
```

---

## Customer Approvals

### Submit Approval
```typescript
POST /api/external-access?action=submit-approval
Body: {
  "tenant_id": "uuid",
  "drawing_id": "uuid",
  "external_org_id": "uuid",
  "approval_status": "APPROVED",
  "approved_by": "uuid",
  "comments": "Approved with minor comments"
}
```

**Approval Status:** `PENDING`, `APPROVED`, `REJECTED`, `APPROVED_WITH_COMMENTS`

### List Approvals
```typescript
GET /api/external-access?action=list-approvals&drawing_id={id}&external_org_id={id}
```

---

## Vendor Progress

### Submit Progress
```typescript
POST /api/external-access?action=submit-progress
Body: {
  "tenant_id": "uuid",
  "drawing_id": "uuid",
  "external_org_id": "uuid",
  "progress_percentage": 75,
  "status": "IN_PROGRESS",
  "notes": "Fabrication 75% complete",
  "submitted_by": "uuid"
}
```

**Progress Status:** `NOT_STARTED`, `IN_PROGRESS`, `COMPLETED`, `ON_HOLD`

### List Progress
```typescript
GET /api/external-access?action=list-progress&drawing_id={id}&external_org_id={id}
```

---

## Field Service Tickets

### Create Ticket
```typescript
POST /api/external-access?action=create-ticket
Body: {
  "tenant_id": "uuid",
  "facility_id": "uuid",
  "equipment_id": "uuid",
  "assigned_external_org_id": "uuid",
  "title": "Pump not working",
  "description": "Main pump stopped working",
  "priority": "HIGH",
  "status": "OPEN",
  "reported_by": "uuid"
}
```

**Priority:** `LOW`, `MEDIUM`, `HIGH`, `CRITICAL`  
**Status:** `OPEN`, `ASSIGNED`, `IN_PROGRESS`, `RESOLVED`, `CLOSED`

### List Tickets
```typescript
GET /api/external-access?action=list-tickets&facility_id={id}&equipment_id={id}&assigned_external_org_id={id}&status={status}
```

### Update Ticket
```typescript
PUT /api/external-access?action=update-ticket
Body: {
  "ticket_id": "uuid",
  "status": "RESOLVED",
  "resolution_notes": "Replaced pump motor"
}
```

---

## Error Handling

All endpoints return consistent error format:

```json
{
  "success": false,
  "error": "Error message"
}
```

**HTTP Status Codes:**
- `200` - Success
- `400` - Bad Request (missing action or invalid params)
- `500` - Server Error

---

## Usage Examples

### Frontend Client Example

```typescript
// Grant drawing access to customer
async function grantDrawingAccess(drawingId: string, orgId: string) {
  const response = await fetch('/api/external-access?action=grant-access', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      tenant_id: currentTenantId,
      external_org_id: orgId,
      resource_type: 'DRAWING',
      resource_id: drawingId,
      access_level: 'VIEW',
      granted_by: currentUserId
    })
  })
  
  const result = await response.json()
  if (result.success) {
    console.log('Access granted:', result.data)
  }
}

// List drawings for external user (RLS enforces RELEASED only)
async function getMyDrawings(projectId: string) {
  const response = await fetch(
    `/api/external-access?action=list-drawings&project_id=${projectId}`
  )
  
  const result = await response.json()
  return result.data // Only RELEASED drawings returned
}

// Submit customer approval
async function approveDrawing(drawingId: string, status: string, comments: string) {
  const response = await fetch('/api/external-access?action=submit-approval', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      tenant_id: currentTenantId,
      drawing_id: drawingId,
      external_org_id: currentOrgId,
      approval_status: status,
      approved_by: currentUserId,
      comments
    })
  })
  
  return await response.json()
}
```

---

## Security Notes

1. **RLS Policies**: All queries automatically filtered by Row Level Security
2. **External Users**: See only RELEASED drawings via RLS
3. **Resource Access**: Checked at database level via `has_resource_access()` function
4. **Audit Trail**: All actions logged in `external_access_audit_log` table
5. **Session Context**: User ID set via `app.current_user_id` session variable

---

## Next Steps

1. Implement user invitation email system
2. Add file upload/download for drawings
3. Create frontend UI components
4. Add real-time notifications
5. Implement audit log viewer
