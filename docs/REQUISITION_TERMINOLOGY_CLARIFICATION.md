# Requisition Terminology - MR vs PR vs Requisition

## Terminology Confusion

The term **"Requisition"** is often used loosely and can mean different things in different contexts.

---

## Three Common Interpretations

### **1. Requisition = Material Request (MR)**
**Some companies use "Requisition" to mean Material Request**

```
Requisition = Material Request (MR)
- Created by: Site Engineer, Project Manager
- Purpose: Request materials needed
- Converts to: Purchase Requisition (PR)
```

**Example:**
- "I need to create a requisition for cement" = Material Request

---

### **2. Requisition = Purchase Requisition (PR)**
**SAP and many ERPs use "Purchase Requisition" as the formal term**

```
Purchase Requisition (PR)
- Created by: Procurement team (from MR)
- Purpose: Formal purchasing document
- Converts to: Purchase Order (PO)
```

**Example:**
- "Convert the MR to a purchase requisition" = PR

---

### **3. Requisition = Generic Request**
**General term for any type of request**

```
Requisition (Generic)
- Material Requisition = MR
- Purchase Requisition = PR
- Service Requisition = SR
- Equipment Requisition = ER
```

---

## Standard ERP Flow (SAP Model)

### **Our Implementation:**

```
┌─────────────────────────────────────────────────────────┐
│                    PROCUREMENT FLOW                      │
└─────────────────────────────────────────────────────────┘

1. MATERIAL REQUEST (MR)
   - Document: MR-2024-001
   - Created by: Site Engineer
   - Purpose: "I need materials"
   - Status: DRAFT → APPROVED
   
   ↓ Convert
   
2. PURCHASE REQUISITION (PR)
   - Document: PR-2024-001
   - Created by: Procurement (from MR)
   - Purpose: "Formal purchase request"
   - Status: OPEN → PARTIALLY_CONVERTED → CLOSED
   
   ↓ Convert
   
3. PURCHASE ORDER (PO)
   - Document: PO-2024-001
   - Created by: Procurement (from PR)
   - Sent to: Vendor
   - Purpose: "Official order to vendor"
   - Status: CREATED → APPROVED → SENT → RECEIVED
```

---

## Terminology by System

| System | Term Used | Meaning |
|--------|-----------|---------|
| **SAP** | Purchase Requisition (PR) | Formal procurement document |
| **SAP** | Material Request (not standard) | Custom/informal request |
| **Oracle** | Purchase Requisition | Same as SAP PR |
| **Procore** | Material Request | Site-level request |
| **Our System** | Material Request (MR) | Site/user request |
| **Our System** | Purchase Requisition (PR) | Procurement document |

---

## Key Differences: MR vs PR

### **Material Request (MR)**
- **Created by:** End users (Site Engineer, Project Manager, Store Keeper)
- **Purpose:** Express need for materials
- **Approval:** Project Manager, Construction Manager
- **Contains:** Material needs, quantities, required dates
- **Status:** DRAFT, SUBMITTED, APPROVED, REJECTED
- **Converts to:** Purchase Requisition (PR)

### **Purchase Requisition (PR)**
- **Created by:** Procurement team (from approved MR)
- **Purpose:** Formal procurement document
- **Approval:** Procurement Manager, Finance (if high value)
- **Contains:** Vendor details, pricing, delivery terms
- **Status:** OPEN, PARTIALLY_CONVERTED, FULLY_CONVERTED, CLOSED
- **Converts to:** Purchase Order (PO)

---

## When People Say "Requisition"

### **Context 1: Site User**
```
"I need to create a requisition for cement"
→ They mean: Material Request (MR)
→ Action: Create MR-2024-001
```

### **Context 2: Procurement Team**
```
"Convert this requisition to a PO"
→ They mean: Purchase Requisition (PR)
→ Action: Convert PR-2024-001 → PO-2024-001
```

### **Context 3: Management**
```
"How many requisitions are pending?"
→ They could mean: MRs OR PRs (need clarification)
→ Action: Ask "Material Requests or Purchase Requisitions?"
```

---

## Our System Design

### **We Use Both Terms Explicitly:**

1. **Material Request (MR)**
   - Table: `material_requests`, `material_request_items`
   - Document Type: 'MR'
   - Number Range: MR-2024-0001

2. **Purchase Requisition (PR)**
   - Table: `pr_headers`, `pr_items`
   - Document Type: 'PR'
   - Number Range: PR-2024-0001

3. **Purchase Order (PO)**
   - Table: `purchase_orders`, `po_lines`
   - Document Type: 'PO'
   - Number Range: PO-2024-0001

---

## Mapping Table

### **MR → PR Mapping**
```sql
CREATE TABLE mr_pr_item_mapping (
  id UUID PRIMARY KEY,
  mr_item_id UUID REFERENCES material_request_items(id),
  pr_item_id UUID REFERENCES pr_items(id),
  quantity DECIMAL(13,3),
  created_at TIMESTAMP
);
```

### **PR → PO Mapping**
```sql
CREATE TABLE pr_po_item_mapping (
  id UUID PRIMARY KEY,
  pr_item_id UUID REFERENCES pr_items(id),
  po_item_id UUID REFERENCES po_lines(id),
  quantity DECIMAL(13,3),
  created_at TIMESTAMP
);
```

---

## User Interface Terminology

### **For Site Users:**
- Use: "Material Request" or "Request Materials"
- Avoid: "Purchase Requisition" (too technical)

### **For Procurement Team:**
- Use: "Purchase Requisition" (formal term)
- Show: MR reference number for traceability

### **For Management:**
- Use both terms explicitly:
  - "Material Requests (MR)" - from sites
  - "Purchase Requisitions (PR)" - from procurement

---

## Real-World Example

### **Scenario: Site Engineer Needs Cement**

**Step 1: Create Material Request**
```
User: Site Engineer (John)
Action: "Create Material Request"
Document: MR-2024-001
Items:
  - Cement: 100 bags
  - Steel: 5 tons
Status: DRAFT → SUBMITTED → APPROVED
```

**Step 2: Procurement Creates PR**
```
User: Procurement Officer (Sarah)
Action: "Convert MR to Purchase Requisition"
Source: MR-2024-001
Document: PR-2024-001
Items:
  - Cement: 100 bags (from MR-2024-001, Line 1)
  - Steel: 5 tons (from MR-2024-001, Line 2)
Added:
  - Estimated prices
  - Preferred vendors
  - Delivery plant
Status: OPEN
```

**Step 3: Procurement Creates PO**
```
User: Procurement Officer (Sarah)
Action: "Convert PR to Purchase Order"
Source: PR-2024-001
Document: PO-2024-001
Vendor: ABC Suppliers
Items:
  - Cement: 100 bags @ $10/bag = $1,000
  - Steel: 5 tons @ $500/ton = $2,500
Total: $3,500
Status: CREATED → APPROVED → SENT TO VENDOR
```

---

## API Endpoints

### **Material Requests**
```
POST   /api/material-requests          (Create MR)
GET    /api/material-requests           (List MRs)
GET    /api/material-requests/:id       (Get MR details)
PUT    /api/material-requests/:id       (Update MR)
POST   /api/material-requests/:id/approve (Approve MR)
```

### **Purchase Requisitions**
```
POST   /api/purchase-requisitions       (Create PR from MR)
GET    /api/purchase-requisitions       (List PRs)
GET    /api/purchase-requisitions/:id   (Get PR details)
POST   /api/purchase-requisitions/:id/convert-to-po (Convert to PO)
```

### **Purchase Orders**
```
POST   /api/purchase-orders             (Create PO from PR)
GET    /api/purchase-orders             (List POs)
GET    /api/purchase-orders/:id         (Get PO details)
POST   /api/purchase-orders/:id/send    (Send PO to vendor)
```

---

## Summary

### **Terminology Clarification:**

| Term | Our System | Who Uses It | Purpose |
|------|------------|-------------|---------|
| **Material Request (MR)** | ✅ Yes | Site users | Express material need |
| **Purchase Requisition (PR)** | ✅ Yes | Procurement | Formal procurement doc |
| **Requisition (generic)** | ❌ Avoid | Ambiguous | Use MR or PR explicitly |
| **Purchase Order (PO)** | ✅ Yes | Procurement | Order to vendor |

### **Best Practice:**
- Always use **explicit terms**: "Material Request (MR)" or "Purchase Requisition (PR)"
- Avoid generic "Requisition" to prevent confusion
- In UI: Use "Material Request" for site users, "Purchase Requisition" for procurement

---

## Status: ✅ CLARIFIED

**Recommendation:** Use MR and PR as distinct document types, avoid generic "Requisition" term.
