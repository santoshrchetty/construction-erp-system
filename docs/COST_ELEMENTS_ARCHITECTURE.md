# Cost Elements and Cost Accounting Architecture

## Overview

Implementation of SAP-style Cost Accounting (CO) module with separate Cost Elements master table, following SAP FI-CO separation model.

**Status**: ✅ SCHEMA COMPLETE - Ready for migration

---

## Architecture: FI-CO Separation

### Financial Accounting (FI) vs Cost Accounting (CO)

**SAP Standard Model:**
```
Financial Accounting (FI)          Cost Accounting (CO)
├── GL Accounts (SKA1)            ├── Cost Elements (CSKB)
├── External reporting            ├── Internal management
├── Compliance focus              ├── Profitability focus
└── Legal requirements            └── Decision support
```

**Our Implementation:**
```
universal_journal
├── gl_account      → Financial view (FI)
└── cost_element    → Controlling view (CO)
```

---

## Cost Elements Master Table

### Schema

```sql
CREATE TABLE cost_elements (
    cost_element VARCHAR(20) UNIQUE NOT NULL,
    cost_element_name VARCHAR(100) NOT NULL,
    
    -- Classification
    cost_element_category VARCHAR(20),  -- PRIMARY_DIRECT, PRIMARY_INDIRECT, SECONDARY
    cost_element_type VARCHAR(20),      -- MATERIAL, LABOR, EQUIPMENT, SUBCONTRACTOR, OVERHEAD
    
    -- Attributes
    is_direct_cost BOOLEAN,
    is_primary_cost BOOLEAN,
    is_secondary_cost BOOLEAN,
    
    -- GL Integration
    gl_account VARCHAR(20),             -- NULL for secondary cost elements
    
    -- Allocation
    allocation_allowed BOOLEAN,
    default_allocation_basis VARCHAR(30) -- LABOR_HOURS, MACHINE_HOURS, etc.
);
```

### Cost Element Categories

**1. PRIMARY_DIRECT** (1:1 with GL Accounts)
- Direct costs traceable to specific activities
- Examples: Direct materials, Direct labor, Equipment, Subcontractors
- Posting: Activity-level (activity_code populated)

**2. PRIMARY_INDIRECT** (1:1 with GL Accounts)
- Indirect costs not directly traceable to activities
- Examples: Site overhead, Project management, Admin costs
- Posting: WBS-level (activity_code NULL)

**3. SECONDARY** (CO-only, no GL Account)
- Internal allocations and settlements
- Examples: Overhead allocation, Internal orders, Settlements
- Posting: CO module only (gl_account NULL)

### Cost Element Types

| Type | Description | Examples |
|------|-------------|----------|
| MATERIAL | Material costs | Cement, Steel, Electrical materials |
| LABOR | Labor costs | Skilled labor, Unskilled labor, Overtime |
| EQUIPMENT | Equipment costs | Rental, Fuel, Maintenance |
| SUBCONTRACTOR | Subcontractor costs | Civil, MEP, Finishing subcontractors |
| OVERHEAD | Overhead costs | Site office, Utilities, Insurance |
| ALLOCATION | Internal allocations | Overhead distribution |
| SETTLEMENT | Cost settlements | WBS settlement, Internal order settlement |
| INTERNAL_ORDER | Internal activities | Activity-based costing |

---

## Universal Journal Integration

### Enhanced Schema

```sql
ALTER TABLE universal_journal 
ADD COLUMN activity_code VARCHAR(50);    -- Execution-level tracking
ADD COLUMN cost_element VARCHAR(20);     -- Cost accounting view
```

### Dual-Level Cost Tracking

**WBS Level** (Budget Control)
```
wbs_element = 'HW-0001.01'
```

**Activity Level** (Execution Tracking)
```
activity_code = 'HW-0001.01-A01'
```

### Posting Patterns

**Pattern 1: Primary Direct Cost (Activity-Level)**
```sql
INSERT INTO universal_journal (
    gl_account,        -- '500000' (Financial view)
    cost_element,      -- '500000' (Cost view, 1:1 mapping)
    wbs_element,       -- 'HW-0001.01' (Budget control)
    activity_code,     -- 'HW-0001.01-A01' (Execution tracking)
    project_code,      -- 'HW-0001' (Reporting)
    cost_center,       -- 'CC-SITE-01' (Responsibility)
    company_amount,
    debit_credit
);
```

**Pattern 2: Primary Indirect Cost (WBS-Level)**
```sql
INSERT INTO universal_journal (
    gl_account,        -- '600000'
    cost_element,      -- '600000'
    wbs_element,       -- 'HW-0001.01'
    activity_code,     -- NULL (no specific activity)
    project_code,      -- 'HW-0001'
    cost_center,       -- 'CC-SITE-01'
    company_amount,
    debit_credit
);
```

**Pattern 3: Secondary Cost (Allocation, CO-only)**
```sql
INSERT INTO universal_journal (
    gl_account,        -- NULL (no financial posting)
    cost_element,      -- '900000' (Allocation cost element)
    wbs_element,       -- 'HW-0001.01'
    activity_code,     -- 'HW-0001.01-A01'
    project_code,      -- 'HW-0001'
    cost_center,       -- 'CC-SITE-01'
    company_amount,
    debit_credit
);
```

---

## Cost Accountant Reports

### 1. Direct vs Indirect Cost Report

```sql
SELECT 
    uj.project_code,
    ce.is_direct_cost,
    ce.cost_element_type,
    SUM(uj.company_amount) as total_cost
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
GROUP BY uj.project_code, ce.is_direct_cost, ce.cost_element_type
ORDER BY ce.is_direct_cost DESC, total_cost DESC;
```

**Output:**
```
Project    | Direct | Type          | Total Cost
-----------|--------|---------------|------------
HW-0001    | true   | MATERIAL      | 275,000
HW-0001    | true   | SUBCONTRACTOR | 150,000
HW-0001    | true   | LABOR         | 73,000
HW-0001    | true   | EQUIPMENT     | 32,000
HW-0001    | false  | OVERHEAD      | 23,000
```

### 2. Cost Element Category Breakdown

```sql
SELECT 
    ce.cost_element_category,
    COUNT(DISTINCT uj.cost_element) as element_count,
    SUM(uj.company_amount) as total_cost
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
GROUP BY ce.cost_element_category;
```

### 3. Activity-Level Cost Report

```sql
SELECT 
    uj.activity_code,
    ce.cost_element_type,
    SUM(uj.company_amount) as actual_cost
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
  AND uj.activity_code IS NOT NULL
GROUP BY uj.activity_code, ce.cost_element_type
ORDER BY uj.activity_code, actual_cost DESC;
```

### 4. WBS-Level Budget vs Actual

```sql
SELECT 
    uj.wbs_element,
    ce.is_direct_cost,
    SUM(uj.company_amount) as actual_cost
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
GROUP BY uj.wbs_element, ce.is_direct_cost;
```

### 5. Allocation Report (Secondary Costs)

```sql
SELECT 
    uj.activity_code,
    ce.cost_element_name,
    ce.default_allocation_basis,
    SUM(uj.company_amount) as allocated_amount
FROM universal_journal uj
JOIN cost_elements ce ON uj.cost_element = ce.cost_element
WHERE uj.project_code = 'HW-0001'
  AND ce.is_secondary_cost = true
GROUP BY uj.activity_code, ce.cost_element_name, ce.default_allocation_basis;
```

---

## Service Layer Integration

### Updated Query Pattern

**Before (GL Account Ranges):**
```typescript
.eq('wbs_element', activityCode)
.gte('gl_account', '500000')
.lte('gl_account', '599999')
```

**After (Cost Element Join):**
```typescript
.select('company_amount, cost_elements!inner(cost_element_type)')
.eq('activity_code', activityCode)
.eq('cost_elements.cost_element_type', 'MATERIAL')
```

**Benefits:**
- ✅ Cleaner queries (no GL range logic)
- ✅ Type-safe (cost_element_type enum)
- ✅ Supports secondary costs
- ✅ Better performance (indexed joins)

---

## Migration Files

### 1. Cost Elements Schema
**File:** `database/cost-elements-schema.sql`
- Creates cost_elements table
- Inserts primary direct cost elements (500000-539999)
- Inserts primary indirect cost elements (600000-699999)
- Inserts secondary cost elements (900000-920000)

### 2. Universal Journal Enhancement
**File:** `database/enhance-universal-journal-for-costing.sql`
- Adds activity_code column
- Adds cost_element column
- Creates indexes
- Adds trigger to auto-sync cost_element from gl_account

### 3. Sample Data
**File:** `database/insert-hw0001-universal-journal-data.sql`
- Sample postings for HW-0001 project
- Demonstrates all 3 posting patterns
- Includes primary and secondary costs

---

## Benefits of This Architecture

### 1. SAP Standard Alignment
- Mirrors SAP FI-CO separation
- Familiar to SAP-trained accountants
- Easier migration to/from SAP

### 2. Flexibility
- Support for secondary costs (allocations)
- Activity-based costing ready
- Variance analysis framework

### 3. Reporting Power
- Direct vs Indirect classification
- Cost element type breakdown
- Activity-level cost tracking
- Allocation transparency

### 4. Clean Separation
- Financial view (gl_account) for compliance
- Cost view (cost_element) for management
- No mixing of concerns

### 5. Future-Proof
- Supports advanced cost accounting
- Allocation and settlement ready
- Internal order processing capable

---

## Next Steps

1. ✅ Run migration: `cost-elements-schema.sql`
2. ✅ Run migration: `enhance-universal-journal-for-costing.sql`
3. ✅ Run sample data: `insert-hw0001-universal-journal-data.sql`
4. ✅ Update service layer: `resourcePlanning.service.ts` (COMPLETE)
5. ✅ Update documentation: `RESOURCE_PLANNING_ARCHITECTURE.md` (COMPLETE)
6. ⏳ Test cost reports with sample data
7. ⏳ Create cost allocation logic
8. ⏳ Build cost accountant dashboard
9. ⏳ Implement variance analysis UI
10. ⏳ Add budget vs actual comparison

---

## Key Insights

- **Cost Elements ≠ GL Accounts** (separate tables, different purposes)
- **Primary Cost Elements = GL Accounts** (1:1 mapping, same number)
- **Secondary Cost Elements** have no GL account (CO-only)
- **activity_code** enables execution-level cost tracking
- **wbs_element** enables budget-level cost control
- **cost_element_type** replaces GL account range logic
- **Direct vs Indirect** determined by cost element attributes, not GL ranges
