# Tenant Architecture Reference

## Overview
Multi-tenant architecture implementation for Construction ERP system with complete data isolation.

## Multi-Tenant User Model

### Architecture Decision
**Users table changed from single-tenant to multi-tenant model:**
- One user record per tenant (not one record per user)
- Composite unique key: `(email, tenant_id)`
- Same email can exist across multiple tenants with different user IDs
- Dropped `user_tenants` junction table (redundant)

### User Table Structure
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR NOT NULL,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    role_id UUID REFERENCES roles(id),
    first_name VARCHAR,
    last_name VARCHAR,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(email, tenant_id)  -- Allows same email across tenants
);
```

### Authentication Flow
1. User authenticates via Supabase Auth (single auth.users record)
2. User selects tenant at login
3. Query users table by `email` AND `tenant_id`
4. Fetch tenant-specific user record with role and permissions
5. Set tenant session cookie
6. Middleware validates tenant access on each request

### Key Changes
- **Removed**: Foreign key constraint from `users.id` to `auth.users.id`
- **Removed**: Unique constraint on `users.email`
- **Added**: Composite unique constraint on `(email, tenant_id)`
- **Dropped**: `user_tenants` table

### Migration Scripts
- `migrate_users_multi_tenant.sql` - Converts users table to multi-tenant
- `fix_auth_objects_tenant_specific.sql` - Makes authorization objects tenant-specific

## Authorization System

### Tenant-Specific Authorization Objects
```sql
CREATE TABLE authorization_objects (
    id UUID PRIMARY KEY,
    object_name VARCHAR NOT NULL,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    module VARCHAR,
    UNIQUE(object_name, tenant_id)  -- Same object name per tenant
);
```

### Role-Based Access Control
- Roles are tenant-specific (role.tenant_id must match user.tenant_id)
- Authorization objects are tenant-specific
- Role-authorization mappings include tenant_id for validation

## Database Schema Changes

### Tenant ID Column Addition
All business tables now include `tenant_id VARCHAR REFERENCES tenants(id)` column:

#### Core Business Tables (82 tables)
- account_assignment_categories, account_assignment_config, account_determination, account_keys
- activities, activity_dependencies, activity_equipment, activity_manpower, activity_materials, activity_services, activity_subcontractors
- actual_costs, approval_actions, approval_delegations, approval_document_types, approval_executions
- approval_field_definitions, approval_field_options, approval_instances, approval_level_templates
- approval_object_registry, approval_object_types, approval_policies, approval_steps
- authorization_audit_log, authorization_fields, authorization_objects
- boq_categories, boq_items, capital_goods_itc_tracking
- chart_of_accounts, company_codes, company_controlling_areas, company_groups
- controlling_areas, cost_centers, cost_elements, cost_objects, cost_transactions
- customer_approval_configuration, customer_material_request_config
- daily_timesheets, demand_headers, demand_lines, departments
- document_number_ranges, document_type_config, document_types
- employee_hierarchy, employee_rates, employees, equipment
- financial_documents, fiscal_year_variants, fixed_assets, flexible_approval_levels
- functional_approver_assignments, fx_rates
- gl_account_authorization, gl_accounts, gl_determination_rules
- goods_receipts, grn_lines, internal_orders, journal_entries
- material_categories, material_groups, material_movements, material_plant_data
- material_price_history, material_pricing, material_request_items, material_requests
- material_status, material_storage_data, material_types, materials
- mobile_ui_config, movement_type_account_keys, movement_type_account_mappings, movement_types
- mrp_shortage_analysis, num_range_usg_hist
- number_range_alerts, number_range_audit_log, number_range_buffer, number_range_groups
- org_hierarchy, organizational_hierarchy, payment_terms, permissions, persons_responsible

### Implementation Status
- ✅ Migration script created: `add_tenant_id_columns.sql`
- ✅ All core business tables identified
- ⚠️ Migration incomplete (persons_responsible table statement truncated)

## Tenant Schema Design

### Core Tenant Table
```sql
CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  -- Hidden from users
    tenant_code VARCHAR(20) UNIQUE NOT NULL,         -- "001", "002" - user sees this
    tenant_name VARCHAR(100) NOT NULL,               -- "ACME Corp" - display name
    ...
);
```

### UUID Visibility Strategy

**Users NEVER see**: `550e8400-e29b-41d4-a716-446655440000`

**Users see**: 
- `tenant_code = "001"`
- `tenant_name = "ACME Corp"`

**System Behavior**:
- **Internal**: All foreign keys use UUID for relationships
- **User Interface**: Always resolves UUID to show tenant_code/tenant_name
- **APIs**: Accept tenant_code, internally convert to UUID
- **URLs**: `/tenant/001/dashboard` (using tenant_code)
- **Reports**: Show "001 - ACME Corp"

**Benefits**:
- Users work with familiar "001", "002" codes
- System gets UUID benefits (security, uniqueness)
- No user confusion with long UUID strings
- UUID purely for internal database relationships

## Data Isolation Strategy
- **Row-Level Security**: Each tenant's data isolated by tenant_id
- **Foreign Key Constraints**: All tenant_id columns reference tenants(id)
- **Query Filtering**: All queries must include tenant context

## Next Steps
1. ✅ Complete migration script
2. ✅ Implement multi-tenant user model
3. ✅ Make authorization objects tenant-specific
4. ✅ Update authentication flow for tenant selection
5. ✅ Fix middleware to query by email + tenant_id
6. Add indexes on tenant_id columns
7. Implement RLS policies
8. Update application queries