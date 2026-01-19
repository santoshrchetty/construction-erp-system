# Material Request Dropdown APIs - Implementation Summary

## Phase 1: Master Data Verification ✅

### Database Tables Verified:
- ✅ `company_codes` - 1 record (C001)
- ✅ `plants` - 2 records (P001, P002)
- ✅ `cost_centers` - Active records available
- ✅ `projects` - Multiple projects available
- ✅ `materials` - 46 materials (via material_master_view)
- ✅ `storage_locations` - 5 locations across plants
- ✅ `vendors` - 5 vendors (VEN-001 to VEN-005)

### Key Findings:
- `material_master` table does NOT exist
- `material_master_view` exists with 46 materials (includes category_name, group_name, plant_count)
- `materials` base table has 46 active records
- Storage locations are properly linked to plants via `plant_id`

## Phase 2: API Endpoints Created ✅

### 1. Company Codes API
**Endpoint**: `GET /api/erp-config/companies`
**Returns**: `{ success: true, data: [{ id, company_code, company_name, currency }] }`
**File**: `app/api/erp-config/companies/route.ts`

### 2. Plants API (Cascading)
**Endpoint**: `GET /api/erp-config/plants?companyId={uuid}`
**Returns**: `{ success: true, data: [{ id, plant_code, plant_name, plant_type, company_code_id }] }`
**File**: `app/api/erp-config/plants/route.ts`
**Features**: Optional company filter for cascading dropdown

### 3. Storage Locations API (Cascading)
**Endpoint**: `GET /api/erp-config/storage-locations?plantId={uuid}`
**Returns**: `{ success: true, data: [{ id, sloc_code, sloc_name, location_type, plant_id }] }`
**File**: `app/api/erp-config/storage-locations/route.ts`
**Features**: Optional plant filter for cascading dropdown

### 4. Materials Search API (Enhanced)
**Endpoint**: `GET /api/materials?search={term}&withStock=true&plantId={uuid}&storageLocationId={uuid}&limit=20`
**Returns**: 
- Without stock: `{ success: true, data: [{ material_code, material_name, base_uom, standard_price, category_name, group_name }] }`
- With stock: Includes `material_storage_data` with `current_stock`, `reserved_stock`, `available_stock`
**File**: `app/api/materials/route.ts` (UPDATED)
**Features**: 
- Search by material code or name
- Optional stock availability info
- Filter by plant or storage location
- Uses `material_master_view` for simple search
- Uses `materials` table with joins for stock info

### 5. Existing APIs (Already Available)
- ✅ `/api/projects` - Get projects
- ✅ `/api/cost-centers` - Get cost centers
- ✅ `/api/vendors` - Get vendors

## API Usage Examples

### Cascading Dropdown Flow:
```javascript
// 1. Load companies
GET /api/erp-config/companies
→ Select company → companyId

// 2. Load plants for selected company
GET /api/erp-config/plants?companyId={companyId}
→ Select plant → plantId

// 3. Load storage locations for selected plant
GET /api/erp-config/storage-locations?plantId={plantId}
→ Select storage location → storageLocationId

// 4. Search materials with stock for selected location
GET /api/materials?search=cement&withStock=true&storageLocationId={storageLocationId}
→ Shows materials with available stock
```

### Material Search with Stock:
```javascript
// Search materials with stock availability
GET /api/materials?search=cement&withStock=true&plantId={plantId}

Response:
{
  "success": true,
  "data": [
    {
      "material_code": "MAT-001",
      "material_name": "Portland Cement 50kg",
      "base_uom": "BAG",
      "standard_price": 8.50,
      "material_storage_data": [
        {
          "current_stock": 100,
          "reserved_stock": 20,
          "available_stock": 80,
          "storage_locations": {
            "sloc_code": "0001",
            "sloc_name": "Main Warehouse"
          }
        }
      ]
    }
  ]
}
```

## Next Steps (Phase 3)

### Update Material Request Component:
1. Replace hardcoded dropdowns with API calls
2. Implement cascading logic (company → plant → storage location)
3. Add material autocomplete with stock display
4. Show available stock when material is selected
5. Add validation for insufficient stock

### Component Changes Needed:
- File: `components/tiles/UnifiedMaterialRequestComponent.tsx`
- Add state management for cascading dropdowns
- Implement API calls using fetch/axios
- Add loading states and error handling
- Display stock availability indicators

## Authorization
All endpoints use existing authorization middleware:
- Materials API requires: `MATERIAL_MASTER_READ` permission
- Other endpoints: No specific auth (use default project access)

## Database Schema Notes
- `materials` table is the base table (14 columns)
- `material_master_view` is a view with enriched data (12 columns including category_name, group_name)
- `material_storage_data` table links materials to storage locations with stock levels
- Cascading: company_codes → plants → storage_locations → material_storage_data
