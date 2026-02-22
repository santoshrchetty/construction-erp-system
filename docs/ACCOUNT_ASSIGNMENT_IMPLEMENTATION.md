# Account Assignment Implementation Guide
## For MR, PR, and PO

## Overview
Implement line-item level "Cost Booked To" (account assignment) for Material Requests, Purchase Requisitions, and Purchase Orders.

## Database Setup (Run in Supabase SQL Editor)

```sql
-- File: database/init_account_assignment.sql
-- Already created - run this in Supabase SQL Editor
```

## Implementation Steps

### STEP 1: Add MR Type Selection to Form

**Location**: `UnifiedMaterialRequestComponent.tsx`

**Add state**:
```typescript
const [mrTypes, setMRTypes] = useState([])
const [mrType, setMRType] = useState('')
const [accountAssignmentTypes, setAccountAssignmentTypes] = useState([])
```

**Add to form header** (after "Requested for" section):
```tsx
<div className="space-y-2">
  <label className="block text-sm font-medium text-slate-700">
    MR Type <span className="text-red-500">*</span>
  </label>
  <select 
    value={mrType}
    onChange={(e) => {
      setMRType(e.target.value)
      loadAccountAssignments(e.target.value)
    }}
    className="w-full h-11 px-3 border border-slate-300 rounded-md"
  >
    <option value="">Select MR Type</option>
    <option value="PROJECT">Project Materials</option>
    <option value="MAINTENANCE">Maintenance</option>
    <option value="GENERAL">General Supplies</option>
    <option value="ASSET">Asset Purchase</option>
    <option value="OFFICE">Office Supplies</option>
    <option value="SAFETY">Safety Equipment</option>
    <option value="EQUIPMENT">Equipment</option>
  </select>
</div>
```

### STEP 2: Add Account Assignment Per Line Item

**Update MaterialRequestItem interface**:
```typescript
interface MaterialRequestItem {
  line_number: number
  material_code: string
  material_name: string
  requested_quantity: number
  base_uom: string
  available_stock: number
  priority: string
  required_date: string
  // NEW FIELDS
  account_assignment_code?: string  // CC, WB, AS, WA, OM, OP, OQ
  cost_center?: string
  wbs_element?: string
  activity_code?: string
  asset_number?: string
  order_number?: string
}
```

**Add to each line item row** (in Material Items section):
```tsx
<div className="md:col-span-2 space-y-2">
  <label className="block text-sm font-medium text-slate-700">
    Cost Booked To <span className="text-red-500">*</span>
  </label>
  <select
    value={item.account_assignment_code || ''}
    onChange={(e) => updateMaterialItem(index, 'account_assignment_code', e.target.value)}
    className="w-full h-11 px-3 border border-slate-300 rounded-md"
  >
    <option value="">Select...</option>
    {accountAssignmentTypes.map(type => (
      <option key={type.code} value={type.code}>
        {type.name}
      </option>
    ))}
  </select>
</div>

{/* Conditional fields based on account assignment */}
{item.account_assignment_code === 'CC' && (
  <div className="space-y-2">
    <label className="block text-sm font-medium text-slate-700">
      Cost Center <span className="text-red-500">*</span>
    </label>
    <select
      value={item.cost_center || ''}
      onChange={(e) => updateMaterialItem(index, 'cost_center', e.target.value)}
      className="w-full h-11 px-3 border border-slate-300 rounded-md"
    >
      <option value="">Select cost center</option>
      {costCenters.map(cc => (
        <option key={cc.cost_center_code} value={cc.cost_center_code}>
          {cc.cost_center_code} - {cc.cost_center_name}
        </option>
      ))}
    </select>
  </div>
)}

{item.account_assignment_code === 'WB' && (
  <div className="space-y-2">
    <label className="block text-sm font-medium text-slate-700">
      WBS Element <span className="text-red-500">*</span>
    </label>
    <select
      value={item.wbs_element || ''}
      onChange={(e) => updateMaterialItem(index, 'wbs_element', e.target.value)}
      className="w-full h-11 px-3 border border-slate-300 rounded-md"
    >
      <option value="">Select WBS</option>
      {wbsElements.map(wbs => (
        <option key={wbs.id} value={wbs.code}>
          {wbs.code} - {wbs.name}
        </option>
      ))}
    </select>
  </div>
)}

{item.account_assignment_code === 'AS' && (
  <div className="space-y-2">
    <label className="block text-sm font-medium text-slate-700">
      Asset Number <span className="text-red-500">*</span>
    </label>
    <input
      value={item.asset_number || ''}
      onChange={(e) => updateMaterialItem(index, 'asset_number', e.target.value)}
      placeholder="Enter asset number"
      className="w-full h-11 px-3 border border-slate-300 rounded-md"
    />
  </div>
)}
```

### STEP 3: Load Account Assignment Options

**Add function**:
```typescript
const loadAccountAssignments = async (mrType: string) => {
  try {
    const response = await fetch(`/api/account-assignments?mrType=${mrType}`)
    const data = await response.json()
    if (data.success) {
      setAccountAssignmentTypes(data.data)
      
      // Auto-select default
      const defaultType = data.data.find((t: any) => t.is_default)
      if (defaultType) {
        // Apply to all items
        setFormData(prev => ({
          ...prev,
          items: prev.items.map(item => ({
            ...item,
            account_assignment_code: defaultType.code
          }))
        }))
      }
    }
  } catch (error) {
    console.error('Failed to load account assignments:', error)
  }
}
```

### STEP 4: Update Material Request Service

**Location**: `domains/materials/unifiedMaterialRequestService.ts`

**Update createMaterialRequest**:
```typescript
// In itemsToInsert mapping, add:
const itemsToInsert = request.items.map((item: any, index: number) => ({
  request_id: requestData.id,
  line_number: item.line_number || index + 1,
  material_code: item.material_code,
  material_name: item.material_name,
  requested_quantity: item.requested_quantity,
  base_uom: item.base_uom,
  required_date: item.required_date,
  priority: item.priority,
  // NEW: Account assignment fields
  account_assignment_code: item.account_assignment_code,
  cost_center: item.cost_center,
  wbs_element: item.wbs_element,
  activity_code: item.activity_code,
  asset_number: item.asset_number,
  order_number: item.order_number,
  tenant_id: tenantId
}))
```

### STEP 5: Display in MR List

**Location**: `MaterialRequestList.tsx` or approval component

**Add columns**:
```typescript
{
  key: 'account_assignment',
  label: 'Cost Booked To',
  visible: true
},
{
  key: 'cost_object',
  label: 'Cost Object',
  visible: true
}
```

**Render**:
```tsx
<td>{getAccountAssignmentName(item.account_assignment_code)}</td>
<td>{getCostObject(item)}</td>
```

**Helper functions**:
```typescript
const getAccountAssignmentName = (code: string) => {
  const names: Record<string, string> = {
    'CC': 'Cost Center',
    'WB': 'Project (WBS)',
    'AS': 'Asset',
    'WA': 'WBS + Activity',
    'OM': 'Maintenance Order',
    'OP': 'Production Order',
    'OQ': 'Quality Order'
  }
  return names[code] || code
}

const getCostObject = (item: any) => {
  if (item.cost_center) return item.cost_center
  if (item.wbs_element) return item.wbs_element
  if (item.asset_number) return item.asset_number
  if (item.order_number) return item.order_number
  return '-'
}
```

### STEP 6: PR Auto-Creation (After MR Approval)

**Create function** in `domains/materials/stockCheckService.ts`:
```typescript
export async function createPRFromMR(mrId: string, mrItemId: string, shortageQty: number) {
  const supabase = await createServiceClient()
  
  // Get MR item with account assignment
  const { data: mrItem } = await supabase
    .from('material_request_items')
    .select('*')
    .eq('id', mrItemId)
    .single()
  
  // Get MR header
  const { data: mr } = await supabase
    .from('material_requests')
    .select('*')
    .eq('id', mrId)
    .single()
  
  // Create PR header
  const prNumber = await generatePRNumber(mr.company_code)
  const { data: pr } = await supabase
    .from('purchase_requisitions')
    .insert({
      pr_number: prNumber,
      mr_id: mrId,
      company_code: mr.company_code,
      plant_code: mr.plant_code,
      status: 'DRAFT',
      tenant_id: mr.tenant_id
    })
    .select()
    .single()
  
  // Create PR item with account assignment copied from MR
  await supabase
    .from('purchase_requisition_items')
    .insert({
      pr_id: pr.id,
      mr_item_id: mrItemId,
      line_number: mrItem.line_number,
      material_code: mrItem.material_code,
      quantity: shortageQty,  // Only shortage, not full quantity
      base_uom: mrItem.base_uom,
      // COPY account assignment from MR
      account_assignment_code: mrItem.account_assignment_code,
      cost_center: mrItem.cost_center,
      wbs_element: mrItem.wbs_element,
      activity_code: mrItem.activity_code,
      asset_number: mrItem.asset_number,
      order_number: mrItem.order_number,
      tenant_id: mr.tenant_id
    })
  
  return pr
}
```

### STEP 7: PO Creation from PR

**Similar pattern** - copy account assignment from PR to PO:
```typescript
// In PO creation
await supabase
  .from('purchase_order_items')
  .insert({
    po_id: po.id,
    pr_item_id: prItem.id,
    // ... other fields
    // COPY account assignment from PR
    account_assignment_code: prItem.account_assignment_code,
    cost_center: prItem.cost_center,
    wbs_element: prItem.wbs_element,
    activity_code: prItem.activity_code,
    asset_number: prItem.asset_number,
    order_number: prItem.order_number
  })
```

## Testing Checklist

- [ ] Run `init_account_assignment.sql` in Supabase
- [ ] Verify tables created: `account_assignment_types`, `mr_type_account_assignment_mapping`
- [ ] Test API: `/api/account-assignments?mrType=PROJECT`
- [ ] Create MR with PROJECT type → should show WB and WA options
- [ ] Create MR with GENERAL type → should show only CC option
- [ ] Submit MR → verify account assignment saved in `material_request_items`
- [ ] Approve MR → verify PR created with same account assignment
- [ ] Create PO from PR → verify account assignment copied

## Key Business Rules

1. **MR Type determines allowed account assignments**
   - PROJECT → WB or WA
   - MAINTENANCE → OM or CC
   - GENERAL → CC only
   - ASSET → AS only

2. **Account assignment flows unchanged**
   - MR line → PR line → PO line → GR → FI posting
   - Never modified, only copied

3. **Required fields validation**
   - CC requires: cost_center
   - WB requires: wbs_element
   - AS requires: asset_number
   - WA requires: wbs_element + activity_code
   - OM/OP/OQ require: order_number

4. **Line-item level**
   - Each line can have different account assignment
   - Header has organizational data (company, plant)
   - Line has account assignment (cost object)

## Files Created

1. ✅ `domains/administration/accountAssignmentService.ts` - Service layer
2. ✅ `app/api/account-assignments/route.ts` - API endpoint
3. ✅ `database/init_account_assignment.sql` - Database schema

## Next Steps

1. Run SQL script in Supabase
2. Update `UnifiedMaterialRequestComponent.tsx` with steps above
3. Test MR creation with account assignment
4. Implement PR auto-creation logic
5. Implement PO creation from PR
