# MR → PR → PO Procurement Flow Design

## 1. Document Flow Overview

```
┌─────────────────┐
│  Material       │  Site User creates demand
│  Request (MR)   │  No pricing, no vendor
└────────┬────────┘
         │ Approval
         ↓
┌─────────────────┐
│  Purchase       │  Procurement adds pricing
│  Requisition    │  Consolidates multiple MRs
│  (PR)           │  Still no vendor commitment
└────────┬────────┘
         │ Approval
         ↓
┌─────────────────┐
│  Purchase       │  Legal commitment to vendor
│  Order (PO)     │  Final price, terms, delivery
└─────────────────┘
```

## 2. Data Model

### 2.1 Material Request Tables

```sql
-- MR Header
CREATE TABLE mr_headers (
  id UUID PRIMARY KEY,
  mr_number VARCHAR(20) UNIQUE NOT NULL,
  company_code VARCHAR(4) NOT NULL,
  plant_code VARCHAR(4) NOT NULL,
  project_code VARCHAR(24),
  wbs_element VARCHAR(24),
  requested_by VARCHAR(12) NOT NULL,
  required_date DATE NOT NULL,
  priority VARCHAR(10) NOT NULL, -- LOW, MEDIUM, HIGH, URGENT
  status VARCHAR(20) NOT NULL, -- DRAFT, SUBMITTED, APPROVED, REJECTED, CLOSED
  purpose TEXT,
  justification TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(12),
  tenant_id UUID NOT NULL
);

-- MR Items
CREATE TABLE mr_items (
  id UUID PRIMARY KEY,
  mr_header_id UUID NOT NULL REFERENCES mr_headers(id),
  line_number INTEGER NOT NULL,
  material_code VARCHAR(40),
  material_description TEXT,
  quantity DECIMAL(13,3) NOT NULL,
  uom VARCHAR(3) NOT NULL,
  required_date DATE NOT NULL,
  
  -- Account Assignment (Item Level)
  account_assignment VARCHAR(1) NOT NULL, -- P=Project, K=CostCenter, M=Maintenance, F=Production
  project_code VARCHAR(24),
  wbs_element VARCHAR(24),
  activity_code VARCHAR(12),
  cost_center VARCHAR(10),
  order_number VARCHAR(12),
  
  -- Quantity Tracking
  requested_quantity DECIMAL(13,3) NOT NULL,
  open_quantity DECIMAL(13,3) NOT NULL, -- Not yet converted to PR
  pr_quantity DECIMAL(13,3) DEFAULT 0, -- Converted to PR
  
  -- Status
  item_status VARCHAR(20) NOT NULL, -- OPEN, PARTIAL, CLOSED
  technical_remarks TEXT,
  
  tenant_id UUID NOT NULL,
  UNIQUE(mr_header_id, line_number)
);
```

### 2.2 Purchase Requisition Tables

```sql
-- PR Header
CREATE TABLE pr_headers (
  id UUID PRIMARY KEY,
  pr_number VARCHAR(20) UNIQUE NOT NULL,
  company_code VARCHAR(4) NOT NULL,
  purchasing_org VARCHAR(4) NOT NULL,
  purchase_group VARCHAR(3) NOT NULL,
  status VARCHAR(20) NOT NULL, -- DRAFT, SUBMITTED, APPROVED, REJECTED, CLOSED
  created_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(12),
  tenant_id UUID NOT NULL
);

-- PR Items
CREATE TABLE pr_items (
  id UUID PRIMARY KEY,
  pr_header_id UUID NOT NULL REFERENCES pr_headers(id),
  line_number INTEGER NOT NULL,
  material_code VARCHAR(40),
  material_description TEXT,
  quantity DECIMAL(13,3) NOT NULL,
  uom VARCHAR(3) NOT NULL,
  delivery_plant VARCHAR(4) NOT NULL,
  required_date DATE NOT NULL,
  estimated_price DECIMAL(13,2),
  currency VARCHAR(3),
  
  -- Account Assignment (Copied from MR)
  account_assignment VARCHAR(1) NOT NULL,
  project_code VARCHAR(24),
  wbs_element VARCHAR(24),
  activity_code VARCHAR(12),
  cost_center VARCHAR(10),
  order_number VARCHAR(12),
  
  -- Quantity Tracking
  pr_quantity DECIMAL(13,3) NOT NULL,
  open_quantity DECIMAL(13,3) NOT NULL, -- Not yet converted to PO
  po_quantity DECIMAL(13,3) DEFAULT 0, -- Converted to PO
  
  -- Status
  item_status VARCHAR(20) NOT NULL, -- OPEN, PARTIAL, CLOSED
  
  tenant_id UUID NOT NULL,
  UNIQUE(pr_header_id, line_number)
);

-- MR to PR Mapping (Many-to-Many)
CREATE TABLE mr_pr_item_mapping (
  id UUID PRIMARY KEY,
  mr_item_id UUID NOT NULL REFERENCES mr_items(id),
  pr_item_id UUID NOT NULL REFERENCES pr_items(id),
  quantity DECIMAL(13,3) NOT NULL, -- Quantity copied from MR to PR
  created_at TIMESTAMP DEFAULT NOW(),
  tenant_id UUID NOT NULL
);
```

### 2.3 Purchase Order Tables

```sql
-- PO Header
CREATE TABLE po_headers (
  id UUID PRIMARY KEY,
  po_number VARCHAR(20) UNIQUE NOT NULL,
  vendor_code VARCHAR(10) NOT NULL,
  company_code VARCHAR(4) NOT NULL,
  purchasing_org VARCHAR(4) NOT NULL,
  purchase_group VARCHAR(3) NOT NULL,
  currency VARCHAR(3) NOT NULL,
  payment_terms VARCHAR(4),
  incoterms VARCHAR(3),
  status VARCHAR(20) NOT NULL, -- DRAFT, SUBMITTED, APPROVED, CLOSED
  total_value DECIMAL(15,2),
  created_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(12),
  tenant_id UUID NOT NULL
);

-- PO Items
CREATE TABLE po_items (
  id UUID PRIMARY KEY,
  po_header_id UUID NOT NULL REFERENCES po_headers(id),
  line_number INTEGER NOT NULL,
  material_code VARCHAR(40),
  material_description TEXT,
  quantity DECIMAL(13,3) NOT NULL,
  uom VARCHAR(3) NOT NULL,
  unit_price DECIMAL(13,2) NOT NULL,
  line_value DECIMAL(15,2) NOT NULL,
  tax_code VARCHAR(2),
  delivery_plant VARCHAR(4) NOT NULL,
  delivery_date DATE NOT NULL,
  
  -- Account Assignment (Copied from PR)
  account_assignment VARCHAR(1) NOT NULL,
  project_code VARCHAR(24),
  wbs_element VARCHAR(24),
  activity_code VARCHAR(12),
  cost_center VARCHAR(10),
  order_number VARCHAR(12),
  
  -- Quantity Tracking
  po_quantity DECIMAL(13,3) NOT NULL,
  gr_quantity DECIMAL(13,3) DEFAULT 0, -- Goods Receipt quantity
  open_quantity DECIMAL(13,3) NOT NULL, -- Not yet received
  
  item_status VARCHAR(20) NOT NULL, -- OPEN, PARTIAL, CLOSED
  
  tenant_id UUID NOT NULL,
  UNIQUE(po_header_id, line_number)
);

-- PR to PO Mapping (Many-to-Many)
CREATE TABLE pr_po_item_mapping (
  id UUID PRIMARY KEY,
  pr_item_id UUID NOT NULL REFERENCES pr_items(id),
  po_item_id UUID NOT NULL REFERENCES po_items(id),
  quantity DECIMAL(13,3) NOT NULL, -- Quantity copied from PR to PO
  created_at TIMESTAMP DEFAULT NOW(),
  tenant_id UUID NOT NULL
);
```

## 3. Business Rules

### 3.1 MR Business Rules

```typescript
// MR Creation Rules
- MR can be created by site users (Project Manager, Site Engineer)
- MR must have at least one item
- Each item must have material OR description
- Required date must be >= current date
- Account assignment is MANDATORY at item level
- If account_assignment = 'P', project_code is required
- If account_assignment = 'K', cost_center is required
- Status starts as DRAFT

// MR Approval Rules
- Only SUBMITTED MRs can be approved
- Approval based on total estimated value
- Approved MRs can be converted to PR
- Rejected MRs can be revised and resubmitted

// MR Quantity Control
- open_quantity = requested_quantity - pr_quantity
- item_status = OPEN if open_quantity = requested_quantity
- item_status = PARTIAL if 0 < open_quantity < requested_quantity
- item_status = CLOSED if open_quantity = 0
- MR header status = CLOSED when all items are CLOSED
```

### 3.2 PR Business Rules

```typescript
// PR Creation Rules
- PR can only be created by procurement users
- PR can be created from multiple approved MR items
- PR items inherit account assignment from MR items
- Estimated price can be added during PR creation
- Purchasing org and purchase group are mandatory

// PR Copy from MR Rules
- Only APPROVED MR items can be copied
- Partial quantity copy is allowed
- open_quantity on MR item must be > 0
- Account assignment is copied without modification
- Multiple MR items can be combined into one PR item if:
  * Same material
  * Same delivery plant
  * Same account assignment
  * Same required date (within tolerance)

// PR Approval Rules
- PR approval based on total estimated value
- Approved PRs can be converted to PO
- PR can be split into multiple POs by vendor

// PR Quantity Control
- open_quantity = pr_quantity - po_quantity
- item_status = OPEN if open_quantity = pr_quantity
- item_status = PARTIAL if 0 < open_quantity < pr_quantity
- item_status = CLOSED if open_quantity = 0
```

### 3.3 PO Business Rules

```typescript
// PO Creation Rules
- PO can only be created by procurement users
- PO must have vendor
- PO can be created from multiple approved PR items
- Unit price is MANDATORY
- Payment terms and incoterms are required
- PO represents legal commitment

// PO Copy from PR Rules
- Only APPROVED PR items can be copied
- Partial quantity copy is allowed
- open_quantity on PR item must be > 0
- Account assignment is copied without modification
- Multiple PR items can be combined into one PO item if:
  * Same material
  * Same vendor
  * Same delivery plant
  * Same account assignment

// PO Approval Rules
- PO approval based on total value
- Approved POs can receive goods (GR)
- PO cannot be deleted after approval

// PO Quantity Control
- open_quantity = po_quantity - gr_quantity
- item_status = OPEN if open_quantity = po_quantity
- item_status = PARTIAL if 0 < open_quantity < po_quantity
- item_status = CLOSED if open_quantity = 0
```

## 4. Copy Functions Logic

### 4.1 MR → PR Copy Function

```typescript
async function copyMRtoPR(
  mrItemIds: string[],
  copyQuantities: { [mrItemId: string]: number },
  prHeaderData: PRHeaderData
): Promise<PRHeader> {
  
  // 1. Validate MR items
  const mrItems = await validateMRItems(mrItemIds)
  for (const item of mrItems) {
    if (item.mr_header.status !== 'APPROVED') {
      throw new Error(`MR ${item.mr_header.mr_number} is not approved`)
    }
    if (item.open_quantity <= 0) {
      throw new Error(`MR item ${item.line_number} has no open quantity`)
    }
    const copyQty = copyQuantities[item.id]
    if (copyQty > item.open_quantity) {
      throw new Error(`Copy quantity exceeds open quantity for item ${item.line_number}`)
    }
  }
  
  // 2. Create PR Header
  const prHeader = await createPRHeader({
    pr_number: await getNextPRNumber(prHeaderData.company_code),
    company_code: prHeaderData.company_code,
    purchasing_org: prHeaderData.purchasing_org,
    purchase_group: prHeaderData.purchase_group,
    status: 'DRAFT',
    created_by: getCurrentUser()
  })
  
  // 3. Create PR Items
  let lineNumber = 1
  for (const mrItem of mrItems) {
    const copyQty = copyQuantities[mrItem.id]
    
    const prItem = await createPRItem({
      pr_header_id: prHeader.id,
      line_number: lineNumber++,
      material_code: mrItem.material_code,
      material_description: mrItem.material_description,
      quantity: copyQty,
      uom: mrItem.uom,
      delivery_plant: mrItem.mr_header.plant_code,
      required_date: mrItem.required_date,
      
      // Copy account assignment
      account_assignment: mrItem.account_assignment,
      project_code: mrItem.project_code,
      wbs_element: mrItem.wbs_element,
      activity_code: mrItem.activity_code,
      cost_center: mrItem.cost_center,
      order_number: mrItem.order_number,
      
      pr_quantity: copyQty,
      open_quantity: copyQty,
      item_status: 'OPEN'
    })
    
    // 4. Create mapping
    await createMRPRMapping({
      mr_item_id: mrItem.id,
      pr_item_id: prItem.id,
      quantity: copyQty
    })
    
    // 5. Update MR item quantities
    await updateMRItemQuantities(mrItem.id, {
      pr_quantity: mrItem.pr_quantity + copyQty,
      open_quantity: mrItem.open_quantity - copyQty,
      item_status: calculateItemStatus(mrItem.open_quantity - copyQty, mrItem.requested_quantity)
    })
  }
  
  // 6. Update MR header status if all items closed
  await updateMRHeaderStatus(mrItems[0].mr_header_id)
  
  return prHeader
}
```

### 4.2 PR → PO Copy Function

```typescript
async function copyPRtoPO(
  prItemIds: string[],
  copyQuantities: { [prItemId: string]: number },
  poHeaderData: POHeaderData
): Promise<POHeader> {
  
  // 1. Validate PR items
  const prItems = await validatePRItems(prItemIds)
  for (const item of prItems) {
    if (item.pr_header.status !== 'APPROVED') {
      throw new Error(`PR ${item.pr_header.pr_number} is not approved`)
    }
    if (item.open_quantity <= 0) {
      throw new Error(`PR item ${item.line_number} has no open quantity`)
    }
    const copyQty = copyQuantities[item.id]
    if (copyQty > item.open_quantity) {
      throw new Error(`Copy quantity exceeds open quantity for item ${item.line_number}`)
    }
  }
  
  // 2. Create PO Header
  const poHeader = await createPOHeader({
    po_number: await getNextPONumber(poHeaderData.company_code),
    vendor_code: poHeaderData.vendor_code,
    company_code: poHeaderData.company_code,
    purchasing_org: poHeaderData.purchasing_org,
    purchase_group: poHeaderData.purchase_group,
    currency: poHeaderData.currency,
    payment_terms: poHeaderData.payment_terms,
    incoterms: poHeaderData.incoterms,
    status: 'DRAFT',
    created_by: getCurrentUser()
  })
  
  // 3. Create PO Items
  let lineNumber = 1
  let totalValue = 0
  
  for (const prItem of prItems) {
    const copyQty = copyQuantities[prItem.id]
    const unitPrice = poHeaderData.itemPrices[prItem.id]
    const lineValue = copyQty * unitPrice
    totalValue += lineValue
    
    const poItem = await createPOItem({
      po_header_id: poHeader.id,
      line_number: lineNumber++,
      material_code: prItem.material_code,
      material_description: prItem.material_description,
      quantity: copyQty,
      uom: prItem.uom,
      unit_price: unitPrice,
      line_value: lineValue,
      tax_code: poHeaderData.tax_code,
      delivery_plant: prItem.delivery_plant,
      delivery_date: prItem.required_date,
      
      // Copy account assignment
      account_assignment: prItem.account_assignment,
      project_code: prItem.project_code,
      wbs_element: prItem.wbs_element,
      activity_code: prItem.activity_code,
      cost_center: prItem.cost_center,
      order_number: prItem.order_number,
      
      po_quantity: copyQty,
      open_quantity: copyQty,
      item_status: 'OPEN'
    })
    
    // 4. Create mapping
    await createPRPOMapping({
      pr_item_id: prItem.id,
      po_item_id: poItem.id,
      quantity: copyQty
    })
    
    // 5. Update PR item quantities
    await updatePRItemQuantities(prItem.id, {
      po_quantity: prItem.po_quantity + copyQty,
      open_quantity: prItem.open_quantity - copyQty,
      item_status: calculateItemStatus(prItem.open_quantity - copyQty, prItem.pr_quantity)
    })
  }
  
  // 6. Update PO total value
  await updatePOHeader(poHeader.id, { total_value: totalValue })
  
  // 7. Update PR header status if all items closed
  await updatePRHeaderStatus(prItems[0].pr_header_id)
  
  return poHeader
}
```

## 5. Status Calculation Logic

```typescript
function calculateItemStatus(openQty: number, totalQty: number): string {
  if (openQty === totalQty) return 'OPEN'
  if (openQty === 0) return 'CLOSED'
  return 'PARTIAL'
}

async function updateMRHeaderStatus(mrHeaderId: string) {
  const items = await getMRItems(mrHeaderId)
  const allClosed = items.every(item => item.item_status === 'CLOSED')
  const anyClosed = items.some(item => item.item_status === 'CLOSED' || item.item_status === 'PARTIAL')
  
  if (allClosed) {
    await updateMRHeader(mrHeaderId, { status: 'CLOSED' })
  } else if (anyClosed) {
    await updateMRHeader(mrHeaderId, { status: 'PARTIAL' })
  }
}
```

## 6. Traceability Queries

```sql
-- Find all PRs created from an MR
SELECT pr.pr_number, pr.status, pri.line_number, m.quantity
FROM mr_pr_item_mapping m
JOIN pr_items pri ON m.pr_item_id = pri.id
JOIN pr_headers pr ON pri.pr_header_id = pr.id
WHERE m.mr_item_id = :mr_item_id;

-- Find all POs created from a PR
SELECT po.po_number, po.vendor_code, po.status, poi.line_number, m.quantity
FROM pr_po_item_mapping m
JOIN po_items poi ON m.po_item_id = poi.id
JOIN po_headers po ON poi.po_header_id = po.id
WHERE m.pr_item_id = :pr_item_id;

-- Full traceability: MR → PR → PO
SELECT 
  mr.mr_number,
  pri.pr_number,
  po.po_number,
  mr_map.quantity as mr_to_pr_qty,
  pr_map.quantity as pr_to_po_qty
FROM mr_items mri
JOIN mr_headers mr ON mri.mr_header_id = mr.id
LEFT JOIN mr_pr_item_mapping mr_map ON mri.id = mr_map.mr_item_id
LEFT JOIN pr_items pri_item ON mr_map.pr_item_id = pri_item.id
LEFT JOIN pr_headers pri ON pri_item.pr_header_id = pri.id
LEFT JOIN pr_po_item_mapping pr_map ON pri_item.id = pr_map.pr_item_id
LEFT JOIN po_items poi ON pr_map.po_item_id = poi.id
LEFT JOIN po_headers po ON poi.po_header_id = po.id
WHERE mri.id = :mr_item_id;
```

## 7. Role-Based Access Control

```typescript
const PERMISSIONS = {
  MR: {
    CREATE: ['SITE_USER', 'PROJECT_MANAGER', 'SITE_ENGINEER'],
    APPROVE: ['PROJECT_MANAGER', 'PROCUREMENT_MANAGER'],
    VIEW: ['ALL']
  },
  PR: {
    CREATE: ['PROCUREMENT_USER', 'PROCUREMENT_MANAGER'],
    APPROVE: ['PROCUREMENT_MANAGER', 'FINANCE_MANAGER'],
    VIEW: ['PROCUREMENT_USER', 'PROCUREMENT_MANAGER']
  },
  PO: {
    CREATE: ['PROCUREMENT_USER', 'PROCUREMENT_MANAGER'],
    APPROVE: ['PROCUREMENT_MANAGER', 'FINANCE_MANAGER'],
    VIEW: ['PROCUREMENT_USER', 'PROCUREMENT_MANAGER', 'FINANCE_USER']
  }
}
```

## 8. Best Practices

1. **Immutability**: Never modify approved documents. Create new versions instead.
2. **Audit Trail**: Log all copy operations with user, timestamp, and quantities.
3. **Quantity Precision**: Use DECIMAL(13,3) for quantities to match SAP standards.
4. **Account Assignment**: Always copy account assignment from source to target.
5. **Partial Conversion**: Support partial quantity conversion at every stage.
6. **Status Derivation**: Calculate header status from item statuses.
7. **Validation**: Validate open quantities before copy operations.
8. **Traceability**: Maintain mapping tables for full document chain visibility.
9. **Locking**: Use row-level locks during quantity updates to prevent race conditions.
10. **Transaction Scope**: Wrap copy operations in database transactions.

---

**Status**: Production-Ready Design  
**SAP Alignment**: MM-PUR Module Compatible  
**Last Updated**: 2025-01-XX
