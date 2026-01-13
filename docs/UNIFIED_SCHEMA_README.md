# Construction Management SaaS - Unified Database Schema

## Overview
This document describes the unified database schema that consolidates all fragmented schema files into a single source of truth for the construction management system.

## Schema Consolidation Summary

### Before Consolidation
- **200+ fragmented SQL files** in the database folder
- **Multiple versions** of the same table definitions
- **Inconsistent structures** across different migration scripts
- **No authoritative reference** for current database state

### After Consolidation
- **Single unified schema file**: `unified_schema.sql`
- **Comprehensive documentation** with comments
- **Logical organization** by functional areas
- **Complete indexes and triggers** for performance

## Schema Structure

### 1. Organizational Structure (SAP-Style)
```sql
company_codes              -- Legal entities (C001, C002, etc.)
purchasing_organizations   -- Procurement organizations
plants                    -- Project sites/locations
storage_locations         -- Warehouse locations
cost_centers             -- Cost center master data
```

### 2. User Management & Security
```sql
roles                     -- System roles (Admin, Manager, etc.)
users                     -- User master data
user_roles               -- Many-to-many user-role assignments
authorization_objects    -- SAP-style authorization objects
authorization_fields     -- Fields for each auth object
role_authorization_objects -- Role-based auth assignments
tiles                    -- Fiori-style UI tiles
```

### 3. Project Management
```sql
projects                 -- Construction projects
wbs_nodes               -- Work Breakdown Structure
activities              -- Schedulable work units
tasks                   -- Progress tracking items
activity_dependencies  -- Project dependencies
```

### 4. Financial Management
```sql
chart_of_accounts       -- Multi-company COA
financial_documents     -- Document headers
journal_entries         -- GL postings
```

### 5. Procurement & Vendor Management
```sql
vendors                 -- Vendor master data
subcontractors         -- Subcontractor extensions
purchase_orders        -- PO headers
po_lines              -- PO line items
```

### 6. Inventory Management
```sql
stores                 -- Warehouses/stores
stock_items           -- Material master
stock_balances        -- Current stock levels
goods_receipts        -- GRN headers
grn_lines            -- GRN line items
stock_movements      -- All inventory transactions
```

### 7. Time Management
```sql
timesheets           -- Timesheet headers
timesheet_entries    -- Individual time entries
```

### 8. Costing & BOQ
```sql
cost_objects         -- Cost tracking objects
actual_costs         -- Actual cost postings
boq_categories       -- BOQ category hierarchy
boq_items           -- Bill of quantities items
```

## Key Features

### 1. Multi-Company Support
- **Company codes** for legal entity separation
- **Currency support** per company
- **Organizational hierarchy** (Company → Plant → Storage Location)

### 2. SAP-Style Authorization
- **Authorization objects** with field-level control
- **Role-based assignments** instead of user-based
- **Organizational restrictions** (company, plant, etc.)

### 3. Complete Audit Trail
- **Created/updated timestamps** on all master data
- **User tracking** for all transactions
- **Reference tracking** across documents

### 4. Performance Optimization
- **Strategic indexes** on all foreign keys
- **Composite indexes** for common queries
- **Generated columns** for calculated fields

### 5. Data Integrity
- **Foreign key constraints** for referential integrity
- **Unique constraints** for business keys
- **Check constraints** for data validation
- **Triggers** for automatic updates

## Migration Strategy

### Phase 1: Schema Deployment
1. **Backup existing data** from current database
2. **Deploy unified schema** to new environment
3. **Verify table structures** match requirements

### Phase 2: Data Migration
1. **Extract data** from existing tables
2. **Transform data** to match new structure
3. **Load data** with proper relationships

### Phase 3: Application Updates
1. **Update API endpoints** to use new schema
2. **Modify UI components** for new table structures
3. **Test all functionality** end-to-end

### Phase 4: Cleanup
1. **Archive old schema files** for reference
2. **Delete fragmented files** after verification
3. **Update documentation** and README

## Database Views

### project_line_items
SAP CJI3 equivalent for project cost analysis:
```sql
SELECT project_code, cost_element_code, amount, posting_date
FROM project_line_items
WHERE project_code = 'PROJ-001';
```

### user_authorization_summary
Complete user authorization overview:
```sql
SELECT user_id, role_name, object_name, field_values
FROM user_authorization_summary
WHERE email = 'admin@nttdemo.com';
```

## Functions

### check_user_authorization()
Validates user permissions for specific operations:
```sql
SELECT check_user_authorization(
    user_id, 
    'F_PROJ_CRE', 
    '{"ACTVT": "01", "BUKRS": "C001"}'::jsonb
);
```

## Triggers

### Automatic Updates
- **update_updated_at_column()**: Updates timestamps on record changes
- **update_po_received_quantity()**: Updates PO quantities on GRN posting
- **update_stock_balance()**: Maintains stock balances on movements

## Next Steps

1. **Review the unified schema** for completeness
2. **Test schema deployment** in development environment
3. **Plan data migration** from existing fragmented structure
4. **Update application code** to use new schema
5. **Clean up old files** after successful migration

## Files to Archive/Delete

After successful migration, these fragmented files can be archived:
- All `check_*.sql` files (verification scripts)
- All `fix_*.sql` files (patch scripts)
- All `debug_*.sql` files (troubleshooting scripts)
- All `add_*.sql` files (incremental additions)
- All `update_*.sql` files (modification scripts)

## Maintenance

### Regular Tasks
- **Monitor index performance** and add new indexes as needed
- **Review authorization objects** for new requirements
- **Update documentation** when schema changes
- **Backup schema** before major modifications

### Schema Versioning
- **Version control** all schema changes
- **Document breaking changes** in release notes
- **Maintain migration scripts** for version upgrades
- **Test rollback procedures** for emergency recovery