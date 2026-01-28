# Material Fields Usage Analysis - Audit Report

## 📊 Summary

The material master data endpoints are **selecting all fields** but several new fields from the recent schema updates are **not being fully utilized in the business logic**.

---

## ✅ Fields Being Used

### In `materials` table (Current Schema)

| Field                | Used In                       | Status  | Notes                                   |
| -------------------- | ----------------------------- | ------- | --------------------------------------- |
| `id`                 | ✅ All queries                | Used    | Primary key                             |
| `material_code`      | ✅ getMaterialMaster, filters | Used    | Search & filter                         |
| `material_name`      | ✅ getMaterialMaster, search  | Used    | Text search                             |
| `description`        | ✅ Select \*                  | Used    | Displayed                               |
| `base_uom`           | ✅ getMaterialPlantData       | Used    | Plant data                              |
| `material_type`      | ✅ Filters                    | Used    | Type filtering                          |
| `is_active`          | ✅ All queries                | Used    | Active filter                           |
| `created_at`         | ✅ Select \*                  | Used    | Audit                                   |
| `category`           | ✅ Filters                    | Used    | Category filtering                      |
| `material_group`     | ⚠️ Select \* only             | Partial | **Not used in filtering/display logic** |
| `valuation_class_id` | ⚠️ Select \* only             | Partial | **Not used in queries**                 |

---

## ⚠️ Fields Not Fully Utilized

### Material Valuation & Pricing (NEW)

```typescript
// Current: Not referenced in getMaterialCategories/getMaterialGroups
valuation_class_id UUID  // ❌ Not used
material_group VARCHAR   // ❌ Not used in business logic
```

**Missing Queries**:

```typescript
// ❌ NOT IMPLEMENTED
export async function getMaterialValuationClasses();
export async function getMaterialByValuationClass(classId: string);
export async function getMaterialsByGroup(groupCode: string);
```

### Material Plant Data (PARTIAL)

```typescript
// Current: Basic selection
.select(`
  *,
  materials!inner (material_name, category, base_uom)  // ✅ Some related fields
`)
```

**Missing Fields Not Being Loaded**:

- `reorder_point` - Not used in reorder logic
- `safety_stock` - Not used in safety calculations
- `planned_delivery_time` - Not used for scheduling
- `standard_price` - Not used for costing
- `valuation_method` - Not used for FIFO/LIFO logic
- `abc_classification_code` - Not used for ABC analysis

---

## 🔍 Current API Usage

### `/api/materials/master-data?type=categories`

```typescript
// ✅ WORKING: Returns all fields from material_categories
.select('*')
.eq('is_active', true)
.order('category_name')
```

**Returned Fields**:

```json
{
  "category_code": "RAW",
  "category_name": "Raw Materials",
  "description": "...",
  "parent_category": "...",
  "is_active": true,
  "created_at": "..."
}
```

### `/api/materials/master-data?type=groups`

```typescript
// ✅ WORKING: Returns all fields from material_groups
.select('*')
.eq('is_active', true)
.order('group_name')
```

**Returned Fields**:

```json
{
  "id": "...",
  "group_code": "STEEL",
  "group_name": "Steel Products",
  "description": "...",
  "category_code": "RAW", // ✅ Related
  "is_active": true,
  "created_at": "..."
}
```

### `/api/materials/master-data?type=material-types`

```typescript
// ✅ WORKING: Returns all fields from material_types
.select('*')
.eq('is_active', true)
.order('material_type_name')
```

---

## ❌ Missing Implementations

### 1. Valuation Classes Not Being Used

```typescript
// Current endpoint returns it but no business logic
GET /api/materials/master-data?type=valuation-classes

// Missing:
// - Pricing calculations using valuation method
// - Moving average vs standard price logic
// - GL account determination from class
```

### 2. Material-to-Valuation-Class Relationship Unused

```typescript
// In materials table:
valuation_class_id UUID  // ❌ Selected but never used

// Should be used for:
// - Cost accounting
// - Price variance reporting
// - GL account assignment
```

### 3. Material Group Hierarchy Not Used

```typescript
// Current: Just returns list
getMaterialGroups(categoryCode);

// Missing:
// - Tree structure (parent-child)
// - ABC classification analysis
// - Procurement type by group
// - Lead time defaults by group
```

### 4. Plant Data Relationships Incomplete

```typescript
// Current: Gets material_plant_data with basic joins
.select(`
  *,
  materials!inner (material_name, category, base_uom)
`)

// Missing joins:
// - plants(plant_code, plant_name)
// - storage_locations(sloc_code, sloc_name)
// - valuation_classes(class_name)
// - units_of_measure(uom_name)
```

---

## 📋 Required Enhancements

### Priority 1: Critical (Blocking Functionality)

**1.1 - Enhance Material Queries with All Fields**

```typescript
// Current ❌
.select('*')

// Should be ✅
.select(`
  *,
  material_types(material_type_name, description),
  valuation_classes(class_name, valuation_method),
  material_groups(group_name, category_code)
`)
```

**1.2 - Add Material Pricing Service**

```typescript
// Missing completely
export async function getMaterialPricingByVendor(
  materialCode: string,
  vendorCode: string,
) {
  // Get current price from material_prices table
  // Apply quantity breaks
  // Handle currency conversion
}
```

**1.3 - Implement Valuation Logic**

```typescript
// Missing: Used for costing
export async function calculateMaterialCost(
  materialCode: string,
  quantity: number,
  valuationMethod?: string, // Standard, Moving Avg, FIFO, LIFO
) {
  // Look up valuation_class_id
  // Apply valuation method
  // Return calculated cost
}
```

### Priority 2: Important (Improves Functionality)

**2.1 - Enhance Plant Data Queries**

```typescript
export async function getMaterialPlantDataEnhanced(
  materialCode: string,
  plantCode?: string,
) {
  return supabase
    .from("material_plant_data")
    .select(
      `
      *,
      materials(
        material_name,
        category,
        base_uom,
        valuation_classes(class_name, valuation_method)
      ),
      plants(plant_name, address),
      storage_locations(sloc_name, location_type)
    `,
    )
    .eq("material_code", materialCode);
}
```

**2.2 - Material Group Hierarchy**

```typescript
export async function getMaterialGroupHierarchy(categoryCode?: string) {
  // Build tree structure
  // Include ABC classification
  // Return parent-child relationships
}
```

**2.3 - ABC Analysis**

```typescript
export async function getMaterialsABCAnalysis(plantCode: string) {
  // Group materials by abc_classification_code
  // Calculate stock value distribution
  // Return analysis by group
}
```

### Priority 3: Nice-to-Have (Enhances UX)

**3.1 - Material Search with Related Data**

```typescript
export async function searchMaterialsEnhanced(searchTerm: string) {
  // Search across multiple fields
  // Include pricing info
  // Include stock levels
  // Include valuation class
}
```

**3.2 - Supplier Material Mapping** (when added to schema)

```typescript
export async function getMaterialSuppliers(materialCode: string) {
  // Get all suppliers for material
  // Show lead times
  // Show pricing
  // Show quality ratings
}
```

---

## 🔧 Quick Fix: Update Service Functions

### Current Issues to Fix

```typescript
// Issue 1: getMaterialMaster doesn't select related data
❌ .select('*')
✅ .select(`
     *,
     material_types(material_type_name),
     valuation_classes(class_name, class_code),
     material_groups(group_name)
   `)

// Issue 2: getMaterialPlantData missing plant/storage relations
❌ materials!inner (material_name, category, base_uom)
✅ materials!inner(
     material_name,
     category,
     base_uom,
     valuation_classes(class_name, valuation_method)
   ),
   plants(plant_name, plant_code),
   storage_locations(sloc_name, location_type)

// Issue 3: No pricing queries
❌ NOT IMPLEMENTED
✅ material_prices(
     price,
     currency_code,
     vendor_code,
     valid_from,
     valid_to
   )
```

---

## 📊 Fields by Table - Complete Audit

### ✅ material_categories

```
✅ category_code - Used
✅ category_name - Used
✅ description - Used
⚠️ parent_category - Selected but not used in hierarchy logic
✅ is_active - Used
✅ created_at - Used
```

### ✅ material_types

```
✅ id - Used
✅ material_type_code - Used
✅ material_type_name - Used
✅ description - Used
⚠️ inventory_managed - Selected but not used
⚠️ quantity_update - Selected but not used
⚠️ value_update - Selected but not used
✅ is_active - Used
```

### ✅ valuation_classes

```
✅ id - Used
✅ class_code - Used
✅ class_name - Used
✅ description - Used
✅ is_active - Used
✅ created_at - Used
```

### ✅ material_groups

```
✅ id - Used
✅ group_code - Used
✅ group_name - Used
✅ description - Used
⚠️ category_code - Foreign key exists but not used in filtering
✅ is_active - Used
✅ created_at - Used
```

### ⚠️ materials

```
✅ id - Used
✅ material_code - Used
✅ material_name - Used
✅ description - Used
✅ base_uom - Used
✅ material_type - Used for filtering
⚠️ valuation_class_id - Selected but NOT used in costing logic
⚠️ category - Used for filtering but not joined
⚠️ material_group - Selected but NOT used
✅ is_active - Used
✅ created_at - Used
```

### ❌ material_plant_data (Partial Implementation)

```
❌ Missing: Reorder point logic
❌ Missing: Safety stock calculations
❌ Missing: Lead time scheduling
❌ Missing: ABC classification analysis
❌ Missing: Standard price usage
❌ Missing: Valuation method logic
```

### ❌ material_prices (Not Using)

```
❌ Price lookups
❌ Quantity break pricing
❌ Vendor-specific pricing
❌ Currency conversion
```

---

## 🎯 Recommendation

**Implement in this order**:

1. ✅ **DONE**: Endpoint returns latest fields
2. ⚠️ **NEEDED**: Enhance SELECT statements to include all related data (joins)
3. ⚠️ **NEEDED**: Add valuation class to costing calculations
4. ⚠️ **NEEDED**: Add material pricing lookups
5. ⚠️ **NEEDED**: Implement ABC classification analysis
6. ⚠️ **NEEDED**: Implement reorder point logic

**Estimated effort**: 1-2 days
**Impact**: Medium-High (enables proper cost accounting)

---

## Example: Complete Material Query (What It Should Be)

```typescript
export async function getMaterialMasterComplete(
  materialCode?: string,
  filters?: { category?: string; material_type?: string },
) {
  const supabase = createServiceClient();

  let query = supabase
    .from("materials")
    .select(
      `
      id,
      material_code,
      material_name,
      description,
      base_uom,
      category,
      material_group,
      is_active,
      created_at,
      material_type,
      valuation_class_id,
      material_types!inner(
        id,
        material_type_code,
        material_type_name,
        inventory_managed,
        quantity_update,
        value_update
      ),
      material_groups(
        id,
        group_code,
        group_name,
        category_code
      ),
      valuation_classes(
        id,
        class_code,
        class_name,
        valuation_method
      )
    `,
    )
    .eq("is_active", true)
    .order("material_code");

  if (materialCode) {
    query = query.eq("material_code", materialCode);
  } else {
    if (filters?.category) query = query.eq("category", filters.category);
    if (filters?.material_type)
      query = query.eq("material_type", filters.material_type);
  }

  const { data, error } = await query.limit(100);
  if (error) throw error;
  return data || [];
}
```

This would return complete, normalized material data ready for display and business logic processing.
