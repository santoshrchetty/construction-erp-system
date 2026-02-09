# Who Creates Purchase Requisitions (PR)?

## Clear Separation of Roles

```
┌─────────────────────────────────────────────────────────────┐
│  SITE USERS (Engineers, Foremen)                            │
│  Create: Material Request (MR)                              │
│  "I need materials"                                         │
└─────────────────────────────────────────────────────────────┘
                          ↓
                    MR Approved
                          ↓
                  Stock Check (System)
                          ↓
                    Not in Stock
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  PROCUREMENT TEAM (Buyers, Procurement Officers)            │
│  Create: Purchase Requisition (PR)                          │
│  "Let's buy this from vendors"                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Who Creates PR?

### **Primary: Procurement/Purchasing Team**

**Roles:**
- Procurement Officer
- Purchasing Manager
- Buyer
- Materials Manager
- Supply Chain Coordinator

**Why Procurement Creates PR:**
1. **Vendor Knowledge** - Know which vendors to use
2. **Pricing Expertise** - Can negotiate prices
3. **Terms & Conditions** - Understand payment terms, delivery terms
4. **Compliance** - Ensure purchasing policies followed
5. **Consolidation** - Can combine multiple MRs into one PR/PO

---

## Two PR Creation Methods

### **Method 1: Manual PR Creation (10% of cases)**

**Scenario:** Procurement creates PR directly (no MR)

**When:**
- Planned bulk purchases
- Contract renewals
- Strategic sourcing
- Long-term agreements

**Example:**
```
Procurement Manager creates PR directly:
- Annual cement contract renewal
- Bulk steel order for Q1
- Equipment maintenance contract
```

**Process:**
```
Procurement Team → Create PR → Convert to PO → Send to Vendor
```

---

### **Method 2: Convert MR to PR (90% of cases)**

**Scenario:** Procurement converts approved MR to PR

**When:**
- Materials not in stock
- Site requests need purchasing
- Ad-hoc requirements

**Example:**
```
Site Engineer creates MR-2024-001
→ Project Manager approves
→ System checks stock: Not available
→ Procurement receives notification
→ Procurement Officer converts MR → PR
→ PR-2024-001 created (linked to MR-2024-001)
```

**Process:**
```
Site User → MR → Approval → Stock Check → Procurement → PR → PO
```

---

## MR to PR Conversion Flow

### **Step-by-Step Process**

```
┌─────────────────────────────────────────────────────────────┐
│  STEP 1: MR Created & Approved                              │
├─────────────────────────────────────────────────────────────┤
│  MR-2024-001                                                │
│  Requested by: Site Engineer (John)                         │
│  Status: APPROVED                                           │
│  Items:                                                     │
│    Line 1: Cement OPC 43 - 100 bags                        │
│    Line 2: Steel TMT 16mm - 5 tons                         │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 2: System Checks Stock                                │
├─────────────────────────────────────────────────────────────┤
│  Line 1: Cement - 0 bags available ❌ (Need to purchase)   │
│  Line 2: Steel - 0 tons available ❌ (Need to purchase)    │
│                                                             │
│  Action: Create PR requirement                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 3: Procurement Notified                               │
├─────────────────────────────────────────────────────────────┤
│  Notification to: Procurement Team                          │
│  Message: "MR-2024-001 requires purchasing"                 │
│  Items to purchase: 2 items                                 │
│                                                             │
│  [View MR] [Convert to PR]                                  │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 4: Procurement Reviews MR                             │
├─────────────────────────────────────────────────────────────┤
│  Procurement Officer: Sarah                                 │
│  Reviews:                                                   │
│    ✓ Material specifications                               │
│    ✓ Quantities                                            │
│    ✓ Required dates                                        │
│    ✓ Account assignments (Project, WBS)                    │
│    ✓ Budget availability                                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 5: Procurement Creates PR (Auto or Manual)            │
├─────────────────────────────────────────────────────────────┤
│  Option A: Click "Auto-Convert to PR" (Recommended)        │
│    → System copies all data from MR to PR                   │
│    → Procurement adds vendor details                        │
│                                                             │
│  Option B: Manual PR creation                               │
│    → Procurement manually enters data                       │
│    → Links to MR manually                                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  STEP 6: PR Created                                         │
├─────────────────────────────────────────────────────────────┤
│  PR-2024-001                                                │
│  Created by: Procurement Officer (Sarah)                    │
│  Source: MR-2024-001                                        │
│  Status: OPEN                                               │
│                                                             │
│  Items (copied from MR + enriched):                         │
│    Line 1: Cement OPC 43 - 100 bags                        │
│      Source: MR-2024-001, Line 1                           │
│      Preferred Vendor: ABC Suppliers                        │
│      Estimated Price: $10/bag                               │
│      Delivery Plant: PLANT-01                               │
│                                                             │
│    Line 2: Steel TMT 16mm - 5 tons                         │
│      Source: MR-2024-001, Line 2                           │
│      Preferred Vendor: XYZ Steel                            │
│      Estimated Price: $500/ton                              │
│      Delivery Plant: PLANT-01                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Flow: MR → PR

### **What Gets Copied from MR to PR?**

```sql
-- Auto-copy from MR line items to PR items
INSERT INTO pr_items (
  pr_header_id,
  line_number,
  
  -- Material Info (from MR)
  material_code,
  material_description,
  quantity,
  uom,
  
  -- Organizational Data (from MR)
  delivery_plant,
  storage_location,
  
  -- Account Assignment (from MR)
  account_assignment_category,
  project_code,
  wbs_element,
  activity_code,
  cost_center,
  gl_account,
  
  -- Dates (from MR)
  required_date,
  
  -- Pricing (from Material Master or MR estimate)
  estimated_price,
  currency,
  
  -- Tracking
  source_mr_id,
  source_mr_line_number,
  
  -- Quantities for tracking
  pr_quantity,
  open_quantity
)
SELECT
  @new_pr_id,
  mri.line_number,
  
  mri.material_code,
  mri.description,
  mri.quantity,
  mri.unit,
  
  mri.plant_code,
  mri.storage_location,
  
  mri.account_assignment_category,
  mri.project_code,
  mri.wbs_element,
  mri.activity_code,
  mri.cost_center,
  mri.gl_account,
  
  mr.required_date,
  
  mri.estimated_unit_cost,
  mr.currency_code,
  
  mri.material_request_id,
  mri.line_number,
  
  mri.quantity,
  mri.quantity
FROM material_request_items mri
JOIN material_requests mr ON mri.material_request_id = mr.id
WHERE mr.id = @source_mr_id
  AND mri.fulfillment_type IN ('PURCHASE', 'MIXED');
```

### **What Procurement Adds to PR?**

```javascript
// Procurement enriches PR with purchasing data
const prEnrichment = {
  // Vendor Selection
  preferred_vendor_code: 'V-001',
  alternative_vendor_1: 'V-002',
  alternative_vendor_2: 'V-003',
  
  // Purchasing Org Data
  purchasing_org: 'PO01',
  purchase_group: 'PG1',
  
  // Pricing (if not from MR)
  estimated_price: 10.50,
  price_unit: 1,
  
  // Delivery Terms
  delivery_date: '2024-02-20',
  incoterms: 'FOB',
  
  // Notes
  purchasing_notes: 'Urgent delivery required'
};
```

---

## PR Creation Permissions

### **Role-Based Access**

```typescript
// Who can create PR
const PR_CREATOR_ROLES = [
  'PROCUREMENT_OFFICER',
  'PURCHASING_MANAGER',
  'BUYER',
  'MATERIALS_MANAGER',
  'SUPPLY_CHAIN_COORDINATOR'
];

// Who CANNOT create PR
const NO_PR_ACCESS = [
  'SITE_ENGINEER',      // Can only create MR
  'PROJECT_MANAGER',    // Can only approve MR
  'FOREMAN',            // Can only create MR
  'STORE_KEEPER'        // Can only create MR
];
```

---

## Procurement Workflow

### **Daily Procurement Tasks**

```
Morning:
1. Check pending MRs requiring purchase
2. Review stock availability reports
3. Consolidate similar requirements

Midday:
4. Convert approved MRs to PRs
5. Add vendor details to PRs
6. Get quotations if needed

Afternoon:
7. Convert PRs to POs
8. Send POs to vendors
9. Track deliveries
```

---

## Auto-Conversion vs Manual PR Creation

### **Option 1: Auto-Conversion (Recommended - 90%)**

**Process:**
```
Procurement clicks "Convert MR to PR"
→ System auto-creates PR
→ Copies all MR data
→ Procurement adds vendor details
→ Done in 2 minutes
```

**Advantages:**
- Fast (2 minutes)
- No data entry errors
- Maintains traceability
- Auto-links MR ↔ PR

---

### **Option 2: Manual PR Creation (10%)**

**Process:**
```
Procurement creates PR from scratch
→ Manually enters all data
→ Manually links to MR (optional)
→ Takes 10-15 minutes
```

**When to use:**
- Consolidating multiple MRs
- Strategic purchases
- Contract-based orders
- No MR exists

---

## PR Approval Workflow

### **After PR Created**

```
PR Created (Status: DRAFT)
    ↓
Procurement Manager Reviews
    ↓
Approved (Status: APPROVED)
    ↓
Convert to PO
    ↓
Send to Vendor
```

**Approval Levels:**
- < $10,000: Procurement Officer (auto-approve)
- $10,000 - $50,000: Procurement Manager
- > $50,000: Finance Manager + Procurement Manager

---

## UI Design: Procurement Dashboard

### **Pending MRs Requiring Purchase**

```
┌─────────────────────────────────────────────────────────────┐
│  MATERIAL REQUESTS REQUIRING PURCHASE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  MR-2024-001  |  Highway Project  |  2 items  |  Urgent   │
│  Requested: 2024-01-20  |  Need by: Tomorrow               │
│  [View Details]  [Convert to PR]                           │
│                                                             │
│  MR-2024-003  |  Bridge Project   |  5 items  |  Normal   │
│  Requested: 2024-01-19  |  Need by: Next Week              │
│  [View Details]  [Convert to PR]                           │
│                                                             │
│  MR-2024-005  |  Office Building  |  1 item   |  Normal   │
│  Requested: 2024-01-18  |  Need by: 2024-02-01             │
│  [View Details]  [Convert to PR]                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### **Convert MR to PR Screen**

```
┌─────────────────────────────────────────────────────────────┐
│  CONVERT MR-2024-001 TO PURCHASE REQUISITION                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Source MR: MR-2024-001                                     │
│  Project: Highway Project P-001                             │
│  Requested by: John (Site Engineer)                         │
│  Required Date: Tomorrow                                    │
│                                                             │
│  Items to Purchase:                                         │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ 1. Cement OPC 43 - 100 bags                          │ │
│  │    Account: Project P-001, WBS W-001                 │ │
│  │    Preferred Vendor: [ABC Suppliers ▼]              │ │
│  │    Est. Price: [$10.00] per bag                      │ │
│  │                                                       │ │
│  │ 2. Steel TMT 16mm - 5 tons                           │ │
│  │    Account: Project P-001, WBS W-001                 │ │
│  │    Preferred Vendor: [XYZ Steel ▼]                   │ │
│  │    Est. Price: [$500.00] per ton                     │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  Purchasing Org: [PO01 ▼]                                  │
│  Purchase Group: [PG1 ▼]                                   │
│                                                             │
│  Notes: [Urgent delivery required...]                      │
│                                                             │
│  [Cancel]  [Create PR]                                      │
└─────────────────────────────────────────────────────────────┘
```

---

## Summary

### **Who Creates PR:**

**Primary (90%):** Procurement Team
- Converts approved MRs to PRs
- Adds vendor details
- Manages purchasing process

**Secondary (10%):** Procurement Team
- Creates PR directly (no MR)
- For planned/strategic purchases

### **Site Users:**
- ❌ Cannot create PR
- ✅ Can only create MR
- ✅ Can view PR status (linked to their MR)

### **Key Points:**
1. **MR = Site request** ("I need materials")
2. **PR = Procurement document** ("Let's buy from vendor X")
3. **Procurement converts MR → PR** (auto-copy data)
4. **All org data & account assignments flow from MR to PR**
5. **Procurement adds vendor & purchasing details**

---

## Status: ✅ CLARIFIED

**PR is created by Procurement Team, not site users!**
