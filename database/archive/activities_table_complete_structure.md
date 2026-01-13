# Complete Activities Table Structure

## Overview
The activities table is the core scheduling entity in the construction management system. Activities drive the project schedule and contain all cost, resource, and dependency information.

## Complete Field List

### Core Fields (from original schema.sql)
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
- `is_active` - Active flag
- `created_at` - Creation timestamp
- `updated_at` - Update timestamp

### Scheduling Fields (from restructure_activities_tasks.sql)
- `duration_days` - Duration in working days
- `progress_percentage` - Progress (0-100%)
- `status` - Activity status (not_started, in_progress, on_hold, completed, cancelled)
- `priority` - Priority (low, medium, high, critical)
- `assigned_resources` - Array of resource IDs
- `predecessor_activities` - Array of predecessor activity IDs
- `dependency_type` - Default dependency type
- `lag_days` - Default lag days

### Activity Type Fields (from add_activity_types.sql)
- `activity_type` - ENUM: INTERNAL, EXTERNAL, SERVICE
- `cost_rate` - Cost rate per hour (for INTERNAL)
- `assigned_internal_team` - Array of team member IDs (for INTERNAL)
- `vendor_id` - Vendor reference (for EXTERNAL/SERVICE)
- `rate` - Rate (for EXTERNAL)
- `quantity` - Quantity (for EXTERNAL)
- `requires_po` - Whether PO is required

### Direct Cost Fields (from add_direct_indirect_costs.sql)
- `direct_labor_cost` - Direct labor costs
- `direct_material_cost` - Direct material costs
- `direct_equipment_cost` - Direct equipment costs
- `direct_subcontract_cost` - Direct subcontractor costs
- `direct_expense_cost` - Direct expense costs
- `direct_cost_total` - Computed total (GENERATED ALWAYS AS)

## Activity Types Explained

### INTERNAL Activities
- Work performed by internal team
- Uses: `assigned_internal_team`, `cost_rate`, `planned_hours`
- Cost flows from timesheets → `direct_labor_cost`

### EXTERNAL Activities
- Work performed by vendors/subcontractors
- Uses: `vendor_id`, `rate`, `quantity`, `requires_po`
- Cost flows from PO → GRN → Invoice → `direct_subcontract_cost`

### SERVICE Activities
- Complex services with multiple line items
- Uses: `vendor_id`, `requires_po`
- Has related `service_lines` table with BOQ breakdown
- Cost flows from service line items → `direct_subcontract_cost`

## Related Tables

### service_lines
- `id` - UUID primary key
- `activity_id` - Reference to activities
- `line_description` - Service line description
- `quantity` - Quantity
- `uom` - Unit of measurement
- `rate` - Rate per unit
- `amount` - Computed amount (quantity * rate)
- `actual_quantity` - Actual quantity completed
- `actual_amount` - Actual cost posted

### activity_dependencies
- `id` - UUID primary key
- `predecessor_activity_id` - Predecessor activity
- `successor_activity_id` - Successor activity
- `dependency_type` - Dependency type (finish_to_start, etc.)
- `lag_days` - Lag days

## Usage Examples

### Creating INTERNAL Activity
```sql
INSERT INTO activities (
    project_id, wbs_node_id, code, name, activity_type,
    duration_days, planned_hours, cost_rate, assigned_internal_team
) VALUES (
    'project-uuid', 'wbs-uuid', 'AIR-24-01.01-A01', 'Site Preparation',
    'INTERNAL', 5, 40, 75.00, '{user1-uuid, user2-uuid}'
);
```

### Creating EXTERNAL Activity
```sql
INSERT INTO activities (
    project_id, wbs_node_id, code, name, activity_type,
    duration_days, vendor_id, quantity, rate, requires_po
) VALUES (
    'project-uuid', 'wbs-uuid', 'AIR-24-01.01-A02', 'Concrete Supply',
    'EXTERNAL', 3, 'vendor-uuid', 100.00, 250.00, true
);
```

### Creating SERVICE Activity with Lines
```sql
-- Create the activity
INSERT INTO activities (
    project_id, wbs_node_id, code, name, activity_type,
    duration_days, vendor_id, requires_po
) VALUES (
    'project-uuid', 'wbs-uuid', 'AIR-24-01.01-A03', 'Electrical Installation',
    'SERVICE', 10, 'vendor-uuid', true
);

-- Add service lines
INSERT INTO service_lines (activity_id, line_description, quantity, uom, rate) VALUES
('activity-uuid', 'Cable laying per meter', 500, 'lm', 15.00),
('activity-uuid', 'Switch installation', 20, 'nos', 125.00),
('activity-uuid', 'Panel installation', 2, 'nos', 2500.00);
```

## Migration Notes
- Run `complete_activities_schema.sql` to add all missing fields
- Existing activities will get default values for new fields
- All changes are backward compatible
- Use the migration script to update existing data safely