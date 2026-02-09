# MR→PR→PO Gap Analysis

## ✅ Already Exists in Database

### Material Request (MR) - COMPLETE
- ✅ `material_requests` table (header)
- ✅ `material_request_items` table (line items)

**Existing Fields Match Requirements:**
- company_code, plant_code, project_code, wbs_element, activity_code, cost_center ✅
- request_number, request_type, requested_by, required_date, priority, status ✅
- purpose, justification, notes ✅
- Line items: material_code, requested_quantity, base_uom, line_number ✅

### Purchase Order (PO) - COMPLETE
- ✅ `purchase_orders` table (header) 
- ✅ `po_lines` table (line items)
- ✅ `goods_receipts` table (GR header)
- ✅ `grn_lines` table (GR line items)

## ❌ Missing Tables (Need to Create)

### 1. Purchase Requisition (PR) Tables
```sql
-- MISSING: PR Header
CREATE TABLE pr_headers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pr_number VARCHAR(20) UNIQUE NOT NULL,
  company_code VARCHAR(4) NOT NULL,
  purchasing_org VARCHAR(4) NOT NULL,
  purchase_group VARCHAR(3) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
  created_at TIMESTAMP DEFAULT NOW(),
  created_by VARCHAR(12),
  tenant_id UUID NOT NULL
);

-- MISSING: PR Items
CREATE TABLE pr_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
  
  -- Account Assignment
  project_code VARCHAR(24),
  wbs_element VARCHAR(24),
  activity_code VARCHAR(12),
  cost_center VARCHAR(10),
  
  -- Quantity Tracking
  pr_quantity DECIMAL(13,3) NOT NULL,
  open_quantity DECIMAL(13,3) NOT NULL,
  po_quantity DECIMAL(13,3) DEFAULT 0,
  item_status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
  
  tenant_id UUID NOT NULL,
  UNIQUE(pr_header_id, line_number)
);
```

### 2. MR→PR Mapping Table
```sql
-- MISSING: Track which MR items created which PR items
CREATE TABLE mr_pr_item_mapping (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  mr_item_id UUID NOT NULL REFERENCES material_request_items(id),
  pr_item_id UUID NOT NULL REFERENCES pr_items(id),
  quantity DECIMAL(13,3) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  tenant_id UUID NOT NULL
);
```

### 3. PR→PO Mapping Table
```sql
-- MISSING: Track which PR items created which PO items
CREATE TABLE pr_po_item_mapping (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pr_item_id UUID NOT NULL REFERENCES pr_items(id),
  po_item_id UUID NOT NULL REFERENCES po_lines(id),
  quantity DECIMAL(13,3) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  tenant_id UUID NOT NULL
);
```

### 4. Add Quantity Tracking to MR Items
```sql
-- MISSING: Add quantity tracking columns to material_request_items
ALTER TABLE material_request_items
ADD COLUMN open_quantity DECIMAL(13,3),
ADD COLUMN pr_quantity DECIMAL(13,3) DEFAULT 0,
ADD COLUMN item_status VARCHAR(20) DEFAULT 'OPEN';

-- Initialize existing records
UPDATE material_request_items 
SET open_quantity = requested_quantity,
    pr_quantity = 0,
    item_status = 'OPEN'
WHERE open_quantity IS NULL;
```

### 5. Add Quantity Tracking to PO Lines
```sql
-- MISSING: Add quantity tracking columns to po_lines
ALTER TABLE po_lines
ADD COLUMN open_quantity DECIMAL(13,3),
ADD COLUMN gr_quantity DECIMAL(13,3) DEFAULT 0,
ADD COLUMN item_status VARCHAR(20) DEFAULT 'OPEN';

-- Initialize existing records
UPDATE po_lines 
SET open_quantity = quantity,
    gr_quantity = 0,
    item_status = 'OPEN'
WHERE open_quantity IS NULL;
```

## 📊 Summary

| Component | Status | Action Required |
|-----------|--------|-----------------|
| MR Tables | ✅ Complete | None - already exists |
| PR Tables | ❌ Missing | Create 2 tables |
| PO Tables | ✅ Complete | Add 3 columns |
| MR→PR Mapping | ❌ Missing | Create 1 table |
| PR→PO Mapping | ❌ Missing | Create 1 table |
| MR Quantity Tracking | ⚠️ Partial | Add 3 columns |

## 🚀 Implementation Priority

1. **HIGH** - Create PR tables (pr_headers, pr_items)
2. **HIGH** - Create mapping tables (mr_pr_item_mapping, pr_po_item_mapping)
3. **HIGH** - Add quantity tracking to material_request_items
4. **MEDIUM** - Add quantity tracking to po_lines
5. **LOW** - Create copy functions (MR→PR, PR→PO)

## ⏱️ Estimated Implementation Time

- Database changes: 30 minutes
- Copy functions: 2 hours
- API endpoints: 3 hours
- UI components: 4 hours
- **Total: ~1 day**

---

**Next Step**: Run the SQL migrations to create missing tables and columns.
