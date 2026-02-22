# UnifiedMaterialRequestComponent - Option 3 Implementation

## Changes Required

### 1. Add State Variables (After line 50)

```typescript
// Add after existing state declarations
const [mrType, setMrType] = useState('')
const [mrTypes, setMrTypes] = useState([])
const [allowedAccountAssignments, setAllowedAccountAssignments] = useState([])
```

### 2. Load MR Types on Mount (Add to useEffect)

```typescript
useEffect(() => {
  loadProjectsOnDemand()
  loadMRTypes() // ADD THIS
}, [])

// Add this function
const loadMRTypes = async () => {
  try {
    const response = await fetch('/api/account-assignments?action=mrTypes')
    const data = await response.json()
    if (data.success) {
      setMrTypes(data.data || [])
    }
  } catch (error) {
    console.error('Failed to load MR types:', error)
  }
}
```

### 3. Handle MR Type Change

```typescript
const handleMRTypeChange = async (selectedMrType: string) => {
  setMrType(selectedMrType)
  setFormData(prev => ({ ...prev, mr_type: selectedMrType }))
  
  // Load allowed account assignments
  try {
    const response = await fetch(`/api/account-assignments?mrType=${selectedMrType}`)
    const data = await response.json()
    if (data.success) {
      setAllowedAccountAssignments(data.data || [])
      
      // Auto-populate default for all items
      const defaultAA = data.data?.find((a: any) => a.is_default)
      if (defaultAA) {
        setFormData(prev => ({
          ...prev,
          items: prev.items.map(item => ({
            ...item,
            account_assignment_code: defaultAA.code
          }))
        }))
      }
    }
  } catch (error) {
    console.error('Failed to load account assignments:', error)
  }
}
```

### 4. Replace "Requested for" Section (Lines ~600-650)

**REMOVE:**
```typescript
<div className="space-y-4">
  <div className="flex items-center justify-between">
    <div className="flex items-center space-x-2 text-lg font-semibold text-slate-800">
      <Icons.Target className="h-5 w-5 text-blue-600" />
      <span>Requested for</span>
    </div>
    ...
  </div>
  
  <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
    {accountAssignmentTypes.map(type => (
      <button ...>{type.name}</button>
    ))}
  </div>
  
  {/* Cost Center Assignment */}
  {formData.account_assignment === 'K' && (...)}
</div>
```

**REPLACE WITH:**
```typescript
<div className="space-y-4">
  <div className="flex items-center justify-between">
    <div className="flex items-center space-x-2 text-lg font-semibold text-slate-800">
      <Icons.FileText className="h-5 w-5 text-blue-600" />
      <span>Material Request Type</span>
    </div>
    <div className="flex items-center space-x-3">
      {formData.request_number && (
        <div className="text-sm text-slate-600">
          <span className="font-medium">MR Number:</span> {formData.request_number}
        </div>
      )}
      <div className={`px-3 py-1 rounded-full text-xs font-medium ${
        formState.status === 'DRAFT' ? 'bg-gray-100 text-gray-800' :
        formState.status === 'SUBMITTED' ? 'bg-blue-100 text-blue-800' :
        formState.status === 'APPROVED' ? 'bg-green-100 text-green-800' :
        'bg-red-100 text-red-800'
      }`}>
        {formState.status}
      </div>
    </div>
  </div>
  
  <div className="space-y-2">
    <label className="block text-sm font-medium text-slate-700">
      MR Type <span className="text-red-500">*</span>
    </label>
    <select 
      value={mrType}
      onChange={(e) => handleMRTypeChange(e.target.value)}
      disabled={formState.isReadOnly}
      className="w-full h-11 px-3 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 disabled:bg-slate-50"
    >
      <option value="">Select MR Type</option>
      {mrTypes.map((type: any) => (
        <option key={type.code} value={type.code}>{type.name}</option>
      ))}
    </select>
  </div>
</div>
```

### 5. Add Account Assignment Per Line Item (In Material Items section)

**ADD AFTER "Material" field (around line 750):**

```typescript
<div className="space-y-2">
  <label className="block text-sm font-medium text-slate-700">
    Cost Booked To <span className="text-red-500">*</span>
  </label>
  <select
    value={item.account_assignment_code || ''}
    onChange={(e) => updateMaterialItem(index, 'account_assignment_code', e.target.value)}
    className="w-full h-11 px-3 border border-slate-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
  >
    <option value="">Select...</option>
    {allowedAccountAssignments.map((aa: any) => (
      <option key={aa.code} value={aa.code}>
        {aa.name} {aa.is_default && '(Default)'}
      </option>
    ))}
  </select>
</div>

{/* Conditional fields based on account assignment */}
{item.account_assignment_code === 'CC' && (
  <div className="space-y-2">
    <label className="block text-sm font-medium text-slate-700">Cost Center *</label>
    <input
      value={item.cost_center || ''}
      onChange={(e) => updateMaterialItem(index, 'cost_center', e.target.value)}
      placeholder="Enter cost center"
      className="w-full h-11 px-3 border border-slate-300 rounded-md"
    />
  </div>
)}

{item.account_assignment_code === 'WB' && (
  <div className="space-y-2">
    <label className="block text-sm font-medium text-slate-700">WBS Element *</label>
    <input
      value={item.wbs_element || ''}
      onChange={(e) => updateMaterialItem(index, 'wbs_element', e.target.value)}
      placeholder="Enter WBS element"
      className="w-full h-11 px-3 border border-slate-300 rounded-md"
    />
  </div>
)}

{item.account_assignment_code === 'AS' && (
  <div className="space-y-2">
    <label className="block text-sm font-medium text-slate-700">Asset Number *</label>
    <input
      value={item.asset_number || ''}
      onChange={(e) => updateMaterialItem(index, 'asset_number', e.target.value)}
      placeholder="Enter asset number"
      className="w-full h-11 px-3 border border-slate-300 rounded-md"
    />
  </div>
)}

{(item.account_assignment_code === 'OM' || item.account_assignment_code === 'OP' || item.account_assignment_code === 'OQ') && (
  <div className="space-y-2">
    <label className="block text-sm font-medium text-slate-700">Order Number *</label>
    <input
      value={item.order_number || ''}
      onChange={(e) => updateMaterialItem(index, 'order_number', e.target.value)}
      placeholder="Enter order number"
      className="w-full h-11 px-3 border border-slate-300 rounded-md"
    />
  </div>
)}
```

### 6. Update MaterialRequestItem Interface

**In types/forms.ts or at top of component:**

```typescript
export interface MaterialRequestItem {
  line_number: number
  material_code: string
  material_name: string
  requested_quantity: number
  base_uom: string
  available_stock: number
  priority: string
  required_date: string
  // ADD THESE:
  account_assignment_code?: string
  cost_center?: string
  wbs_element?: string
  activity_code?: string
  asset_number?: string
  order_number?: string
}
```

### 7. Update Submit Handler

**In handleSubmit function, ensure mr_type is included:**

```typescript
const response = await fetch('/api/material-requests', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    ...formData,
    mr_type: mrType, // ADD THIS
    items: formData.items.map(item => ({
      ...item,
      // Account assignment fields already included
    }))
  })
})
```

## Summary of Changes

1. ✅ Replace icon buttons with MR Type dropdown
2. ✅ Load MR types from API
3. ✅ Load allowed account assignments when MR Type changes
4. ✅ Add account assignment dropdown per line item
5. ✅ Add conditional fields (Cost Center, WBS, Asset, Order Number)
6. ✅ Auto-populate default account assignment
7. ✅ Include account assignment in submit payload

## Testing

1. Open form → Select MR Type "PROJECT"
2. Should show WB and WA options in line items
3. Select WB → should show WBS Element field
4. Submit → verify mr_type and account_assignment_code saved

## Files to Update

- `components/features/materials/UnifiedMaterialRequestComponent.tsx`
- `types/forms.ts` (if MaterialRequestItem interface is there)
