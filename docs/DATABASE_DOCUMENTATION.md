# Construction Management Database - Complete Documentation

## Table of Contents
1. [Schema Overview](#schema-overview)
2. [Database Relationships](#database-relationships)
3. [Activities Table Structure](#activities-table-structure)
4. [Industry Standards Alignment](#industry-standards-alignment)
5. [Setup Instructions](#setup-instructions)
6. [Architecture](#architecture)
7. [Key Features](#key-features)
8. [Usage Examples](#usage-examples)
9. [Migration Guide](#migration-guide)
10. [Maintenance](#maintenance)

---

## Schema Overview

### Version: 2.0 (Unified Schema)
**File**: `unified_schema.sql`
**Last Updated**: 2024
**Description**: Complete database schema for construction management system with SAP-style organizational structure and RBAC

### Database Structure (8 Major Sections)

1. **Organizational Structure (SAP-Style)** - Company codes, plants, storage locations, profit centers
2. **User Management & Security** - Users, roles, authorization objects  
3. **Project Management** - Projects, WBS, activities, tasks
4. **Financial Management** - Chart of accounts, journal entries, movement mappings
5. **Procurement** - Vendors, purchase orders, receipts
6. **Inventory** - Stock items, balances, movements
7. **Time Management** - Timesheets and entries
8. **Costing & BOQ** - Cost objects, BOQ items

### Key Statistics
- **65+ tables** properly organized and documented
- **50+ indexes** for optimal performance
- **15+ triggers** for automatic updates
- **Multiple views** for reporting (project_line_items, user_authorization_summary)
- **Authorization functions** for SAP-style security
- **Complete foreign key relationships** for data integrity

---

## Database Relationships

### Core Entity Relationships

```
PROJECTS (1) ──┬── (M) WBS_NODES
               ├── (M) ACTIVITIES  
               ├── (M) TASKS
               ├── (M) COST_OBJECTS
               ├── (M) BOQ_ITEMS
               ├── (M) TIMESHEETS
               ├── (M) PURCHASE_ORDERS
               ├── (M) GOODS_RECEIPTS
               ├── (M) STORES
               └── (M) ACTUAL_COSTS

WBS_NODES (1) ──┬── (M) WBS_NODES (self-referencing)
                ├── (M) ACTIVITIES
                ├── (M) BOQ_ITEMS
                └── (M) COST_OBJECTS

ACTIVITIES (1) ──┬── (M) TASKS
                 ├── (M) TIMESHEET_ENTRIES
                 └── (M) COST_OBJECTS

VENDORS (1) ──┬── (1) SUBCONTRACTORS
              ├── (M) PURCHASE_ORDERS
              └── (M) GOODS_RECEIPTS

PURCHASE_ORDERS (1) ──┬── (M) PO_LINES
                      └── (M) GOODS_RECEIPTS

STORES (1) ──┬── (M) GOODS_RECEIPTS
             ├── (M) STOCK_BALANCES
             └── (M) STOCK_MOVEMENTS

STOCK_ITEMS (1) ──┬── (M) STOCK_BALANCES
                  └── (M) STOCK_MOVEMENTS

COST_OBJECTS (1) ──┬── (M) TIMESHEET_ENTRIES
                   └── (M) ACTUAL_COSTS
```

### Hierarchical Structure
1. **Projects** contain multiple **WBS Nodes** (Work Breakdown Structure)
2. **WBS Nodes** can have child **WBS Nodes** (hierarchical tree)
3. **WBS Nodes** contain multiple **Activities** 
4. **Activities** contain multiple **Tasks**
5. **Cost Objects** can be linked to any level: WBS Node, Activity, or Task

### Cost Tracking Flow
```
PROJECT
├── WBS_NODE (Phase 1)
│   ├── ACTIVITY (Foundation Work)
│   │   ├── TASK (Excavation)
│   │   │   └── COST_OBJECT (Labor + Equipment)
│   │   └── TASK (Concrete Pour)
│   │       └── COST_OBJECT (Material + Labor)
│   └── ACTIVITY (Structural Work)
│       ├── TASK (Steel Fixing)
│       └── TASK (Concrete Work)
└── WBS_NODE (Phase 2)
    └── ACTIVITY (Finishing Work)
```

### Procurement to Inventory Flow
```
BOQ_ITEMS → RFQ → QUOTATIONS → PURCHASE_ORDERS → PO_LINES
                                      ↓
GOODS_RECEIPTS → GRN_LINES → STOCK_MOVEMENTS → STOCK_BALANCES
```

### Timesheet to Costing Integration
```
TIMESHEETS → TIMESHEET_ENTRIES → ACTUAL_COSTS
     ↓              ↓                ↓
  (User)      (Task/Activity)   (Cost Object)
```

---

## Activities Table Structure

### Overview
The activities table is the core scheduling entity in the construction management system. Activities drive the project schedule and contain all cost, resource, and dependency information.

### Complete Field List

#### Core Fields
- `id` - UUID primary key
- `project_id` - UUID reference to projects
- `wbs_node_id` - UUID reference to WBS nodes
- `code` - Unique activity code (auto-generated)
- `name` - Activity name
- `description` - Activity description
- `planned_start_date` - Planned start date
- `planned_end_date` - Planned end date
- `actual_start_date` - Actual start date
- `actual_end_date` - Actual end date
- `planned_hours` - Original planned hours field
- `budget_amount` - Original budget amount
- `responsible_user_id` - Responsible user
- `vendor_id` - Vendor reference (with proper FK constraint)
- `is_active` - Active flag
- `created_at` - Creation timestamp
- `updated_at` - Update timestamp

#### Scheduling Fields
- `duration_days` - Duration in working days
- `progress_percentage` - Progress (0-100%)
- `status` - Activity status (not_started, in_progress, on_hold, completed, cancelled)
- `priority` - Priority (low, medium, high, critical)
- `predecessor_activities` - Array of predecessor activity IDs
- `dependency_type` - Default dependency type
- `lag_days` - Default lag days

#### Activity Type Fields
- `activity_type` - ENUM: INTERNAL, EXTERNAL, SERVICE
- `rate` - Rate (for EXTERNAL)
- `quantity` - Quantity (for EXTERNAL)
- `requires_po` - Whether PO is required

#### Direct Cost Fields
- `direct_labor_cost` - Direct labor costs
- `direct_material_cost` - Direct material costs
- `direct_equipment_cost` - Direct equipment costs
- `direct_subcontract_cost` - Direct subcontractor costs
- `direct_expense_cost` - Direct expense costs

### Activity Types Explained

#### INTERNAL Activities
- Work performed by internal team
- Cost flows from timesheets → `direct_labor_cost`

#### EXTERNAL Activities
- Work performed by vendors/subcontractors
- Uses: `vendor_id`, `rate`, `quantity`, `requires_po`
- Cost flows from PO → GRN → Invoice → `direct_subcontract_cost`

#### SERVICE Activities
- Complex services with multiple line items
- Uses: `vendor_id`, `requires_po`
- Cost flows from service line items → `direct_subcontract_cost`

---

## Industry Standards Alignment

### Primavera P6 Model Alignment

| System | Scheduling Unit | Dependencies | Tasks Purpose |
|--------|----------------|--------------|---------------|
| **Primavera P6** | Activities | Activities | Progress/Checklist |
| **Our System** | Activities | Activities | Progress/Checklist |
| **MS Project** | Tasks | Tasks | Scheduling |

### Tasks (Aligned with Primavera)
**Purpose**: Progress tracking and checklist items within activities

**Removed Fields** (No longer schedulable):
- `planned_start_date`, `planned_end_date`
- `actual_start_date`, `actual_end_date` 
- `planned_hours`, `actual_hours`

**Kept Fields** (Progress tracking):
- `name`, `description`, `status`, `priority`
- `progress_percentage`, `assigned_to`
- `checklist_item` (for quality control)

### Activities (Primary Scheduling Unit)
**Purpose**: Schedulable work items with dependencies (like Primavera)

**Enhanced Fields**:
- `duration_days` (scheduling)
- `predecessor_activities[]` (dependencies)
- `dependency_type`, `lag_days`
- All cost tracking fields

### Dependencies
- **Removed**: `task_dependencies` table
- **Added**: `activity_dependencies` table
- **Types**: finish_to_start, start_to_start, finish_to_finish, start_to_finish

### Usage Pattern
```
Project
├── WBS Node (Foundation)
│   ├── Activity (Excavation) ──┐
│   │   ├── Task (Mark boundaries) ✓    │ Dependencies
│   │   └── Task (Safety check) ✓       │ at Activity
│   └── Activity (Concrete Pour) ←──────┘ Level Only
│       ├── Task (Mix concrete) ✓
│       └── Task (Quality test) ✓
```

### Benefits
1. **Industry Standard**: Matches Primavera P6 model
2. **Simplified**: No complex task dependencies
3. **Clear Separation**: Activities = scheduling, Tasks = progress
4. **Better Performance**: Fewer dependency calculations
5. **Easier Integration**: Compatible with other PM tools

---

## Setup Instructions

### 1. Install Dependencies
```bash
npm install
```

### 2. Set up Supabase
1. Create a new Supabase project at https://supabase.com
2. Run the database schema from `database/unified_schema.sql` in your Supabase SQL editor
3. Copy your project URL and API keys

### 3. Environment Variables
```bash
cp .env.example .env.local
```

Fill in your Supabase credentials:
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

### 4. Generate Types (Optional)
If you make schema changes, regenerate types:
```bash
npx supabase gen types typescript --project-id YOUR_PROJECT_ID > types/supabase/database.types.ts
```

---

## Architecture

### Database Schema
- **Projects**: Central project management
- **WBS Nodes**: Hierarchical work breakdown structure
- **Activities**: Work groupings under WBS nodes with scheduling
- **Tasks**: Granular work items for progress tracking
- **Vendors**: Supplier management
- **Purchase Orders**: Procurement tracking
- **Stores**: Inventory management
- **Timesheets**: Time tracking and approvals
- **Profit Centers**: Profitability analysis
- **Controlling Areas**: Cost management structure

### Type System
- **Supabase Types**: Auto-generated from database schema
- **Zod Schemas**: Runtime validation and type inference
- **Repository Pattern**: Business logic and data access layer

### Key Features
- **Multi-company support** (C001, C002, etc.)
- **SAP-style organizational structure**
- **Complete RBAC with authorization objects**
- **Hierarchical WBS structure**
- **Activity dependency management**
- **Purchase order lifecycle**
- **Inventory tracking**
- **Time tracking with approvals**
- **Cost management integration**
- **Profit center analysis**

---

## Usage Examples

### Basic Repository Usage
```typescript
import { repositories } from './lib/repositories'

// Create a project
const project = await repositories.projects.create({
  name: 'New Project',
  code: 'PROJ-001',
  project_type: 'commercial',
  start_date: '2024-01-01',
  planned_end_date: '2024-12-31',
  budget: 1000000
})

// Find active projects
const activeProjects = await repositories.projects.findActiveProjects()

// Create WBS structure
const wbsNode = await repositories.wbs.create({
  project_id: project.id,
  code: 'WBS-01',
  name: 'Phase 1',
  node_type: 'phase',
  level: 1,
  sequence_order: 1
})
```

### Type-Safe Operations
```typescript
import { CreateProjectSchema } from './types'

// Validate input
const projectData = CreateProjectSchema.parse({
  name: 'Test Project',
  code: 'TEST-001',
  // ... other fields
})

// Create with validated data
const project = await repositories.projects.create(projectData)
```

### Creating Activities
```sql
-- INTERNAL Activity
INSERT INTO activities (
    project_id, wbs_node_id, code, name, activity_type,
    duration_days, planned_hours, responsible_user_id
) VALUES (
    'project-uuid', 'wbs-uuid', 'AIR-24-01.01-A01', 'Site Preparation',
    'INTERNAL', 5, 40, 'user-uuid'
);

-- EXTERNAL Activity
INSERT INTO activities (
    project_id, wbs_node_id, code, name, activity_type,
    duration_days, vendor_id, quantity, rate, requires_po
) VALUES (
    'project-uuid', 'wbs-uuid', 'AIR-24-01.01-A02', 'Concrete Supply',
    'EXTERNAL', 3, 'vendor-uuid', 100.00, 250.00, true
);
```

---

## Migration Guide

### Schema Consolidation Summary

#### Before Consolidation
- **200+ fragmented SQL files** in the database folder
- **Multiple versions** of the same table definitions
- **Inconsistent structures** across different migration scripts
- **No authoritative reference** for current database state

#### After Consolidation
- **Single unified schema file**: `unified_schema.sql`
- **Comprehensive documentation** with comments
- **Logical organization** by functional areas
- **Complete indexes and triggers** for performance

### Migration Strategy

#### Phase 1: Schema Deployment
1. **Backup existing data** from current database
2. **Deploy unified schema** to new environment
3. **Verify table structures** match requirements

#### Phase 2: Data Migration
1. **Extract data** from existing tables
2. **Transform data** to match new structure
3. **Load data** with proper relationships

#### Phase 3: Application Updates
1. **Update API endpoints** to use new schema
2. **Modify UI components** for new table structures
3. **Test all functionality** end-to-end

#### Phase 4: Cleanup
1. **Archive old schema files** for reference
2. **Delete fragmented files** after verification
3. **Update documentation** and README

### Files Archived
After successful migration, these fragmented files were archived:
- All `check_*.sql` files (verification scripts)
- All `fix_*.sql` files (patch scripts)
- All `debug_*.sql` files (troubleshooting scripts)
- All `add_*.sql` files (incremental additions)
- All `update_*.sql` files (modification scripts)

---

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

### Database Views

#### project_line_items
SAP CJI3 equivalent for project cost analysis:
```sql
SELECT project_code, cost_element_code, amount, posting_date, profit_center
FROM project_line_items
WHERE project_code = 'PROJ-001';
```

#### user_authorization_summary
Complete user authorization overview:
```sql
SELECT user_id, role_name, object_name, field_values
FROM user_authorization_summary
WHERE email = 'admin@nttdemo.com';
```

### Functions

#### check_user_authorization()
Validates user permissions for specific operations:
```sql
SELECT check_user_authorization(
    user_id, 
    'F_PROJ_CRE', 
    '{"ACTVT": "01", "BUKRS": "C001"}'::jsonb
);
```

### Triggers

#### Automatic Updates
- **update_updated_at_column()**: Updates timestamps on record changes
- **update_po_received_quantity()**: Updates PO quantities on GRN posting
- **update_stock_balance()**: Maintains stock balances on movements
- **update_profit_centers_updated_at()**: Updates profit center timestamps

---

## File Structure
```
database/
├── unified_schema.sql              # Complete unified database schema (SINGLE SOURCE OF TRUTH)
├── DATABASE_DOCUMENTATION.md       # This comprehensive documentation file
├── construction_erd.drawio         # Visual ERD diagram
├── relationships.md                # Database relationships (archived content)
└── archive/                        # Archived fragmented files (323+ files)
    ├── unified_schema_fixes.sql    # Applied fixes (archived)
    ├── activities_table_complete_structure.md
    ├── README_Industry_Alignment.md
    └── [323+ other archived SQL files]
```

---

## Summary

This construction management database provides:

- **Complete SAP-style organizational structure** with multi-company support
- **Industry-standard project management** aligned with Primavera P6
- **Comprehensive RBAC system** with authorization objects
- **Full procurement and inventory management** with automatic GL posting
- **Integrated time tracking and costing** with profit center analysis
- **Production-ready schema** with proper indexes, triggers, and constraints

The unified schema serves as the **single source of truth** for all database operations, replacing 200+ fragmented files with one authoritative structure.

**Version**: 2.0  
**Status**: Production Ready  
**Last Updated**: 2024