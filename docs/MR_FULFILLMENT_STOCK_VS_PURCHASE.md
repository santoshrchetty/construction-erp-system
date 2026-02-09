# MR Fulfillment Logic - Stock vs Purchase

## Core Concept

**Site users raise MR without knowing/caring if materials are in stock or need to be purchased.**

The system determines the fulfillment path automatically.

---

## MR Fulfillment Flow

```
┌─────────────────────────────────────────────────────────────┐
│  SITE ENGINEER CREATES MR                                    │
│  "I need 100 bags of cement for Project P-001"              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  MR APPROVED BY PROJECT MANAGER                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  SYSTEM CHECKS STOCK AVAILABILITY                            │
│  Query: Available stock in plant/storage location           │
└─────────────────────────────────────────────────────────────┘
                          ↓
                    ┌─────┴─────┐
                    │           │
            ┌───────▼─────┐ ┌──▼──────────┐
            │ IN STOCK    │ │ NOT IN STOCK│
            │ (100 bags)  │ │ (0 bags)    │
            └───────┬─────┘ └──┬──────────┘
                    │           │
        ┌───────────▼───────────▼──────────┐
        │ PARTIAL STOCK (50 bags available)│
        └───────────┬──────────────────────┘
                    │
    ┌───────────────┼───────────────┐
    │               │               │
    ▼               ▼               ▼
┌────────┐    ┌──────────┐    ┌─────────┐
│ ISSUE  │    │ ISSUE 50 │    │ CREATE  │
│ FROM   │    │ + CREATE │    │ PR/PO   │
│ STOCK  │    │ PR FOR 50│    │ FOR 100 │
└────────┘    └──────────┘    └─────────┘
```

---

## Three Fulfillment Scenarios

### **Scenario 1: Fully Available in Stock (70% of cases)**

**MR Details:**
```
MR-2024-001
Requested by: Site Engineer (John)
Material: Cement
Quantity: 100 bags
Plant: PLANT-01
Storage Location: WH-01
```

**System Check:**
```sql
SELECT available_quantity 
FROM inventory_stock
WHERE material_code = 'CEMENT-OPC-43'
  AND plant_code = 'PLANT-01'
  AND storage_location = 'WH-01';
  
Result: 500 bags available ✅
```

**Action:**
```
1. Create Goods Issue (GI) document
2. Issue 100 bags from stock
3. Update inventory: 500 - 100 = 400 bags
4. Post to accounting:
   DR: Project P-001 (WIP)
   CR: Inventory
5. Close MR (Status: FULFILLED_FROM_STOCK)
```

**No PR/PO needed!**

---

### **Scenario 2: Not Available in Stock (20% of cases)**

**MR Details:**
```
MR-2024-002
Requested by: Site Engineer (Sarah)
Material: Special Steel Grade
Quantity: 10 tons
Plant: PLANT-01
Storage Location: WH-01
```

**System Check:**
```sql
SELECT available_quantity 
FROM inventory_stock
WHERE material_code = 'STEEL-SPECIAL-500'
  AND plant_code = 'PLANT-01'
  AND storage_location = 'WH-01';
  
Result: 0 tons available ❌
```

**Action:**
```
1. Create Purchase Requisition (PR)
   PR-2024-001
   Source: MR-2024-002
   Quantity: 10 tons
   
2. Procurement converts PR → PO
   PO-2024-001
   Vendor: ABC Steel Suppliers
   
3. Vendor delivers materials
   
4. Goods Receipt (GR) into stock
   
5. Goods Issue (GI) to project
   
6. Close MR (Status: FULFILLED_VIA_PURCHASE)
```

---

### **Scenario 3: Partially Available (10% of cases)**

**MR Details:**
```
MR-2024-003
Requested by: Site Engineer (Mike)
Material: Cement
Quantity: 100 bags
Plant: PLANT-01
Storage Location: WH-01
```

**System Check:**
```sql
SELECT available_quantity 
FROM inventory_stock
WHERE material_code = 'CEMENT-OPC-43'
  AND plant_code = 'PLANT-01'
  AND storage_location = 'WH-01';
  
Result: 50 bags available ⚠️ (Partial)
```

**Action:**
```
1. SPLIT MR into two fulfillment paths:

   Path A: Issue from Stock
   - Issue 50 bags immediately
   - Update inventory: 50 - 50 = 0 bags
   
   Path B: Purchase Remaining
   - Create PR for 50 bags
   - Convert PR → PO
   - Receive goods
   - Issue to project
   
2. Update MR status:
   - Quantity Requested: 100
   - Quantity Issued: 50
   - Quantity Pending: 50
   - Status: PARTIALLY_FULFILLED
   
3. When purchase arrives:
   - Issue remaining 50 bags
   - Status: FULLY_FULFILLED
```

---

## MR Item Status Tracking

### **Enhanced Schema**
```sql
ALTER TABLE material_request_items
ADD COLUMN fulfillment_type VARCHAR(20),  -- STOCK, PURCHASE, MIXED
ADD COLUMN quantity_from_stock DECIMAL(13,3) DEFAULT 0,
ADD COLUMN quantity_to_purchase DECIMAL(13,3) DEFAULT 0,
ADD COLUMN quantity_issued DECIMAL(13,3) DEFAULT 0,
ADD COLUMN quantity_pending DECIMAL(13,3);

-- Fulfillment types
-- STOCK: Fully from stock
-- PURCHASE: Fully via purchase
-- MIXED: Partial stock + partial purchase
```

### **Item Status Values**
```sql
-- PENDING: MR approved, awaiting fulfillment check
-- STOCK_AVAILABLE: Can be fulfilled from stock
-- PURCHASE_REQUIRED: Needs to be purchased
-- PARTIALLY_ISSUED: Some quantity issued
-- FULLY_ISSUED: All quantity issued
-- CANCELLED: MR cancelled
```

---

## Automatic Stock Check Logic

### **Function: Check Stock Availability**
```sql
CREATE OR REPLACE FUNCTION check_mr_stock_availability(
  p_mr_id UUID
)
RETURNS TABLE (
  item_id UUID,
  material_code VARCHAR,
  requested_qty DECIMAL,
  available_qty DECIMAL,
  fulfillment_type VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    mri.id,
    mri.material_code,
    mri.quantity,
    COALESCE(inv.available_quantity, 0) as available_qty,
    CASE 
      WHEN COALESCE(inv.available_quantity, 0) >= mri.quantity THEN 'STOCK'
      WHEN COALESCE(inv.available_quantity, 0) = 0 THEN 'PURCHASE'
      ELSE 'MIXED'
    END as fulfillment_type
  FROM material_request_items mri
  LEFT JOIN inventory_stock inv 
    ON inv.material_code = mri.material_code
    AND inv.plant_code = mri.plant_code
    AND inv.storage_location = mri.storage_location
  WHERE mri.material_request_id = p_mr_id;
END;
$$ LANGUAGE plpgsql;
```

---

## Workflow After MR Approval

### **Step 1: MR Approved**
```
Status: APPROVED
Next Action: Check stock availability
```

### **Step 2: Stock Check (Automatic)**
```javascript
// Pseudo-code
async function processMRApproval(mrId) {
  const items = await checkStockAvailability(mrId);
  
  for (const item of items) {
    if (item.fulfillment_type === 'STOCK') {
      // Create Goods Issue reservation
      await createStockReservation(item);
      
    } else if (item.fulfillment_type === 'PURCHASE') {
      // Create PR item
      await createPRItem(item);
      
    } else if (item.fulfillment_type === 'MIXED') {
      // Split: Reserve stock + Create PR
      await createStockReservation(item, item.available_qty);
      await createPRItem(item, item.requested_qty - item.available_qty);
    }
  }
}
```

### **Step 3: Fulfillment**
```
STOCK Items:
  → Store Keeper issues materials
  → Goods Issue (GI) document created
  → MR item status: FULLY_ISSUED

PURCHASE Items:
  → Procurement creates PR
  → PR converted to PO
  → Vendor delivers
  → GR → GI → MR item status: FULLY_ISSUED
```

---

## User Experience

### **Site Engineer View (Simple)**
```
1. Create MR
2. Submit for approval
3. Wait for materials
4. Receive materials (don't care if from stock or purchased)
```

### **Store Keeper View (Stock)**
```
1. Receive notification: "MR-2024-001 approved"
2. Check: Materials available in stock
3. Issue materials to site
4. Update MR: Fulfilled from stock
```

### **Procurement View (Purchase)**
```
1. Receive notification: "MR-2024-002 requires purchase"
2. System auto-creates PR from MR
3. Review PR, add vendor details
4. Convert PR → PO
5. Send PO to vendor
6. Track delivery
```

---

## Inventory Integration

### **Stock Reservation**
```sql
CREATE TABLE stock_reservations (
  id UUID PRIMARY KEY,
  material_code VARCHAR(50),
  plant_code VARCHAR(10),
  storage_location VARCHAR(10),
  reserved_quantity DECIMAL(13,3),
  reservation_type VARCHAR(20),  -- MR, SO, PRODUCTION
  reference_document VARCHAR(50), -- MR-2024-001
  reference_item INTEGER,
  created_at TIMESTAMP
);
```

**When MR approved and stock available:**
```sql
INSERT INTO stock_reservations (
  material_code,
  reserved_quantity,
  reservation_type,
  reference_document
) VALUES (
  'CEMENT-OPC-43',
  100,
  'MR',
  'MR-2024-001'
);
```

---

## Reporting

### **MR Fulfillment Report**
```sql
SELECT 
  mr.request_number,
  COUNT(mri.id) as total_items,
  SUM(CASE WHEN mri.fulfillment_type = 'STOCK' THEN 1 ELSE 0 END) as from_stock,
  SUM(CASE WHEN mri.fulfillment_type = 'PURCHASE' THEN 1 ELSE 0 END) as to_purchase,
  SUM(CASE WHEN mri.fulfillment_type = 'MIXED' THEN 1 ELSE 0 END) as mixed
FROM material_requests mr
JOIN material_request_items mri ON mr.id = mri.material_request_id
WHERE mr.status = 'APPROVED'
GROUP BY mr.request_number;
```

---

## Summary

### **Key Points:**

1. ✅ **Site users raise MR** without knowing stock status
2. ✅ **System checks stock** automatically after approval
3. ✅ **Three paths:**
   - Fully from stock (70%) → Direct GI
   - Not in stock (20%) → Create PR/PO
   - Partial stock (10%) → Split fulfillment
4. ✅ **Transparent to user** - they just get materials
5. ✅ **Efficient** - No unnecessary purchases if stock available

---

## Status: ✅ DOCUMENTED

**This is standard ERP behavior** - MR is source-agnostic, system determines fulfillment path.
