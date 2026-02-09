# MR Account Assignment Types - NOT Always Project-Driven

## Key Concept: MRs Can Have Different Account Assignments

Material Requests are **NOT always project-driven**. They can be assigned to different cost objects based on the business need.

---

## Account Assignment Categories

### **1. Project/WBS (Category = P) - 60-70%**
**Most common in construction, but NOT the only type**

**Examples:**
- Materials for Highway Project (P-001)
- Steel for Bridge Construction (WBS: W-001-CIVIL)
- Cement for Building Foundation (Activity: A-100)

**Schema:**
```sql
account_assignment_category = 'P'
project_code = 'P-001'
wbs_element = 'W-001-CIVIL'
activity_code = 'A-100'
```

---

### **2. Cost Center (Category = K) - 20-25%**
**Non-project overhead costs**

**Examples:**
- Office supplies for Head Office
- Maintenance materials for equipment workshop
- Safety equipment for general use
- Fuel for company vehicles (not project-specific)
- IT equipment for admin department

**Schema:**
```sql
account_assignment_category = 'K'
cost_center = 'CC-ADMIN'  -- or CC-MAINT, CC-SAFETY, etc.
gl_account = '520100'     -- Expense account
```

**Real Scenario:**
```
MR-2024-001
Requestor: Admin Manager
Items:
  - Line 1: Office Stationery → Cost Center: CC-ADMIN
  - Line 2: Printer Toner → Cost Center: CC-ADMIN
  - Line 3: Coffee Supplies → Cost Center: CC-ADMIN
```

---

### **3. Asset (Category = A) - 5-10%**
**Capital expenditure - purchasing fixed assets**

**Examples:**
- New excavator purchase
- Tower crane acquisition
- Office building renovation
- Computer servers
- Company vehicles

**Schema:**
```sql
account_assignment_category = 'A'
asset_number = 'A-001'
gl_account = '150000'  -- Fixed Asset account
```

**Real Scenario:**
```
MR-2024-002
Requestor: Equipment Manager
Items:
  - Line 1: Excavator CAT 320D → Asset: A-EXC-001
  - Line 2: Spare Parts for Excavator → Asset: A-EXC-001
```

---

### **4. Internal Order (Category = O) - 3-5%**
**Temporary cost collectors (not projects)**

**Examples:**
- Marketing campaign materials
- Training program supplies
- R&D activities
- Company events
- Temporary initiatives

**Schema:**
```sql
account_assignment_category = 'O'
order_number = 'IO-2024-001'
gl_account = '540000'
```

**Real Scenario:**
```
MR-2024-003
Requestor: HR Manager
Items:
  - Line 1: Training Materials → Internal Order: IO-TRAIN-2024
  - Line 2: Catering for Training → Internal Order: IO-TRAIN-2024
```

---

### **5. Stock/Inventory (Category = blank or 'S') - 5-10%**
**Warehouse stock replenishment (no immediate assignment)**

**Examples:**
- General stock items
- Fast-moving materials
- Buffer stock
- Trading goods

**Schema:**
```sql
account_assignment_category = NULL or 'S'
storage_location = 'WH-01'
gl_account = '140000'  -- Inventory account
-- No project/cost center needed at MR stage
-- Assignment happens at goods issue
```

**Real Scenario:**
```
MR-2024-004
Requestor: Store Keeper
Items:
  - Line 1: Cement (500 bags) → Stock Replenishment
  - Line 2: Steel Bars (10 tons) → Stock Replenishment
  - Line 3: Paint (100 liters) → Stock Replenishment
```

---

## Distribution by Type (Construction Industry)

| Account Assignment | % of MRs | Typical Requestor | Example |
|-------------------|----------|-------------------|---------|
| **Project (P)** | 60-70% | Site Engineer | Materials for Highway Project |
| **Cost Center (K)** | 20-25% | Admin/Maintenance | Office supplies, maintenance |
| **Stock (S)** | 5-10% | Store Keeper | Warehouse replenishment |
| **Asset (A)** | 3-5% | Equipment Manager | New equipment purchase |
| **Internal Order (O)** | 2-3% | Various | Training, events, campaigns |

---

## Mixed MRs (Multiple Account Assignments)

**A single MR can have DIFFERENT account assignments per line item!**

### **Example: Mixed MR**
```
MR-2024-005
Requestor: Site Engineer
Header: No default assignment

Line Items:
  Line 1: Cement (100 bags)
    → Project: P-001, WBS: W-CIVIL (Category = P)
  
  Line 2: Office Supplies
    → Cost Center: CC-SITE-OFFICE (Category = K)
  
  Line 3: Safety Helmets
    → Cost Center: CC-SAFETY (Category = K)
  
  Line 4: Excavator Spare Parts
    → Asset: A-EXC-001 (Category = A)
```

**This is why account assignment MUST be at line item level, not header!**

---

## Schema Design Impact

### **WRONG: Header-Level Assignment**
```sql
-- ❌ This forces ALL lines to same assignment
CREATE TABLE material_requests (
  project_code VARCHAR(20),  -- Forces all lines to one project
  cost_center VARCHAR(20)    -- Can't mix with project
);
```

### **CORRECT: Line-Level Assignment**
```sql
-- ✅ Each line can have different assignment
CREATE TABLE material_request_items (
  account_assignment_category VARCHAR(1),  -- K/P/A/O/S
  project_code VARCHAR(24),
  wbs_element VARCHAR(24),
  cost_center VARCHAR(10),
  asset_number VARCHAR(12),
  order_number VARCHAR(12)
);
```

---

## Validation Rules

### **Rule 1: Category Determines Required Fields**
```sql
IF account_assignment_category = 'P' THEN
  wbs_element IS REQUIRED
ELSIF account_assignment_category = 'K' THEN
  cost_center IS REQUIRED
ELSIF account_assignment_category = 'A' THEN
  asset_number IS REQUIRED
ELSIF account_assignment_category = 'O' THEN
  order_number IS REQUIRED
END IF
```

### **Rule 2: Project Code is Optional**
```sql
-- project_code is NOT mandatory
-- wbs_element is sufficient for project assignment
-- project_code is for reference/grouping only
```

---

## Real-World Scenarios

### **Scenario 1: Pure Project MR (70% of cases)**
```
Site Engineer needs materials for Highway Project
→ All lines assigned to Project P-001
→ account_assignment_category = 'P'
```

### **Scenario 2: Pure Cost Center MR (20% of cases)**
```
Admin Manager needs office supplies
→ All lines assigned to Cost Center CC-ADMIN
→ account_assignment_category = 'K'
```

### **Scenario 3: Mixed MR (10% of cases)**
```
Site Engineer needs:
  - Project materials → Project P-001 (Category = P)
  - Office supplies → Cost Center CC-SITE (Category = K)
  - Safety gear → Cost Center CC-SAFETY (Category = K)
```

### **Scenario 4: Stock Replenishment (5-10% of cases)**
```
Store Keeper replenishes warehouse
→ No account assignment at MR stage
→ Assignment happens when materials are issued to projects/cost centers
```

### **Scenario 5: Asset Purchase (3-5% of cases)**
```
Equipment Manager buys new excavator
→ Assigned to Asset A-EXC-001
→ account_assignment_category = 'A'
→ Capitalized, not expensed
```

---

## Financial Posting Impact

### **Project (P)**
```
DR: Work in Progress (WIP) - Project P-001
CR: Inventory / Vendor
```

### **Cost Center (K)**
```
DR: Expense Account - Cost Center CC-ADMIN
CR: Inventory / Vendor
```

### **Asset (A)**
```
DR: Fixed Asset - Asset A-001
CR: Vendor
```

### **Stock (S)**
```
DR: Inventory
CR: Vendor
(No cost center/project assignment yet)
```

---

## UI Design Implications

### **MR Form - Line Item Section**
```
For each line item:
1. Material Code [Required]
2. Quantity [Required]
3. Account Assignment Category [Required Dropdown]
   - P = Project/WBS
   - K = Cost Center
   - A = Asset
   - O = Internal Order
   - S = Stock

4. IF Category = P:
   Show: Project Code, WBS Element, Activity Code
   
5. IF Category = K:
   Show: Cost Center
   
6. IF Category = A:
   Show: Asset Number
   
7. IF Category = O:
   Show: Internal Order Number
   
8. IF Category = S:
   Show: Storage Location only
```

---

## Summary

### **Key Takeaways:**

1. ❌ **MRs are NOT always project-driven**
2. ✅ **MRs can be assigned to:**
   - Projects (P) - 60-70%
   - Cost Centers (K) - 20-25%
   - Assets (A) - 3-5%
   - Internal Orders (O) - 2-3%
   - Stock (S) - 5-10%

3. ✅ **A single MR can have MIXED assignments** (different per line)
4. ✅ **Account assignment MUST be at line item level**
5. ✅ **project_code is optional** - not all MRs need it

---

## Status: ✅ CLARIFIED

**Impact**: Schema design must support all account assignment types, not just projects.
