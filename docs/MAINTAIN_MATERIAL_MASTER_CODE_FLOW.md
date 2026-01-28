# Maintain Material Master - Complete Code Flow

## Overview
This document traces the complete code flow for the "Maintain Material Master" tile functionality in the Construction ERP application.

---

## 1. USER INTERACTION FLOW

### Step 1: User Clicks Tile
**Location**: `components/layout/EnhancedConstructionTiles.tsx`

```typescript
// Lines 267-269
case 'Maintain Material Master':
case 'Material Master Maintenance':
  return <MaintainMaterialMaster />
```

**What Happens**:
- User clicks on "Maintain Material Master" or "Material Master Maintenance" tile
- `handleTileClick()` sets `activeComponent` state
- Component lazy-loads `MaintainMaterialMaster` from `MaterialMasterComponents.tsx`

---

## 2. COMPONENT INITIALIZATION

### Step 2: Component Loads
**Location**: `components/features/materials/MaterialMasterComponents.tsx`

```typescript
export function MaintainMaterialMaster() {
  // State initialization
  const [searchCode, setSearchCode] = useState('')
  const [material, setMaterial] = useState(null)
  const [formData, setFormData] = useState({...})
  
  // Load master data on mount
  useEffect(() => {
    loadCategories()
    loadMaterialTypes()
  }, [])
}
```

**What Happens**:
- Component initializes with empty state
- Loads categories and material types from API
- Displays search interface

---

## 3. SEARCH MATERIAL FLOW

### Step 3A: Direct Code Search
**Frontend**: `MaterialMasterComponents.tsx`

```typescript
const searchMaterial = async (codeToSearch = null) => {
  const code = codeToSearch || searchCode
  if (!code) return
  setLoading(true)
  
  const response = await fetch('/api/tiles', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      category: 'materials',
      action: 'maintain-material',
      payload: { material_id: code }
    })
  })
}
```

### Step 3B: Parameter-Based Search
**Frontend**: `MaterialMasterComponents.tsx`

```typescript
const searchByParameters = async () => {
  const params = new URLSearchParams({
    category: 'materials',
    action: 'material-master'
  })
  
  if (searchParams.material_name) params.append('search', searchParams.material_name)
  if (searchParams.category) params.append('material_category', searchParams.category)
  if (searchParams.material_type) params.append('material_type', searchParams.material_type)
  
  const response = await fetch(`/api/tiles?${params.toString()}`)
}
```

---

## 4. API ROUTING

### Step 4: API Route Handler
**Location**: `app/api/tiles/route.ts`

#### For Direct Search (POST):
```typescript
// Lines 435-467
if (body.action === 'maintain-material') {
  if (body.payload.material_id && !body.payload.material_name) {
    // Search for material
    const materials = await getMaterialMaster(body.payload.material_id)
    const material = materials[0]
    
    if (!material) {
      return NextResponse.json({
        success: false,
        error: 'Material not found'
      }, { status: 404 })
    }

    return NextResponse.json({
      success: true,
      data: { material }
    })
  } else {
    // Update material
    const data = await updateMaterialMaster(
      body.payload.material_id,
      { material_name, description },
      authContext.userId
    )
  }
}
```

#### For Parameter Search (GET):
```typescript
// Lines 107-122
if (category === 'materials' && action === 'material-master') {
  const { getMaterialMaster } = await import('@/domains/materials/materialMasterService')
  
  const materialCategory = searchParams.get('material_category')
  const materialType = searchParams.get('material_type')
  
  const data = await getMaterialMaster(undefined, search || undefined, {
    category: materialCategory,
    material_type: materialType
  })
  
  return NextResponse.json({
    success: true,
    data: { materials: data }
  })
}
```

---

## 5. SERVICE LAYER

### Step 5: Material Master Service
**Location**: `domains/materials/materialMasterService.ts`

#### Get Material Master:
```typescript
export async function getMaterialMaster(
  materialCode?: string, 
  searchTerm?: string, 
  filters?: { category?: string, material_type?: string }
) {
  const supabase = await createServiceClient()
  
  let query = supabase
    .from('materials')
    .select('*')
    .eq('is_active', true)
    .order('material_code')

  if (materialCode) {
    query = query.eq('material_code', materialCode)
  } else {
    if (searchTerm) {
      query = query.ilike('material_name', `%${searchTerm}%`)
    }
    if (filters?.category) {
      query = query.eq('category', filters.category)
    }
    if (filters?.material_type) {
      query = query.eq('material_type', filters.material_type)
    }
  }

  const { data, error } = await query.limit(100)
  if (error) throw error
  return data || []
}
```

#### Update Material Master:
```typescript
export async function updateMaterialMaster(
  materialCode: string, 
  payload: Partial<MaterialMaster>, 
  userId: string
) {
  const supabase = await createServiceClient()
  
  const { data, error } = await supabase
    .from('materials')
    .update({
      ...payload,
      updated_by: userId,
      updated_at: new Date().toISOString()
    })
    .eq('material_code', materialCode)
    .select()
    .single()

  if (error) throw error
  return data
}
```

---

## 6. DATABASE LAYER

### Step 6: Database Tables

#### Primary Table: `materials`
```sql
CREATE TABLE materials (
  id UUID PRIMARY KEY,
  material_code VARCHAR(31) UNIQUE NOT NULL,
  material_name VARCHAR(240) NOT NULL,
  description TEXT,
  category VARCHAR(50),
  material_group VARCHAR(50),
  base_uom VARCHAR(10) NOT NULL,
  material_type VARCHAR(10) NOT NULL,
  weight_unit VARCHAR(10),
  gross_weight DECIMAL(15,3),
  net_weight DECIMAL(15,3),
  volume_unit VARCHAR(10),
  volume DECIMAL(15,3),
  is_active BOOLEAN DEFAULT true,
  created_by UUID,
  updated_by UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### Supporting Tables:
- `material_categories` - Category master data
- `material_groups` - Group master data
- `material_types` - Material type definitions

---

## 7. RESPONSE FLOW

### Step 7: Data Returns to Frontend
**Location**: `MaterialMasterComponents.tsx`

```typescript
const data = await response.json()
if (data.success && data.data.material) {
  const mat = data.data.material
  setMaterial(mat)
  
  // Populate form data
  setFormData({
    material_name: mat.material_name || '',
    description: mat.description || '',
    category: mat.category || '',
    material_group: mat.material_group || '',
    base_uom: mat.base_uom || '',
    material_type: mat.material_type || '',
    weight_unit: mat.weight_unit || '',
    gross_weight: mat.gross_weight || 0,
    net_weight: mat.net_weight || 0,
    volume_unit: mat.volume_unit || '',
    volume: mat.volume || 0
  })
  
  // Load dependent dropdowns
  if (mat.category) {
    await loadGroups(mat.category)
  }
}
```

---

## 8. UPDATE FLOW

### Step 8: User Updates Material
**Frontend**: `MaterialMasterComponents.tsx`

```typescript
const updateMaterial = async () => {
  if (!material) return
  setSaving(true)
  
  const response = await fetch('/api/tiles', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      category: 'materials',
      action: 'maintain-material',
      payload: { 
        material_id: material.material_code,
        ...formData
      }
    })
  })
  
  const data = await response.json()
  if (data.success) {
    alert('Material updated successfully!')
    await searchMaterial() // Refresh data
  }
}
```

---

## COMPLETE FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────┐
│ 1. USER CLICKS TILE                                         │
│    EnhancedConstructionTiles.tsx                            │
│    - handleTileClick('Maintain Material Master')           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. COMPONENT LOADS                                          │
│    MaterialMasterComponents.tsx                             │
│    - MaintainMaterialMaster()                               │
│    - Load categories & material types                       │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. USER SEARCHES MATERIAL                                   │
│    - Direct code search OR                                  │
│    - Parameter-based search                                 │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. API REQUEST                                              │
│    POST /api/tiles                                          │
│    {                                                        │
│      category: 'materials',                                 │
│      action: 'maintain-material',                           │
│      payload: { material_id: 'CODE' }                       │
│    }                                                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. API ROUTE HANDLER                                        │
│    app/api/tiles/route.ts                                   │
│    - Authenticate user (withAuth)                           │
│    - Route to material handler                              │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. SERVICE LAYER                                            │
│    materialMasterService.ts                                 │
│    - getMaterialMaster(materialCode)                        │
│    - Query database                                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. DATABASE QUERY                                           │
│    Supabase PostgreSQL                                      │
│    SELECT * FROM materials                                  │
│    WHERE material_code = 'CODE'                             │
│    AND is_active = true                                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 8. RESPONSE RETURNS                                         │
│    { success: true, data: { material: {...} } }            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ 9. FRONTEND UPDATES                                         │
│    - setMaterial(data)                                      │
│    - Populate form fields                                   │
│    - Load dependent dropdowns                               │
│    - Enable edit mode                                       │
└─────────────────────────────────────────────────────────────┘
```

---

## KEY FEATURES

### 1. Search Capabilities
- **Direct Code Search**: Enter material code and load instantly
- **Parameter Search**: Search by name, category, or type
- **Search Results Modal**: Select from multiple matches

### 2. Form Sections
- **Basic Information**: Code, name, description
- **Classification**: Category, group, material type
- **Units of Measure**: Base UOM, weight unit, volume unit
- **Physical Properties**: Gross weight, net weight, volume

### 3. Data Validation
- Required fields marked with asterisk (*)
- Material code auto-uppercase
- Dependent dropdowns (groups based on category)
- Real-time form validation

### 4. Update Operations
- Auto-populate all fields from database
- Track changes with updated_by and updated_at
- Refresh data after successful update
- Clear form functionality

---

## SECURITY & AUTHORIZATION

### Authentication Flow
```typescript
// app/api/tiles/route.ts
const authContext = await withAuth(request, Module.COSTING, Permission.VIEW)
```

### Authorization Checks
1. User must be authenticated
2. User must have access to Materials module
3. User must have VIEW permission for search
4. User must have EDIT permission for updates

---

## ERROR HANDLING

### Frontend Error Handling
```typescript
try {
  const response = await fetch('/api/tiles', {...})
  const data = await response.json()
  if (data.success) {
    // Success handling
  } else {
    alert('Error: ' + data.error)
  }
} catch (error) {
  alert('Error: ' + error.message)
}
```

### Backend Error Handling
```typescript
// Service layer throws errors
if (error) throw error

// API layer catches and formats
catch (error) {
  return NextResponse.json({
    error: 'Operation failed',
    details: error.message
  }, { status: 500 })
}
```

---

## PERFORMANCE OPTIMIZATIONS

1. **Lazy Loading**: Component loaded only when needed
2. **Query Limits**: Maximum 100 results per search
3. **Indexed Queries**: Database indexes on material_code
4. **Dependent Loading**: Groups loaded only when category selected
5. **Debounced Search**: Prevents excessive API calls

---

## RELATED COMPONENTS

- **Create Material Master**: Creates new materials
- **Display Material Master**: Read-only view with search
- **Extend Material to Plant**: Plant-specific extensions
- **Material Plant Parameters**: Plant-level settings
- **Material Pricing**: Price management

---

## API ENDPOINTS SUMMARY

| Method | Endpoint | Action | Purpose |
|--------|----------|--------|---------|
| POST | /api/tiles | maintain-material (search) | Get material by code |
| POST | /api/tiles | maintain-material (update) | Update material data |
| GET | /api/tiles | material-master | Search materials by params |
| GET | /api/materials/master-data | categories | Get categories |
| GET | /api/materials/master-data | groups | Get groups |
| GET | /api/materials/master-data | material-types | Get types |

---

## TESTING CHECKLIST

- [ ] Search by material code
- [ ] Search by material name
- [ ] Search by category
- [ ] Search by material type
- [ ] Combined parameter search
- [ ] Update material name
- [ ] Update description
- [ ] Change category (reload groups)
- [ ] Update physical properties
- [ ] Clear form functionality
- [ ] Error handling for not found
- [ ] Authorization checks
- [ ] Concurrent user updates

---

## FUTURE ENHANCEMENTS

1. **Audit Trail**: Track all changes with history
2. **Bulk Update**: Update multiple materials at once
3. **Field-Level Permissions**: Control which fields users can edit
4. **Workflow Integration**: Approval process for changes
5. **Change Comparison**: Show before/after values
6. **Export Functionality**: Export material data
7. **Advanced Search**: More filter options
8. **Recent Materials**: Quick access to recently viewed

---

*Document Version: 1.0*  
*Last Updated: 2024*  
*Maintained by: Development Team*
