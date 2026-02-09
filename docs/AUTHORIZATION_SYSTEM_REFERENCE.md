# Authorization System - Complete Reference

**Last Updated**: 2024
**Status**: ✅ Production Ready - Tenant Isolated

---

## Table of Contents
1. [System Overview](#system-overview)
2. [Architecture](#architecture)
3. [Database Schema](#database-schema)
4. [Tenant Isolation](#tenant-isolation)
5. [Authorization Flow](#authorization-flow)
6. [Field Assignment Strategy](#field-assignment-strategy)
7. [API Endpoints](#api-endpoints)
8. [Migration Guide](#migration-guide)
9. [Best Practices](#best-practices)

---

## System Overview

### Purpose
SAP-style authorization system with:
- ✅ Authorization objects with field-level permissions
- ✅ Role-based access control (RBAC)
- ✅ Module-based tile filtering
- ✅ Strict tenant isolation
- ✅ Dynamic field values from organizational tables

### Key Features
- **116 authorization objects** across 15 modules
- **Tenant-aware RPC functions** with explicit isolation
- **Dynamic field values** from company_codes, plants, departments, etc.
- **Full access by default** with optional field restrictions
- **Zero cross-tenant data leakage** (verified)

---

## Architecture

### Four-Layer Authorization Model

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Field Configuration (Global catalog)              │
│ - authorization_field_config table                         │
│ - Defines available field types (COMP_CODE, PLANT, etc.)  │
│ - Specifies data sources for each field                   │
│ - No tenant_id (global configuration)                      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Authorization Objects (What can be accessed)      │
│ - authorization_objects table                              │
│ - 116 objects across 15 modules                            │
│ - Linked to fields via authorization_object_fields         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Object-Field Mapping (Which fields per object)    │
│ - authorization_object_fields junction table               │
│ - Links objects to field configurations                    │
│ - Defines which fields are required                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: Role Assignments (Who has access with what values)│
│ - role_authorization_objects table                         │
│ - Field values define restrictions                         │
│ - Default: Full access (*) for all fields                  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 5: Module Filtering (What tiles are visible)         │
│ - get_user_modules() RPC returns user's modules            │
│ - Tiles filtered by module_code                            │
│ - Tenant-isolated at every step                            │
└─────────────────────────────────────────────────────────────┘
```

---

## Database Schema

### Core Tables

#### 1. authorization_objects
```sql
CREATE TABLE authorization_objects (
  id uuid PRIMARY KEY,
  object_name text NOT NULL,           -- e.g., 'MATERIAL_MASTER_READ'
  description text,
  module text NOT NULL,                -- e.g., 'materials', 'projects'
  tenant_id uuid NOT NULL REFERENCES tenants(id),
  is_active boolean DEFAULT true,
  created_at timestamptz,
  updated_at timestamptz
);
```

**Module Distribution** (116 objects):
- materials: 24 objects
- finance: 21 objects
- projects: 17 objects
- configuration: 10 objects
- safety: 6 objects
- procurement: 6 objects
- hr: 5 objects
- warehouse: 4 objects
- admin: 4 objects
- user_tasks: 4 objects
- quality: 3 objects
- emergency: 3 objects
- documents: 2 objects
- integration: 2 objects
- reporting: 5 objects

#### 2. authorization_field_config (Global Configuration)
```sql
CREATE TABLE authorization_field_config (
  id uuid PRIMARY KEY,
  field_code varchar(50) UNIQUE NOT NULL,  -- e.g., 'COMP_CODE', 'PLANT', 'ACTVT'
  field_name varchar(100) NOT NULL,        -- Display name
  field_category varchar(50) NOT NULL,     -- Activity/Organizational/Business
  data_source_type varchar(50) NOT NULL,   -- static/table/enum
  source_table varchar(100),               -- Table to fetch values from
  source_value_column varchar(100),
  source_display_column varchar(100),
  static_values jsonb,                     -- For static fields
  default_value varchar(10) DEFAULT '*',
  is_active boolean DEFAULT true,
  display_order integer,
  help_text text,
  created_at timestamptz,
  updated_at timestamptz
);
```

**Purpose**: Global catalog of available field types (no tenant_id)

**Common Fields**:
- `ACTVT` → Activity (static: 01=Create, 02=Change, 03=Display, 06=Delete)
- `COMP_CODE` → Company Code (from company_codes table)
- `PLANT` → Plant (from plants table)
- `DEPT` → Department (from departments table)
- `STORAGE_LOC` → Storage Location (from storage_locations table)
- `COST_CENTER` → Cost Center (from cost_centers table)
- `PURCH_ORG` → Purchasing Organization (from purchasing_organizations table)
- `PROJ_TYPE` → Project Type (enum from projects.project_type)
- `MR_TYPE` → Material Request Type (enum from material_requests.mr_type)
- `PR_TYPE` → Purchase Requisition Type (enum from purchase_requisitions.pr_type)
- `MAT_TYPE` → Material Type (enum from materials.material_type)
- `PO_TYPE` → Purchase Order Type (static values)

#### 3. authorization_object_fields (Junction Table)
```sql
CREATE TABLE authorization_object_fields (
  id uuid PRIMARY KEY,
  auth_object_id uuid NOT NULL REFERENCES authorization_objects(id),
  field_code varchar(50) NOT NULL,     -- References authorization_field_config.field_code
  is_required boolean DEFAULT false,
  tenant_id uuid NOT NULL REFERENCES tenants(id),
  created_at timestamptz,
  updated_at timestamptz
);
```

**Purpose**: Links authorization objects to fields (which fields does each object have?)

#### 4. role_authorization_objects
```sql
CREATE TABLE role_authorization_objects (
  id uuid PRIMARY KEY,
  role_id uuid NOT NULL REFERENCES roles(id),
  auth_object_id uuid NOT NULL REFERENCES authorization_objects(id),
  field_values jsonb DEFAULT '{}'::jsonb,  -- Actual assigned values
  module_full_access boolean DEFAULT false,
  object_full_access boolean DEFAULT false,
  tenant_id uuid NOT NULL REFERENCES tenants(id),
  valid_from timestamptz DEFAULT now(),
  valid_to timestamptz,
  is_active boolean DEFAULT true,
  created_at timestamptz,
  updated_at timestamptz
);
```

**field_values Format**:
```json
{
  "COMP_CODE": ["1000", "2000", "*"],
  "PLANT": ["P001", "P002"],
  "DEPT": ["ADMIN", "FIELD"],
  "ACTVT": ["01", "02", "03"]
}
```

#### 5. roles
```sql
CREATE TABLE roles (
  id uuid PRIMARY KEY,
  name text NOT NULL,
  description text,
  tenant_id uuid NOT NULL REFERENCES tenants(id),
  is_active boolean DEFAULT true,
  created_at timestamptz,
  updated_at timestamptz
);
```

#### 6. user_roles
```sql
CREATE TABLE user_roles (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id),
  role_id uuid NOT NULL REFERENCES roles(id),
  tenant_id uuid NOT NULL REFERENCES tenants(id),
  created_at timestamptz,
  updated_at timestamptz
);
```

---

## Tenant Isolation

### ✅ Verified: Zero Cross-Tenant Data Leakage

**Verification Results**:
```sql
-- Tenant mismatch checks (all returned 0)
role_authorization_objects ↔ roles: 0 mismatches
authorization_fields ↔ authorization_objects: 0 mismatches
user_roles ↔ roles: 0 mismatches
```

### Isolation Mechanisms

#### 1. Database Level
- All tables have `tenant_id uuid NOT NULL`
- Foreign key constraints to `tenants(id)`
- No records exist without tenant_id

#### 2. API Level
```typescript
// All queries filter by tenant_id
.eq('tenant_id', tenantId)
```

#### 3. RPC Function Level
```sql
-- get_user_modules() with explicit tenant checks
WHERE ur.tenant_id = v_tenant_id
  AND r.tenant_id = v_tenant_id
  AND rao.tenant_id = v_tenant_id
  AND ao.tenant_id = v_tenant_id
```

#### 4. Field Values Level
```typescript
// Organizational tables filtered by tenant
.from('company_codes')
.eq('tenant_id', tenantId)
.eq('is_active', true)
```

**Reference**: See `docs/TENANT_ISOLATION_AUTHORIZATION.md` for complete verification.

---

## Authorization Flow

### Complete Flow Diagram

```
USER (emy@prom.com)
  ↓ has tenant_id
┌─────────────────────────────────────┐
│ users table                         │
│ - id: user-uuid                     │
│ - email: emy@prom.com               │
│ - tenant_id: 9bd339ec...            │
└─────────────────────────────────────┘
  ↓ user_roles (tenant-filtered)
┌─────────────────────────────────────┐
│ roles table                         │
│ - id: hr-role-uuid                  │
│ - name: "HR"                        │
│ - tenant_id: 9bd339ec...            │
└─────────────────────────────────────┘
  ↓ role_authorization_objects (tenant-filtered)
┌─────────────────────────────────────┐
│ authorization_objects table         │
│ - id: obj-uuid                      │
│ - object_name: "HR_EMPLOYEE_READ"  │
│ - module: "hr"                      │
│ - tenant_id: 9bd339ec...            │
└─────────────────────────────────────┘
  ↓ get_user_modules() RPC
┌─────────────────────────────────────┐
│ Returns: ["hr"]                     │
│ (friendly module names)             │
└─────────────────────────────────────┘
  ↓ tiles filtered by module_code
┌─────────────────────────────────────┐
│ tiles table                         │
│ WHERE module_code IN ["hr"]         │
│ Result: HR tiles only               │
└─────────────────────────────────────┘
```

**Reference**: See `database/authorization_flow_diagram.md` for detailed schema.

---

## Field Assignment Strategy

### Default: Full Access

When an authorization object is assigned to a role, **all fields default to `*` (full access)**.

```json
{
  "COMP_CODE": ["*"],
  "PLANT": ["*"],
  "DEPT": ["*"],
  "ACTVT": ["*"]
}
```

### Restrictions: Create Specialized Roles

Don't modify base role field values. Instead, create new roles with restrictions:

```
Base Role: Engineer
  └─ Full access to all fields (*)

Restricted Roles:
  ├─ Engineer_Plant_P001
  │   └─ PLANT: ["P001"] (only Plant P001)
  ├─ Engineer_ReadOnly
  │   └─ ACTVT: ["03"] (display only)
  └─ Engineer_North_Region
      └─ PLANT: ["P001", "P002"] (North region only)
```

### Field Value Sources

**Field Configuration** (from authorization_field_config):
- Defines available field types globally
- Specifies data source for each field type
- No tenant_id (shared across all tenants)

**Object-Field Mapping** (from authorization_object_fields):
- Links fields to specific authorization objects
- Defines which fields are required per object
- Tenant-specific assignments

**Field Value Assignment** (in role_authorization_objects.field_values):
- Actual restrictions per role
- Stored as JSONB
- Defaults to '*' (full access)

**Organizational Fields** (from database):
- `COMP_CODE` → `company_codes.company_code`
- `PLANT` → `plants.plant_code`
- `DEPT` → `departments.dept_code`
- `LGORT` → `storage_locations.sloc_code`
- `KOSTL` → `cost_centers.cost_center_code`

**Static Fields** (predefined):
- `ACTVT` → ['01', '02', '03', '06', '*']
- `PO_TYPE` → ['standard', 'blanket', 'contract', '*']
- `MAT_TYPE` → ['FERT', 'ROH', 'HALB', '*']

**API Endpoint**:
```
GET /api/authorization-objects/field-values?field_name=COMP_CODE
GET /api/authorization-objects/field-values?field_name=PLANT
GET /api/authorization-objects/field-values?field_name=ACTVT
```

**Reference**: See `docs/AUTHORIZATION_FIELD_STRATEGY.md` for complete strategy.

---

## API Endpoints

### 1. Authorization Objects API

**Base**: `/api/authorization-objects`

#### GET - Fetch all authorization data
```typescript
Response: {
  success: true,
  data: {
    objects: AuthObject[],      // With nested fields
    roleAuths: RoleAuth[],       // With role_name
    roles: Role[]
  }
}
```

**Tenant Isolation**: ✅ All queries filtered by `tenant_id`

#### POST - Create authorization object
```typescript
Body: {
  object_name: string,
  description: string,
  module: string,
  is_active: boolean
}
```

#### PUT - Update authorization object
```typescript
Body: {
  id: uuid,
  ...updates
}
```

#### DELETE - Delete authorization object
```typescript
Body: {
  id: uuid
}
```

### 2. Field Values API

**Base**: `/api/authorization-objects/field-values`

#### GET - Fetch field values
```typescript
Query: ?field_name=COMP_CODE

Response: {
  success: true,
  data: {
    fieldName: "COMP_CODE",
    values: [
      { value: "1000", label: "1000 - Company 1" },
      { value: "2000", label: "2000 - Company 2" },
      { value: "*", label: "* - All" }
    ],
    source: "database" | "static",
    table: "company_codes"
  }
}
```

**Tenant Isolation**: ✅ Organizational tables filtered by `tenant_id`

### 3. Tiles API

**Base**: `/api/tiles`

#### GET - Fetch user's authorized tiles
```typescript
Response: {
  success: true,
  tiles: Tile[]  // Filtered by get_user_modules() output
}
```

**Tenant Isolation**: ✅ RPC function inherently tenant-isolated

---

## Migration Guide

### SAP Code Elimination (Optional)

**Current State**: Uses SAP codes (AD, CF, MM, PS, FI, etc.)
**Target State**: Use friendly names (admin, configuration, materials, projects, finance)

**Migration Steps**:
1. Backup tiles table
2. Update tiles.module_code (SAP → friendly names)
3. Simplify get_user_modules() RPC (remove CASE mapping)
4. Update frontend (if hardcoded SAP codes exist)
5. Test authorization flow
6. Verify and cleanup

**Files**:
- `database/EXECUTION_GUIDE.md` - Complete migration guide
- `database/step1_backup_tiles.sql` - Backup script
- `database/step2_migrate_tiles_module_codes.sql` - Migration script
- `database/step3_simplify_rpc_function.sql` - RPC update
- `database/step6_rollback_if_needed.sql` - Rollback script

**Status**: ⏳ Optional - System works with both approaches

---

## Best Practices

### 1. Role Design
```
✅ DO: Create broad base roles with full access
✅ DO: Create specialized roles for restrictions
✅ DO: Use clear naming: [Function]_[Level]_[Restriction]
❌ DON'T: Modify base role field values
❌ DON'T: Create unnecessary restrictions upfront
```

### 2. Field Value Assignment
```
✅ DO: Start with full access (*) by default
✅ DO: Add restrictions only when business requires
✅ DO: Document why restrictions exist
❌ DON'T: Over-restrict without business justification
❌ DON'T: Mix organizational and activity restrictions in same role
```

### 3. Tenant Isolation
```
✅ DO: Always filter by tenant_id in queries
✅ DO: Use withAuth middleware for all APIs
✅ DO: Verify tenant_id in RPC functions
❌ DON'T: Trust client-provided tenant_id
❌ DON'T: Skip tenant checks for "admin" users
```

### 4. Module Management
```
✅ DO: Use lowercase friendly names (materials, projects)
✅ DO: Keep module names consistent across tables
✅ DO: Group related objects in same module
❌ DON'T: Mix SAP codes and friendly names
❌ DON'T: Create modules without authorization objects
```

### 5. Testing
```
✅ DO: Test with multiple tenants
✅ DO: Verify cross-tenant access prevention
✅ DO: Test role inheritance and restrictions
✅ DO: Validate field value sources
❌ DON'T: Test only with admin users
❌ DON'T: Skip tenant isolation verification
```

---

## Quick Reference

### Key Files

**Documentation**:
- `docs/AUTHORIZATION_FIELD_STRATEGY.md` - Field assignment strategy
- `docs/TENANT_ISOLATION_AUTHORIZATION.md` - Tenant isolation verification
- `database/authorization_flow_diagram.md` - Complete flow diagram
- `database/EXECUTION_GUIDE.md` - Migration guide

**Database Scripts**:
- `database/authorization_field_config.sql` - Field configuration table
- `database/migrate_restructure_authorization_fields.sql` - Junction table migration
- `database/get_user_modules_tenant_aware.sql` - Tenant-aware RPC function
- `database/verify_tenant_isolation_authorization.sql` - Verification queries
- `database/authorization_field_sources.sql` - Field value mappings
- `database/fix_module_names.sql` - Module standardization

**API Routes**:
- `app/api/authorization-objects/route.ts` - Main API
- `app/api/authorization-objects/field-values/route.ts` - Field values API
- `app/api/tiles/route.ts` - Tiles API (uses RPC)

**UI Components**:
- `components/features/administration/AuthorizationObjects.tsx` - Admin UI

### Key Concepts

| Concept | Description |
|---------|-------------|
| **Authorization Object** | Defines what can be accessed (e.g., MATERIAL_MASTER_READ) |
| **Field Configuration** | Global catalog of available field types (authorization_field_config) |
| **Object-Field Mapping** | Links objects to fields via junction table (authorization_object_fields) |
| **Authorization Field** | Defines access dimension (e.g., COMP_CODE, PLANT, ACTVT) |
| **Role Assignment** | Links role to object with field values |
| **Module** | Groups related objects (e.g., materials, projects) |
| **Tenant Isolation** | Ensures data separation between tenants |
| **Full Access** | All fields = '*' (default) |
| **Field Restriction** | Specific values per field (specialized roles) |

### Common Queries

**Get available field types**:
```sql
SELECT field_code, field_name, field_category, data_source_type
FROM authorization_field_config
WHERE is_active = true
ORDER BY display_order;
```

**Get fields for an authorization object**:
```sql
SELECT aof.field_code, afc.field_name, aof.is_required
FROM authorization_object_fields aof
JOIN authorization_field_config afc ON aof.field_code = afc.field_code
WHERE aof.auth_object_id = 'object-uuid'
  AND aof.tenant_id = 'tenant-uuid';
```

**Get user's modules**:
```sql
SELECT * FROM get_user_modules('user-uuid');
```

**Get role's assignments**:
```sql
SELECT ao.object_name, rao.field_values
FROM role_authorization_objects rao
JOIN authorization_objects ao ON rao.auth_object_id = ao.id
WHERE rao.role_id = 'role-uuid'
  AND rao.tenant_id = 'tenant-uuid';
```

**Get field values for COMP_CODE**:
```sql
SELECT company_code, company_name
FROM company_codes
WHERE tenant_id = 'tenant-uuid'
  AND is_active = true;
```

**Verify tenant isolation**:
```sql
-- Should return 0
SELECT COUNT(*) FROM role_authorization_objects rao
JOIN roles r ON rao.role_id = r.id
WHERE rao.tenant_id != r.tenant_id;
```

---

## Status Summary

| Component | Status | Notes |
|-----------|--------|-------|
| **Database Schema** | ✅ Production | All tables have tenant_id |
| **Tenant Isolation** | ✅ Verified | 0 cross-tenant mismatches |
| **RPC Function** | ✅ Deployed | Explicit tenant checks |
| **API Endpoints** | ✅ Production | All tenant-filtered |
| **Field Values** | ✅ Production | Dynamic from org tables |
| **UI Components** | ✅ Production | Shows assignments correctly |
| **Documentation** | ✅ Complete | All reference docs updated |
| **SAP Code Migration** | ⏳ Optional | Can be done anytime |

---

## Support

For issues or questions:
1. Check relevant documentation in `docs/` folder
2. Review database scripts in `database/` folder
3. Verify tenant isolation with verification queries
4. Check API logs for tenant_id filtering

**Last Verified**: 2024
**Verification Status**: ✅ All systems operational, tenant-isolated
