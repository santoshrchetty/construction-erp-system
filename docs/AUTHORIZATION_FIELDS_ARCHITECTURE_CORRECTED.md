# Authorization Fields Architecture - CORRECTED

## Problem Statement
We initially thought `authorization_fields` was redundant, but it's actually needed as a **junction table** to link authorization objects to field configurations.

## Correct Three-Table Architecture

### 1. authorization_field_config (Global Catalog - No tenant_id)
**Purpose**: Defines all available field types and their data sources

```sql
authorization_field_config (
  id uuid,
  field_code varchar(50) UNIQUE,     -- e.g., 'COMP_CODE', 'PLANT'
  field_name varchar(100),           -- Display name
  field_category varchar(50),        -- Activity/Organizational/Business
  data_source_type varchar(50),      -- static/table/enum
  source_table varchar(100),         -- Where to fetch values
  source_value_column varchar(100),
  source_display_column varchar(100),
  static_values jsonb,
  is_active boolean
)
```

**Example Data**:
- COMP_CODE → fetches from company_codes table
- PLANT → fetches from plants table  
- ACTVT → static values [01, 02, 03, 06]

### 2. authorization_object_fields (Junction Table - Has tenant_id)
**Purpose**: Links authorization objects to fields (which fields does each object have?)

```sql
authorization_object_fields (
  id uuid,
  auth_object_id uuid,               -- Which authorization object
  field_code varchar(50),            -- Which field from config
  is_required boolean,               -- Is this field required?
  tenant_id uuid
)
```

**Example Data**:
- MATERIAL_MASTER_READ has fields: COMP_CODE, PLANT, ACTVT
- PROJECT_CREATE has fields: COMP_CODE, PROJ_TYPE, ACTVT

### 3. role_authorization_objects (Assignment Table - Has tenant_id)
**Purpose**: Assigns objects to roles with actual field value restrictions

```sql
role_authorization_objects (
  id uuid,
  role_id uuid,
  auth_object_id uuid,
  field_values jsonb,                -- Actual restrictions
  module_full_access boolean,
  object_full_access boolean,
  tenant_id uuid
)
```

**Example Data**:
```json
{
  "COMP_CODE": ["1000", "2000"],
  "PLANT": ["P001"],
  "ACTVT": ["01", "02", "03"]
}
```

## Data Flow

```
1. Admin adds new field type
   → INSERT INTO authorization_field_config (SUPPLIER, ...)

2. Admin assigns field to auth object
   → INSERT INTO authorization_object_fields (MATERIAL_MASTER_READ, SUPPLIER, ...)

3. Admin assigns object to role with restrictions
   → INSERT INTO role_authorization_objects (..., field_values: {"SUPPLIER": ["SUP001"]})

4. User tries to access material
   → Check role_authorization_objects.field_values
   → Validate against user's supplier
```

## Migration Steps

1. **Keep authorization_fields table** (don't drop it!)
2. **Rename** to `authorization_object_fields` for clarity
3. **Remove redundant columns**:
   - field_description (now in config)
   - field_values (now in config)
   - is_organizational (now field_category in config)
4. **Rename field_name to field_code** to match config table
5. **Update API** to use new table name

## Benefits

1. **Separation of concerns**:
   - Config table = WHAT fields exist
   - Junction table = WHICH fields each object has
   - Assignment table = VALUES for each role

2. **Flexibility**:
   - Add new field types without code changes
   - Reuse fields across multiple objects
   - Different objects can have different required fields

3. **Tenant isolation**:
   - Config is global (no tenant_id)
   - Junction and assignments are tenant-specific

## API Changes Needed

1. **Keep** `/api/authorization-objects/fields` endpoint
2. **Update** to reference `authorization_object_fields` table
3. **Update** to use `field_code` instead of `field_name`
4. **Fetch** field definitions from `authorization_field_config` for UI dropdown
