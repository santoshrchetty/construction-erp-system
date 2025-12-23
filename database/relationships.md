# Database Relationship Diagram

## Core Entity Relationships

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

TASKS (1) ──┬── (M) TASK_DEPENDENCIES (predecessor/successor)
            ├── (M) TIMESHEET_ENTRIES
            ├── (M) COST_OBJECTS
            └── (M) ACTUAL_COSTS

VENDORS (1) ──┬── (1) SUBCONTRACTORS
              ├── (M) PURCHASE_ORDERS
              └── (M) GOODS_RECEIPTS

PURCHASE_ORDERS (1) ──┬── (M) PO_LINES
                      └── (M) GOODS_RECEIPTS

PO_LINES (1) ──── (M) GRN_LINES

STORES (1) ──┬── (M) GOODS_RECEIPTS
             ├── (M) STOCK_BALANCES
             └── (M) STOCK_MOVEMENTS

STOCK_ITEMS (1) ──┬── (M) STOCK_BALANCES
                  └── (M) STOCK_MOVEMENTS

COST_OBJECTS (1) ──┬── (M) TIMESHEET_ENTRIES
                   └── (M) ACTUAL_COSTS
```

## Key Mapping: WBS → Activities → Tasks → Cost Objects

### Hierarchical Structure:
1. **Projects** contain multiple **WBS Nodes** (Work Breakdown Structure)
2. **WBS Nodes** can have child **WBS Nodes** (hierarchical tree)
3. **WBS Nodes** contain multiple **Activities** 
4. **Activities** contain multiple **Tasks**
5. **Cost Objects** can be linked to any level: WBS Node, Activity, or Task

### Cost Tracking Flow:
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

## Procurement to Inventory Flow

### Purchase Order Process:
```
BOQ_ITEMS → RFQ → QUOTATIONS → PURCHASE_ORDERS → PO_LINES
                                      ↓
GOODS_RECEIPTS → GRN_LINES → STOCK_MOVEMENTS → STOCK_BALANCES
```

### Material Flow:
1. **BOQ Items** define material requirements
2. **Purchase Orders** created for procurement
3. **Goods Receipts** record material delivery
4. **Stock Movements** track inventory changes
5. **Stock Balances** maintain current inventory levels

## Timesheet to Costing Integration

### Time Tracking Flow:
```
TIMESHEETS → TIMESHEET_ENTRIES → ACTUAL_COSTS
     ↓              ↓                ↓
  (User)      (Task/Activity)   (Cost Object)
```

### Cost Allocation:
- **Timesheet Entries** link to Tasks, Activities, or Cost Objects
- **Actual Costs** automatically generated from approved timesheets
- **Cost Objects** aggregate costs from multiple sources

## Foreign Key Relationships

### Primary Relationships:
- `wbs_nodes.project_id` → `projects.id`
- `wbs_nodes.parent_id` → `wbs_nodes.id` (self-referencing)
- `activities.wbs_node_id` → `wbs_nodes.id`
- `tasks.activity_id` → `activities.id`
- `cost_objects.task_id` → `tasks.id`

### Cross-Module Relationships:
- `boq_items.wbs_node_id` → `wbs_nodes.id`
- `po_lines.boq_item_id` → `boq_items.id`
- `timesheet_entries.task_id` → `tasks.id`
- `actual_costs.cost_object_id` → `cost_objects.id`

### Reference Relationships:
- `stock_movements.reference_id` → Various tables (GRN, Issues, etc.)
- `actual_costs.reference_id` → Various tables (Timesheets, POs, etc.)

## Indexes for Performance

### Hierarchical Queries:
- `idx_wbs_nodes_parent_id` - For WBS tree traversal
- `idx_activities_wbs_node_id` - For activity lookups
- `idx_tasks_activity_id` - For task queries

### Cost Aggregation:
- `idx_actual_costs_cost_object_id` - For cost rollups
- `idx_timesheet_entries_cost_object_id` - For time cost calculations

### Inventory Tracking:
- `idx_stock_movements_store_item` - For inventory queries
- `idx_stock_balances` (unique constraint) - For current stock levels