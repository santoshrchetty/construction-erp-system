# Maintain Material Master - Sequence Diagram

## Search Material Flow

```
User                Frontend              API Route           Service Layer        Database
 |                     |                      |                     |                  |
 |--Click Tile-------->|                      |                     |                  |
 |                     |                      |                     |                  |
 |                     |--Load Component----->|                     |                  |
 |                     |                      |                     |                  |
 |                     |--GET Categories----->|                     |                  |
 |                     |                      |--Query Categories-->|                  |
 |                     |                      |                     |--SELECT-------->|
 |                     |                      |                     |<--Results-------|
 |                     |<--Categories---------|                     |                  |
 |                     |                      |                     |                  |
 |--Enter Code-------->|                      |                     |                  |
 |--Click Search------>|                      |                     |                  |
 |                     |                      |                     |                  |
 |                     |--POST /api/tiles---->|                     |                  |
 |                     |  {                   |                     |                  |
 |                     |   category: 'materials'                    |                  |
 |                     |   action: 'maintain-material'              |                  |
 |                     |   payload: {         |                     |                  |
 |                     |     material_id: 'CODE'                    |                  |
 |                     |   }                  |                     |                  |
 |                     |  }                   |                     |                  |
 |                     |                      |                     |                  |
 |                     |                      |--Authenticate------>|                  |
 |                     |                      |<--Auth Context------|                  |
 |                     |                      |                     |                  |
 |                     |                      |--getMaterialMaster->|                  |
 |                     |                      |  (materialCode)     |                  |
 |                     |                      |                     |                  |
 |                     |                      |                     |--SELECT * FROM--|
 |                     |                      |                     |  materials      |
 |                     |                      |                     |  WHERE code=... |
 |                     |                      |                     |<--Material Data-|
 |                     |                      |                     |                  |
 |                     |                      |<--Material Data-----|                  |
 |                     |                      |                     |                  |
 |                     |<--Response-----------|                     |                  |
 |                     |  {                   |                     |                  |
 |                     |   success: true      |                     |                  |
 |                     |   data: {            |                     |                  |
 |                     |     material: {...}  |                     |                  |
 |                     |   }                  |                     |                  |
 |                     |  }                   |                     |                  |
 |                     |                      |                     |                  |
 |<--Display Form------|                      |                     |                  |
 |  (All fields       |                      |                     |                  |
 |   populated)       |                      |                     |                  |
 |                     |                      |                     |                  |
```

## Update Material Flow

```
User                Frontend              API Route           Service Layer        Database
 |                     |                      |                     |                  |
 |--Edit Fields------->|                      |                     |                  |
 |--Click Update------>|                      |                     |                  |
 |                     |                      |                     |                  |
 |                     |--POST /api/tiles---->|                     |                  |
 |                     |  {                   |                     |                  |
 |                     |   category: 'materials'                    |                  |
 |                     |   action: 'maintain-material'              |                  |
 |                     |   payload: {         |                     |                  |
 |                     |     material_id: 'CODE'                    |                  |
 |                     |     material_name: 'New Name'              |                  |
 |                     |     description: '...'                     |                  |
 |                     |     ...              |                     |                  |
 |                     |   }                  |                     |                  |
 |                     |  }                   |                     |                  |
 |                     |                      |                     |                  |
 |                     |                      |--Authenticate------>|                  |
 |                     |                      |<--Auth Context------|                  |
 |                     |                      |                     |                  |
 |                     |                      |--updateMaterialMaster>                 |
 |                     |                      |  (code, data, userId)                  |
 |                     |                      |                     |                  |
 |                     |                      |                     |--UPDATE-------->|
 |                     |                      |                     |  materials      |
 |                     |                      |                     |  SET ...        |
 |                     |                      |                     |  WHERE code=... |
 |                     |                      |                     |<--Updated Data--|
 |                     |                      |                     |                  |
 |                     |                      |<--Updated Material--|                  |
 |                     |                      |                     |                  |
 |                     |<--Success Response---|                     |                  |
 |                     |  {                   |                     |                  |
 |                     |   success: true      |                     |                  |
 |                     |   data: {            |                     |                  |
 |                     |     material: {...}  |                     |                  |
 |                     |   }                  |                     |                  |
 |                     |  }                   |                     |                  |
 |                     |                      |                     |                  |
 |<--Show Success------|                      |                     |                  |
 |  Alert             |                      |                     |                  |
 |                     |                      |                     |                  |
 |                     |--Refresh Data------->|                     |                  |
 |                     |  (Re-fetch material) |                     |                  |
 |                     |                      |                     |                  |
```

## Parameter-Based Search Flow

```
User                Frontend              API Route           Service Layer        Database
 |                     |                      |                     |                  |
 |--Enter Name-------->|                      |                     |                  |
 |--Select Category--->|                      |                     |                  |
 |--Click Search------>|                      |                     |                  |
 |                     |                      |                     |                  |
 |                     |--GET /api/tiles----->|                     |                  |
 |                     |  ?category=materials |                     |                  |
 |                     |  &action=material-master                   |                  |
 |                     |  &search=cement      |                     |                  |
 |                     |  &material_category=CEMENT                 |                  |
 |                     |                      |                     |                  |
 |                     |                      |--getMaterialMaster->|                  |
 |                     |                      |  (undefined, 'cement', {              |
 |                     |                      |    category: 'CEMENT'                  |
 |                     |                      |  })                 |                  |
 |                     |                      |                     |                  |
 |                     |                      |                     |--SELECT * FROM--|
 |                     |                      |                     |  materials      |
 |                     |                      |                     |  WHERE name     |
 |                     |                      |                     |  ILIKE '%cement%'
 |                     |                      |                     |  AND category=  |
 |                     |                      |                     |  'CEMENT'       |
 |                     |                      |                     |  LIMIT 100      |
 |                     |                      |                     |<--Material List-|
 |                     |                      |                     |                  |
 |                     |                      |<--Materials Array---|                  |
 |                     |                      |                     |                  |
 |                     |<--Response-----------|                     |                  |
 |                     |  {                   |                     |                  |
 |                     |   success: true      |                     |                  |
 |                     |   data: {            |                     |                  |
 |                     |     materials: [...]  |                     |                  |
 |                     |   }                  |                     |                  |
 |                     |  }                   |                     |                  |
 |                     |                      |                     |                  |
 |<--Show Results------|                      |                     |                  |
 |  Modal             |                      |                     |                  |
 |  (Table with       |                      |                     |                  |
 |   Select buttons)  |                      |                     |                  |
 |                     |                      |                     |                  |
 |--Click Select------>|                      |                     |                  |
 |  on Material       |                      |                     |                  |
 |                     |                      |                     |                  |
 |                     |--Load Material------>|                     |                  |
 |                     |  (Direct code search)|                     |                  |
 |                     |                      |                     |                  |
```

## Component Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│ COMPONENT MOUNT                                             │
│ MaintainMaterialMaster()                                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ useEffect(() => {                                           │
│   loadCategories()    ──────> GET /api/materials/master-data│
│   loadMaterialTypes() ──────> GET /api/materials/master-data│
│ }, [])                                                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ RENDER SEARCH INTERFACE                                     │
│ - Direct code search input                                  │
│ - Parameter search form                                     │
│ - Empty form (waiting for search)                           │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ USER SEARCHES                                               │
│ - searchMaterial() OR searchByParameters()                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ MATERIAL LOADED                                             │
│ - setMaterial(data)                                         │
│ - setFormData(populated)                                    │
│ - loadGroups(category) if category exists                  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ useEffect(() => {                                           │
│   if (formData.category) {                                  │
│     loadGroups(formData.category)                           │
│   }                                                         │
│ }, [formData.category])                                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ RENDER EDIT FORM                                            │
│ - All sections populated                                    │
│ - Dependent dropdowns loaded                                │
│ - Update button enabled                                     │
└─────────────────────────────────────────────────────────────┘
```

## State Management Flow

```
Initial State:
├── searchCode: ''
├── searchParams: { material_name: '', category: '', material_type: '' }
├── searchResults: []
├── showSearchResults: false
├── material: null
├── categories: []
├── groups: []
├── materialTypes: []
├── loading: false
├── searching: false
├── saving: false
└── formData: { all fields empty }

After Search:
├── searchCode: 'CEMENT-001'
├── material: { ...materialData }
├── formData: { ...populated from material }
├── categories: [...loaded]
├── groups: [...loaded for category]
└── materialTypes: [...loaded]

After Update:
├── material: { ...updatedData }
├── formData: { ...refreshed }
└── saving: false
```

## Error Handling Flow

```
Try Block                    Catch Block                  Finally Block
    |                            |                             |
    |--API Call                  |                             |
    |                            |                             |
    |--Success?                  |                             |
    |   |                        |                             |
    |   Yes                      |                             |
    |   |                        |                             |
    |   |--Process Data          |                             |
    |   |--Update State          |                             |
    |   |--Show Success          |                             |
    |                            |                             |
    |   No                       |                             |
    |   |                        |                             |
    |   |--Throw Error---------->|--Catch Error                |
    |                            |--Log Error                  |
    |                            |--Show Alert                 |
    |                            |--Update Error State         |
    |                            |                             |
    |                            |                             |--setLoading(false)
    |                            |                             |--setSaving(false)
    |                            |                             |--setSearching(false)
```

---

*This sequence diagram shows the complete interaction flow between all layers of the Maintain Material Master functionality.*
