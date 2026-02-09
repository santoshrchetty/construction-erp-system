# Account Assignment Mapping - MR/PR/PO

## Current State Analysis

### Existing Account Assignment Fields

#### **MR Header (material_requests)**
```sql
-- CURRENTLY AT HEADER LEVEL (INCORRECT)
company_code VARCHAR(10)
plant_code VARCHAR(10)
cost_center VARCHAR(20)
project_code VARCHAR(20)
wbs_element VARCHAR(50)
activity_code VARCHAR(31)
storage_location VARCHAR(31)
```

#### **MR Items (material_request_items)**
```sql
-- MISSING ACCOUNT ASSIGNMENT FIELDS
material_request_id UUID
line_number INTEGER
material_code VARCHAR(50)
quantity DECIMAL(12,3)
unit VARCHAR(20)
-- ❌ NO account assignment fields
```

#### **PR Items (pr_items)**
```sql
-- PARTIAL ACCOUNT ASSIGNMENT (CORRECT LOCATION)
project_code VARCHAR(24)      ✅
wbs_element VARCHAR(24)       ✅
activity_code VARCHAR(12)     ✅
cost_center VARCHAR(10)       ✅
delivery_plant VARCHAR(4)     ✅
-- ❌ MISSING: account_assignment_category, gl_account, asset_number, storage_location
```

#### **PO Items (po_lines or purchase_order_items)**
```sql
-- FROM poServices.ts interface:
account_assignment_category   ✅
account_assignment_object     ✅
-- ❌ MISSING: Individual fields (cost_center, project_code, wbs_element, etc.)
```

---

## Account Assignment Categories

| Code | Name | Object Field | Master Table |
|------|------|--------------|--------------|
| **K** | Cost Center | cost_center | cost_centers |
| **P** | Project/WBS | wbs_element | wbs_nodes |
| **A** | Asset | asset_number | fixed_assets |
| **O** | Internal Order | order_number | internal_orders |
| **N** | Network | network_number | networks |

---

## Required Fields at Line Item Level

### **Standard Fields (All Line Items)**
```sql
-- Organizational Units
plant_code VARCHAR(10)
storage_location VARCHAR(10)
delivery_date DATE

-- Account Assignment
account_assignment_category VARCHAR(1)  -- K/P/A/O/N
gl_account VARCHAR(10)                  -- G/L Account for posting

-- Cost Center Assignment (Category = K)
cost_center VARCHAR(10)

-- Project Assignment (Category = P)
project_code VARCHAR(24)
wbs_element VARCHAR(24)
activity_code VARCHAR(12)

-- Asset Assignment (Category = A)
asset_number VARCHAR(12)
asset_subnumber VARCHAR(4)

-- Internal Order Assignment (Category = O)
order_number VARCHAR(12)

-- Network Assignment (Category = N)
network_number VARCHAR(12)
network_activity VARCHAR(4)
```

---

## Migration Plan

### **Step 1: Add Missing Fields to MR Items**
```sql
ALTER TABLE material_request_items
ADD COLUMN plant_code VARCHAR(10),
ADD COLUMN storage_location VARCHAR(10),
ADD COLUMN delivery_date DATE,
ADD COLUMN account_assignment_category VARCHAR(1),
ADD COLUMN gl_account VARCHAR(10),
ADD COLUMN cost_center VARCHAR(10),
ADD COLUMN project_code VARCHAR(24),
ADD COLUMN wbs_element VARCHAR(24),
ADD COLUMN activity_code VARCHAR(12),
ADD COLUMN asset_number VARCHAR(12),
ADD COLUMN order_number VARCHAR(12);
```

### **Step 2: Add Missing Fields to PR Items**
```sql
ALTER TABLE pr_items
ADD COLUMN storage_location VARCHAR(10),
ADD COLUMN account_assignment_category VARCHAR(1),
ADD COLUMN gl_account VARCHAR(10),
ADD COLUMN asset_number VARCHAR(12),
ADD COLUMN order_number VARCHAR(12);
```

### **Step 3: Add Missing Fields to PO Items**
```sql
ALTER TABLE po_lines
ADD COLUMN plant_code VARCHAR(10),
ADD COLUMN storage_location VARCHAR(10),
ADD COLUMN account_assignment_category VARCHAR(1),
ADD COLUMN gl_account VARCHAR(10),
ADD COLUMN cost_center VARCHAR(10),
ADD COLUMN project_code VARCHAR(24),
ADD COLUMN wbs_element VARCHAR(24),
ADD COLUMN activity_code VARCHAR(12),
ADD COLUMN asset_number VARCHAR(12),
ADD COLUMN order_number VARCHAR(12);
```

### **Step 4: Migrate Header Data to Line Items (MR)**
```sql
-- Copy account assignment from header to all line items
UPDATE material_request_items mri
SET 
  plant_code = mr.plant_code,
  cost_center = mr.cost_center,
  project_code = mr.project_code,
  wbs_element = mr.wbs_element,
  activity_code = mr.activity_code,
  storage_location = mr.storage_location,
  account_assignment_category = CASE 
    WHEN mr.wbs_element IS NOT NULL THEN 'P'
    WHEN mr.cost_center IS NOT NULL THEN 'K'
    ELSE NULL
  END
FROM material_requests mr
WHERE mri.material_request_id = mr.id;
```

### **Step 5: Remove Header Fields (Optional - After Migration)**
```sql
-- Keep for backward compatibility, but mark as deprecated
ALTER TABLE material_requests
RENAME COLUMN cost_center TO cost_center_deprecated;
-- Repeat for other fields
```

---

## Field Mapping Matrix

| Field | MR Header | MR Items | PR Items | PO Items | Required |
|-------|-----------|----------|----------|----------|----------|
| **plant_code** | ✅ | ❌→✅ | ✅ | ❌→✅ | Yes |
| **storage_location** | ✅ | ❌→✅ | ❌→✅ | ❌→✅ | Yes |
| **delivery_date** | ❌ | ❌→✅ | ✅ | ✅ | Yes |
| **account_assignment_category** | ❌ | ❌→✅ | ❌→✅ | ✅ | Yes |
| **gl_account** | ❌ | ❌→✅ | ❌→✅ | ❌→✅ | Yes |
| **cost_center** | ✅ | ❌→✅ | ✅ | ❌→✅ | If K |
| **project_code** | ✅ | ❌→✅ | ✅ | ❌→✅ | If P |
| **wbs_element** | ✅ | ❌→✅ | ✅ | ❌→✅ | If P |
| **activity_code** | ✅ | ❌→✅ | ✅ | ❌→✅ | If P |
| **asset_number** | ❌ | ❌→✅ | ❌→✅ | ❌→✅ | If A |
| **order_number** | ❌ | ❌→✅ | ❌→✅ | ❌→✅ | If O |

Legend: ✅ Exists | ❌ Missing | ❌→✅ Needs to be added

---

## Use Cases

### **Use Case 1: Mixed Project Materials**
```
MR-001 (Header: No default assignment)
  Line 1: Cement → Project P001, WBS W001 (Category = P)
  Line 2: Steel → Project P002, WBS W005 (Category = P)
  Line 3: Office Supplies → Cost Center CC-ADM (Category = K)
```

### **Use Case 2: Asset Purchase**
```
MR-002
  Line 1: Excavator → Asset A-001 (Category = A)
  Line 2: Spare Parts → Cost Center CC-MAINT (Category = K)
```

### **Use Case 3: Internal Order**
```
MR-003
  Line 1: Materials → Internal Order IO-2024-001 (Category = O)
```

---

## Validation Rules

### **At Line Item Level**
1. **account_assignment_category** is mandatory
2. If category = 'K' → cost_center is mandatory
3. If category = 'P' → wbs_element is mandatory (project_code optional)
4. If category = 'A' → asset_number is mandatory
5. If category = 'O' → order_number is mandatory
6. **gl_account** is mandatory for all categories
7. **plant_code** is mandatory for all items

### **Validation Function**
```sql
CREATE OR REPLACE FUNCTION validate_line_item_account_assignment()
RETURNS TRIGGER AS $$
BEGIN
  -- Check category is provided
  IF NEW.account_assignment_category IS NULL THEN
    RAISE EXCEPTION 'Account assignment category is required';
  END IF;
  
  -- Validate based on category
  IF NEW.account_assignment_category = 'K' AND NEW.cost_center IS NULL THEN
    RAISE EXCEPTION 'Cost center is required for category K';
  END IF;
  
  IF NEW.account_assignment_category = 'P' AND NEW.wbs_element IS NULL THEN
    RAISE EXCEPTION 'WBS element is required for category P';
  END IF;
  
  IF NEW.account_assignment_category = 'A' AND NEW.asset_number IS NULL THEN
    RAISE EXCEPTION 'Asset number is required for category A';
  END IF;
  
  IF NEW.account_assignment_category = 'O' AND NEW.order_number IS NULL THEN
    RAISE EXCEPTION 'Order number is required for category O';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## UI Changes Required

### **MR Form**
- Remove account assignment from header section
- Add account assignment fields to each line item
- Add dropdown for account_assignment_category (K/P/A/O)
- Show/hide relevant fields based on category selection

### **PR Form**
- Add missing fields: account_assignment_category, gl_account, asset_number, order_number
- Inherit from MR line items when converting MR→PR

### **PO Form**
- Expand account_assignment_object to individual fields
- Inherit from PR line items when converting PR→PO

---

## Status: 🔴 REQUIRES MIGRATION

**Priority**: HIGH  
**Impact**: Breaking change for existing data  
**Effort**: 2-3 days (schema + code + testing)
