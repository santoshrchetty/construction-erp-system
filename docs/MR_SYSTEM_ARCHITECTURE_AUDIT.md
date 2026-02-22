# MR System Architecture & PR Fields Audit

## 1. PR Fields Implementation Status ✅

### Purchase Requisition Header Fields
```typescript
// All fields properly implemented in types/material-request-database.ts
purchase_requisitions: {
  pr_number: string                    ✅ Unique PR identifier
  pr_type: 'NB' | 'UB' | 'KB' | 'LB'  ✅ Standard/Transfer/Consignment/Subcontracting
  status: 'OPEN' | 'RELEASED' | 'ORDERED' | 'CLOSED' | 'CANCELLED'  ✅
  priority: 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT'  ✅
  created_from_mr: string | null       ✅ Link to source MR
  company_code: string                 ✅ Organizational unit
  purchasing_organization: string      ✅ Purchasing org
  purchasing_group: string | null      ✅ Buyer group
  requested_by: string                 ✅ Requestor
  total_value: number | null           ✅ Total PR value
  currency: string | null              ✅ Currency code
  approval_status: string | null       ✅ Approval workflow status
}
```

### Purchase Requisition Line Item Fields
```typescript
// All critical PR line fields implemented
purchase_requisition_items: {
  material_code: string                           ✅ Material number
  quantity: number                                ✅ Requested quantity
  unit_of_measure: string                         ✅ UoM
  delivery_date: string                           ✅ Required delivery date
  plant_code: string | null                       ✅ Receiving plant
  storage_location: string | null                 ✅ Storage location
  material_group: string | null                   ✅ Material group
  price_per_unit: number | null                   ✅ Unit price
  currency: string | null                         ✅ Currency
  
  // Account Assignment - Complete Implementation
  account_assignment_category: 'K'|'P'|'A'|'F'|'O'|'N'|'S'|'U'  ✅
  cost_center: string | null                      ✅ Cost center
  project_code: string | null                     ✅ Project
  wbs_element: string | null                      ✅ WBS element
  internal_order: string | null                   ✅ Internal order
  asset_number: string | null                     ✅ Asset number
  profit_center: string | null                    ✅ Profit center
  gl_account: string | null                       ✅ G/L account
  
  // Procurement Fields
  supplier_code: string | null                    ✅ Preferred vendor
  purchase_info_record: string | null             ✅ Info record
  tax_code: string | null                         ✅ Tax code
  delivery_address: string | null                 ✅ Delivery address
}
```

## 2. 4-Layer Architecture Compliance ✅

### Current Folder Structure
```
Construction_App/
├── app/api/material-requests/          # Layer 1: API Routes
│   ├── route.ts                        # HTTP handling
│   ├── list/route.ts                   # List endpoint
│   └── approvals/route.ts              # Approvals endpoint
├── domains/materials/                  # Layer 3: Services
│   ├── materialRequestService.ts       # Core MR business logic
│   ├── materialRequestApprovalService.ts # Approval workflows
│   └── unifiedMaterialRequestService.ts # Unified operations
├── components/features/materials/      # UI Components
│   ├── MaterialRequestFormV2.tsx      # Form component
│   ├── MaterialRequestList.tsx        # List component
│   └── UnifiedMaterialRequestComponent.tsx
└── types/material-request-database.ts  # Type definitions
```

### Missing Layer 2 (Handlers) ⚠️
```typescript
// Need to create: app/api/material-requests/handler.ts
export async function handleMaterialRequests(action: string, body: any, method: string) {
  switch (action) {
    case 'create':
      return await materialRequestService.createMaterialRequest(body)
    case 'approve':
      return await materialRequestApprovalService.approveMaterialRequest(body)
    case 'list':
      return await materialRequestService.getMaterialRequestsList(body)
    default:
      return { error: 'Unknown action' }
  }
}
```

### Missing Layer 4 (Repositories) ⚠️
```typescript
// Need to create: domains/materials/repositories/materialRequestRepository.ts
export class MaterialRequestRepository {
  async getMaterialRequests(filters: any) {
    const supabase = await createServiceClient()
    return await supabase.from('material_requests').select('*').match(filters)
  }
  
  async createMaterialRequest(data: MaterialRequestInsert) {
    const supabase = await createServiceClient()
    return await supabase.from('material_requests').insert(data)
  }
}
```

## 3. Fiori Screen Layout Design

### MR Create/Edit Screen (Object Page Layout)
```
┌─────────────────────────────────────────────────────────────┐
│ Material Request MR-2024-001                    [Save] [Submit] │
├─────────────────────────────────────────────────────────────┤
│ Header Information                                           │
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│ │ MR Type         │ │ Priority        │ │ Required Date   │ │
│ │ [PRODUCTION ▼]  │ │ [HIGH ▼]        │ │ [2024-01-15]    │ │
│ └─────────────────┘ └─────────────────┘ └─────────────────┘ │
│                                                             │
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│ │ Company Code    │ │ Plant Code      │ │ Cost Center     │ │
│ │ [C001 ▼]        │ │ [P001 ▼]        │ │ [CC-PROD ▼]     │ │
│ └─────────────────┘ └─────────────────┘ └─────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ Line Items                                        [Add Line] │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Line │ Material    │ Description │ Qty │ UoM │ Acct Assgn│ │
│ │  10  │ MAT-001     │ Steel Bars  │ 100 │ TON │ OP-001    │ │
│ │  20  │ MAT-002     │ Cement      │  50 │ BAG │ OP-001    │ │
│ │  30  │ OFF-001     │ Stationery  │  10 │ SET │ CC-ADMIN  │ │
│ └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ Account Assignment Details (Per Line)                       │
│ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│ │ Category        │ │ Production Order│ │ Operation       │ │
│ │ [OP ▼]          │ │ [PO-2024-001]   │ │ [0010]          │ │
│ └─────────────────┘ └─────────────────┘ └─────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ Approval Information                                        │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Status: DRAFT → SUBMITTED → APPROVED                    │ │
│ │ Workflow: WF-PRODUCTION-HIGH                            │ │
│ │ Next Approver: Production Manager                       │ │
│ └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### MR List Screen (List Report Layout)
```
┌─────────────────────────────────────────────────────────────┐
│ Material Requests                              [Create New] │
├─────────────────────────────────────────────────────────────┤
│ Filters                                                     │
│ [MR Type ▼] [Status ▼] [Date Range] [Company ▼] [Search...] │
├─────────────────────────────────────────────────────────────┤
│ MR Number    │ Type       │ Status    │ Requestor │ Date     │
│ MR-2024-001  │ PRODUCTION │ APPROVED  │ J.Smith   │ 15/01/24 │
│ MR-2024-002  │ QUALITY    │ PENDING   │ M.Jones   │ 14/01/24 │
│ MR-2024-003  │ PROJECT    │ DRAFT     │ A.Brown   │ 13/01/24 │
└─────────────────────────────────────────────────────────────┘
```

## 4. Required Implementation Tasks

### Immediate (High Priority)
1. **Create Handler Layer** - `app/api/material-requests/handler.ts`
2. **Create Repository Layer** - `domains/materials/repositories/`
3. **Update Services** - Remove direct DB calls, use repositories
4. **Add OP/OQ Account Assignment** - UI dropdowns for Production/Quality

### Medium Priority
5. **Implement Fiori Components** - Object Page and List Report layouts
6. **Add Workflow Integration** - Connect approval workflows
7. **Update Form Validation** - Account assignment validation rules

### Low Priority
8. **Performance Optimization** - Add caching and indexing
9. **Testing** - Unit tests for all layers
10. **Documentation** - API documentation and user guides

## Status: ⚠️ PARTIALLY COMPLETE
- ✅ PR Fields: Complete and correct
- ✅ Type Definitions: Complete
- ⚠️ Architecture: Missing Handler and Repository layers
- ❌ Fiori UI: Not implemented
- ❌ OP/OQ Integration: Not implemented