# Dynamic Stores System

## Overview
Advanced inventory management system with automatic store creation/deletion, FIFO tracking, and multi-site support.

## Key Features

### 1. Auto-Create Stores
- **Trigger**: When materials are received (GRN created)
- **Logic**: Creates store automatically if none exists for project/site
- **Naming**: `{SITE_CODE}-STORE-{YEAR}` (e.g., "MAIN-STORE-2024")
- **Properties**: Marked as `is_auto_created = true`

### 2. Auto-Delete Stores
- **Trigger**: When stock balance reaches zero
- **Logic**: Deactivates auto-created stores when empty
- **Safety**: Only affects stores with `auto_delete_when_empty = true`

### 3. FIFO Inventory Tracking
- **Method**: First-In-First-Out cost calculation
- **Layers**: Each receipt creates a FIFO layer with cost/quantity
- **Issues**: Automatically consume oldest stock first
- **Costing**: Real-time weighted average cost calculation

### 4. Multi-Site Support
- **Sites**: Projects can have multiple sites (`site_code`, `site_name`)
- **Stores**: Each site can have multiple stores
- **Transfers**: Stock can be transferred between sites
- **Isolation**: Stock is tracked separately per site

## Database Schema

### Enhanced Tables
```sql
-- Projects with site support
ALTER TABLE projects ADD COLUMN site_code VARCHAR(10);
ALTER TABLE projects ADD COLUMN site_name VARCHAR(255);

-- Enhanced stores
ALTER TABLE stores ADD COLUMN is_auto_created BOOLEAN DEFAULT false;
ALTER TABLE stores ADD COLUMN site_code VARCHAR(10);
ALTER TABLE stores ADD COLUMN auto_delete_when_empty BOOLEAN DEFAULT true;

-- FIFO tracking
CREATE TABLE stock_fifo_layers (
    id UUID PRIMARY KEY,
    store_id UUID REFERENCES stores(id),
    stock_item_id UUID REFERENCES stock_items(id),
    batch_reference VARCHAR(100),
    receipt_date TIMESTAMP,
    original_quantity DECIMAL(15,4),
    remaining_quantity DECIMAL(15,4),
    unit_cost DECIMAL(15,2),
    grn_line_id UUID REFERENCES grn_lines(id)
);
```

### Key Functions
- `auto_create_store_for_receipt()` - Auto-creates stores on material receipt
- `create_fifo_layer()` - Creates FIFO layers on stock receipt
- `process_fifo_issue()` - Processes stock issues using FIFO
- `auto_delete_empty_stores()` - Auto-deletes empty stores
- `create_stock_movement_with_fifo()` - Enhanced stock movement with FIFO

## API Actions

### Stock Issue (FIFO)
```typescript
await issueStockFIFO(formData)
// Automatically uses oldest stock first
// Calculates real cost based on FIFO layers
```

### Stock Transfer
```typescript
await transferStockBetweenSites(formData)
// Issues from source store (FIFO)
// Receives to destination store
// Maintains cost basis
```

### Store Management
```typescript
await getStoresByProject(projectId)
await getStoresBySite(projectId, siteCode)
await getAutoCreatedStores(projectId)
await getEmptyStores(projectId)
```

### FIFO Analytics
```typescript
await getFIFOStockBalances(storeId)
await getFIFOLayers(storeId, stockItemId)
```

## Usage Examples

### 1. Material Receipt (Auto-Store Creation)
```sql
-- When GRN is created, store is auto-created if needed
INSERT INTO grn_lines (grn_id, po_line_id, received_quantity, accepted_quantity, unit_rate)
VALUES ('grn-id', 'po-line-id', 100, 100, 25.00);
-- Triggers: auto_create_store_for_receipt() and create_fifo_layer()
```

### 2. Stock Issue (FIFO)
```typescript
const result = await issueStockFIFO({
  store_id: 'store-123',
  stock_item_id: 'item-456',
  quantity: 50,
  reference_number: 'ISSUE-001',
  reference_type: 'TASK',
  created_by: 'user-789'
})
// Uses oldest stock first, calculates actual cost
```

### 3. Inter-Site Transfer
```typescript
const result = await transferStockBetweenSites({
  from_store_id: 'store-site-a',
  to_store_id: 'store-site-b',
  stock_item_id: 'item-456',
  quantity: 25,
  reference_number: 'TRANSFER-001',
  created_by: 'user-789'
})
// Maintains FIFO costing across sites
```

## Benefits

### 1. Automation
- No manual store creation required
- Automatic cleanup of empty stores
- Reduced administrative overhead

### 2. Accurate Costing
- True FIFO cost calculation
- Real-time inventory valuation
- Proper cost allocation to projects

### 3. Multi-Site Management
- Centralized inventory across sites
- Easy stock transfers
- Site-specific reporting

### 4. Audit Trail
- Complete movement history
- FIFO layer tracking
- Cost basis documentation

## Monitoring

### Stock Levels
```sql
SELECT * FROM stock_balances_fifo WHERE store_id = 'store-123';
```

### FIFO Layers
```sql
SELECT * FROM stock_fifo_layers 
WHERE store_id = 'store-123' AND remaining_quantity > 0
ORDER BY receipt_date;
```

### Auto-Created Stores
```sql
SELECT * FROM stores 
WHERE is_auto_created = true AND is_active = true;
```

### Empty Stores (Candidates for Deletion)
```sql
SELECT s.* FROM stores s
LEFT JOIN stock_balances sb ON sb.store_id = s.id
WHERE s.auto_delete_when_empty = true
GROUP BY s.id
HAVING COALESCE(SUM(sb.current_quantity), 0) = 0;
```